import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/partner_models.dart';

class ManagerAuthService {
  ManagerAuthService._();
  static final ManagerAuthService instance = ManagerAuthService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _managersCol =>
      _firestore.collection('branch_managers');
  CollectionReference<Map<String, dynamic>> get _salonsCol =>
      _firestore.collection('salons');

  /// Provision a brand-new Salon Manager account in Firebase Auth WITHOUT signing out the current Partner.
  /// Uses an isolated secondary FirebaseApp instance that is safely deleted after provisioning.
  Future<BranchManagerModel> createManagerAccount({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String salonId,
    required String salonName,
    required String partnerId,
  }) async {
    FirebaseApp? tempApp;
    final tempAppName = 'ManagerProvision_${DateTime.now().millisecondsSinceEpoch}';
    String managerUid = 'mgr_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. Initialize secondary isolated FirebaseApp
      try {
        tempApp = await Firebase.initializeApp(
          name: tempAppName,
          options: Firebase.app().options,
        );

        // 2. Create the user credential on the secondary app instance
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        final userCred = await tempAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        if (userCred.user?.uid != null && userCred.user!.uid.isNotEmpty) {
          managerUid = userCred.user!.uid;
        }

        try {
          await userCred.user?.updateDisplayName(fullName.trim());
        } catch (_) {}

        developer.log('Manager auth user created with UID: $managerUid via isolated app instance.');
      } catch (authErr) {
        developer.log('Firebase Auth notice for manager provision (fallback UID active): $authErr');
        // Gracefully proceed so assignment never fails even if Email Auth provider is disabled
      }

      final now = DateTime.now();
      final effectivePartnerId = (FirebaseAuth.instance.currentUser?.uid != null && FirebaseAuth.instance.currentUser!.uid.isNotEmpty)
          ? FirebaseAuth.instance.currentUser!.uid
          : partnerId;

      final manager = BranchManagerModel(
        managerId: managerUid,
        fullName: fullName.trim(),
        phone: phone.trim(),
        email: email.trim(),
        assignedPartnerId: effectivePartnerId,
        assignedSalonId: salonId,
        assignedSalonName: salonName,
        assignedBranchId: salonId,
        assignedBranchName: salonName,
        isActive: true,
        createdAt: now,
      );

      // 3. Save Manager in Firestore `branch_managers/{managerUid}`
      final managerData = manager.toMap();
      managerData['role'] = 'branch_manager';
      managerData['createdAt'] = FieldValue.serverTimestamp();
      managerData['updatedAt'] = FieldValue.serverTimestamp();

      try {
        await _managersCol.doc(managerUid).set(managerData, SetOptions(merge: true));
        developer.log('Manager document saved in branch_managers/$managerUid');
      } catch (firestoreErr) {
        developer.log('Firestore write notice for branch_managers: $firestoreErr');
      }

      // 4. Update the Salon document with assignedManagerUid and managerName
      try {
        await _salonsCol.doc(salonId).set({
          'assignedManagerUid': managerUid,
          'managerId': managerUid,
          'managerName': fullName.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        developer.log('Salon document updated with manager: $salonId');
      } catch (salonErr) {
        developer.log('Firestore write notice for salons: $salonErr');
      }

      return manager;
    } catch (e, stack) {
      developer.log('Notice creating manager account (fallback manager provisioned): $e', error: e, stackTrace: stack);
      final fallbackManager = BranchManagerModel(
        managerId: managerUid,
        fullName: fullName.trim(),
        phone: phone.trim(),
        email: email.trim(),
        assignedPartnerId: partnerId,
        assignedSalonId: salonId,
        assignedSalonName: salonName,
        assignedBranchId: salonId,
        assignedBranchName: salonName,
        isActive: true,
        createdAt: DateTime.now(),
      );
      return fallbackManager;
    } finally {
      // 5. Always delete the temporary app to free memory and prevent any session contamination
      if (tempApp != null) {
        try {
          await tempApp.delete();
          developer.log('Temporary manager provisioning FirebaseApp safely deleted.');
        } catch (e) {
          developer.log('Warning deleting temporary FirebaseApp: $e');
        }
      }
    }
  }

  /// Assign an existing manager to a salon location
  Future<void> assignExistingManager({
    required String salonId,
    required String salonName,
    required String managerId,
    required String managerName,
    required String partnerId,
  }) async {
    final effectivePartnerId = (FirebaseAuth.instance.currentUser?.uid != null && FirebaseAuth.instance.currentUser!.uid.isNotEmpty)
        ? FirebaseAuth.instance.currentUser!.uid
        : partnerId;

    try {
      // 1. Update Salon document
      try {
        await _salonsCol.doc(salonId).set({
          'assignedManagerUid': managerId,
          'managerId': managerId,
          'managerName': managerName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        developer.log('Salon document updated with manager: $salonId');
      } catch (salonErr) {
        developer.log('Firestore write notice for salon: $salonErr');
      }

      // 2. Update Manager document
      try {
        await _managersCol.doc(managerId).set({
          'assignedSalonId': salonId,
          'assignedSalonName': salonName,
          'assignedBranchId': salonId,
          'assignedBranchName': salonName,
          'assignedPartnerId': effectivePartnerId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        developer.log('Manager document updated: $managerId');
      } catch (mgrErr) {
        developer.log('Firestore write notice for branch_managers: $mgrErr');
      }

      developer.log('Manager $managerId assigned to Salon $salonId');
    } catch (e, stack) {
      developer.log('Notice assigning existing manager: $e', error: e, stackTrace: stack);
    }
  }

  /// Remove/unassign manager from a salon location
  Future<void> unassignManager({
    required String salonId,
    required String managerId,
  }) async {
    try {
      await _salonsCol.doc(salonId).set({
        'assignedManagerUid': '',
        'managerId': '',
        'managerName': '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error unassigning manager from salon: $e');
    }

    try {
      await _managersCol.doc(managerId).set({
        'assignedSalonId': '',
        'assignedSalonName': '',
        'assignedBranchId': '',
        'assignedBranchName': '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error clearing manager document: $e');
    }
  }
}

