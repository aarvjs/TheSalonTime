import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../auth/services/partner_auth_service.dart';
import '../models/partner_models.dart';

class PartnerFirestoreService {
  PartnerFirestoreService._();
  static final PartnerFirestoreService instance = PartnerFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _partnersCol =>
      _firestore.collection('partners');
  CollectionReference<Map<String, dynamic>> get _salonsCol =>
      _firestore.collection('salons');
  CollectionReference<Map<String, dynamic>> get _branchesCol =>
      _firestore.collection('branches');
  CollectionReference<Map<String, dynamic>> get _homeServiceCol =>
      _firestore.collection('home_service_profiles');
  CollectionReference<Map<String, dynamic>> get _managersCol =>
      _firestore.collection('branch_managers');
  CollectionReference<Map<String, dynamic>> get _bookingsCol =>
      _firestore.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _transactionsCol =>
      _firestore.collection('earnings_transactions');

  /// Fetch partner document from Firestore
  Future<PartnerModel?> getPartnerProfile(String uid) async {
    try {
      if (uid.isEmpty) return null;
      final doc = await _partnersCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return PartnerModel.fromMap(doc.data()!, doc.id);
    } catch (e, stack) {
      developer.log('Error fetching partner profile: $e', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Create new partner profile document in Firestore
  Future<PartnerModel> createPartnerProfile({
    required String uid,
    required String fullName,
    required String phone,
    String? businessName,
    PartnerBusinessModel businessModel = PartnerBusinessModel.both,
  }) async {
    try {
      final formattedPhone = PartnerAuthService.formatPhoneNumber(phone);
      final authEmail = PartnerAuthService.formatAuthEmail(phone);
      final salonTradeName = (businessName != null && businessName.trim().isNotEmpty)
          ? businessName.trim()
          : "${fullName.trim()}'s Salon";

      final partner = PartnerModel(
        id: uid,
        fullName: fullName.trim(),
        email: authEmail,
        phone: formattedPhone,
        businessName: salonTradeName,
        verificationStatus: PartnerVerificationStatus.notSubmitted,
        businessModel: businessModel,
        activeBusinessModel: businessModel,
      );

      await _partnersCol.doc(uid).set(partner.toMap(isNew: true));
      developer.log('Partner profile document created in Firestore: $uid');
      return partner;
    } catch (e, stack) {
      developer.log('Error creating partner profile: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update only permitted profile fields in Firestore
  Future<void> updatePartnerProfile(
    String uid, {
    String? fullName,
    String? businessName,
    String? profilePhoto,
    PartnerBusinessModel? businessModel,
    PartnerBusinessModel? activeBusinessModel,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null && fullName.trim().isNotEmpty) {
        updateData['fullName'] = fullName.trim();
      }
      if (businessName != null && businessName.trim().isNotEmpty) {
        updateData['businessName'] = businessName.trim();
      }
      if (profilePhoto != null && profilePhoto.trim().isNotEmpty) {
        updateData['profilePhoto'] = profilePhoto.trim();
      }
      if (businessModel != null) {
        updateData['businessModel'] = businessModel.name;
      }
      if (activeBusinessModel != null) {
        updateData['activeBusinessModel'] = activeBusinessModel.name;
      }

      await _partnersCol.doc(uid).set(updateData, SetOptions(merge: true));
      developer.log('Partner profile updated in Firestore: $uid');
    } catch (e, stack) {
      developer.log('Error updating partner profile: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update business model preference
  Future<void> updateBusinessModel(String uid, PartnerBusinessModel model) async {
    try {
      await _partnersCol.doc(uid).set({
        'businessModel': model.name,
        'activeBusinessModel': model.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error updating business model: $e');
    }
  }

  /// Upload partner photo to Firebase Storage and return download URL
  Future<String?> uploadPartnerPhoto(String uid, File photoFile) async {
    try {
      final ref = _storage.ref().child('partner_photos').child('$uid.jpg');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': uid},
      );
      final uploadTask = await ref.putFile(photoFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stack) {
      developer.log('Error uploading partner photo: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Upload partner verification document to Firebase Storage and return download URL
  Future<String> uploadPartnerDocument({
    required String uid,
    required File file,
    required String fileName,
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'pdf';
      final mimeType = ext == 'pdf'
          ? 'application/pdf'
          : ext == 'png'
              ? 'image/png'
              : 'image/jpeg';
      final cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'partner_docs/$uid/${DateTime.now().millisecondsSinceEpoch}_$cleanName';
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'uploadedBy': uid,
          'originalName': fileName,
        },
      );
      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stack) {
      developer.log('Error uploading partner document: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Submit partner verification documents and business details to Firestore
  Future<PartnerModel> submitVerificationDocuments({
    required String uid,
    required String legalName,
    required String businessName,
    required String businessType,
    required String regNumber,
    required String businessAddress,
    required List<PartnerDocumentModel> documents,
  }) async {
    try {
      final docData = <String, dynamic>{
        'legalName': legalName.trim(),
        'businessName': businessName.trim(),
        'businessType': businessType.trim(),
        'regNumber': regNumber.trim(),
        'businessAddress': businessAddress.trim(),
        'documents': documents.map((d) => d.toMap()).toList(),
        'verificationStatus': 'submitted',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _partnersCol.doc(uid).set(docData, SetOptions(merge: true));
      developer.log('Partner verification submitted in Firestore: $uid');

      final updatedPartner = await getPartnerProfile(uid);
      if (updatedPartner != null) {
        return updatedPartner;
      }

      return PartnerModel(
        id: uid,
        fullName: legalName,
        email: '',
        phone: '',
        businessName: businessName,
        legalName: legalName,
        businessType: businessType,
        regNumber: regNumber,
        businessAddress: businessAddress,
        verificationStatus: PartnerVerificationStatus.submitted,
        submittedAt: DateTime.now(),
        documents: documents,
      );
    } catch (e, stack) {
      developer.log('Error submitting partner verification: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ==========================================
  // SALON LOCATIONS MANAGEMENT (MY SALONS)
  // ==========================================

  /// Fetch all salon locations belonging to a partner
  Future<List<SalonModel>> fetchPartnerSalons(String partnerId) async {
    try {
      if (partnerId.isEmpty) return const [];

      var querySnapshot = await _salonsCol
          .where('partnerId', isEqualTo: partnerId)
          .get();

      var salons = querySnapshot.docs
          .map((doc) => SalonModel.fromMap(doc.data(), doc.id))
          .toList();

      if (salons.isNotEmpty) {
        return salons;
      }

      // Check with current auth user uid if different
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && currentUid.isNotEmpty && currentUid != partnerId) {
        final querySnap2 = await _salonsCol
            .where('partnerId', isEqualTo: currentUid)
            .get();
        if (querySnap2.docs.isNotEmpty) {
          return querySnap2.docs
              .map((doc) => SalonModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }

      // Backward compatibility check 1: Document keyed by partnerId
      final singleDoc = await _salonsCol.doc(partnerId).get();
      if (singleDoc.exists && singleDoc.data() != null) {
        return [SalonModel.fromMap(singleDoc.data()!, singleDoc.id)];
      }

      // Backward compatibility check 2: Legacy branches collection
      final branchSnap = await _branchesCol
          .where('partnerId', isEqualTo: partnerId)
          .get();

      if (branchSnap.docs.isNotEmpty) {
        return branchSnap.docs.map((doc) {
          final data = doc.data();
          return SalonModel.fromMap(data, doc.id);
        }).toList();
      }

      return const [];
    } catch (e, stack) {
      developer.log('Error fetching partner salons: $e', error: e, stackTrace: stack);
      return const [];
    }
  }

  // ==========================================
  // BOOKINGS & EARNINGS MANAGEMENT (DYNAMIC REAL FIRESTORE)
  // ==========================================

  /// Fetch all customer appointments/bookings belonging to a partner
  Future<List<PartnerBookingModel>> fetchPartnerBookings(
    String partnerId, {
    List<String>? salonIds,
    List<String>? salonNames,
  }) async {
    try {
      final Map<String, PartnerBookingModel> results = {};

      if (partnerId.isNotEmpty) {
        final snap = await _bookingsCol
            .where('partnerId', isEqualTo: partnerId)
            .get();
        for (final doc in snap.docs) {
          results[doc.id] = PartnerBookingModel.fromMap(doc.data(), doc.id);
        }
      }

      // Also check with current auth UID if different
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && currentUid.isNotEmpty && currentUid != partnerId) {
        final snap2 = await _bookingsCol
            .where('partnerId', isEqualTo: currentUid)
            .get();
        for (final doc in snap2.docs) {
          results[doc.id] = PartnerBookingModel.fromMap(doc.data(), doc.id);
        }
      }

      // Also scan recent bookings and match by partnerId, salonId, or salonName
      final allSnap = await _bookingsCol.limit(100).get();
      for (final doc in allSnap.docs) {
        final data = doc.data();
        final docPartnerId = data['partnerId'] as String?;
        final docSalonId = (data['salonId'] ?? data['branchId']) as String?;
        final docSalonName = (data['salonName'] ?? data['branchName']) as String?;

        bool isMatch = false;
        if (partnerId.isNotEmpty && docPartnerId == partnerId) {
          isMatch = true;
        } else if (currentUid != null && currentUid.isNotEmpty && docPartnerId == currentUid) {
          isMatch = true;
        } else if (salonIds != null && salonIds.isNotEmpty && docSalonId != null && salonIds.contains(docSalonId)) {
          isMatch = true;
        } else if (salonNames != null && salonNames.isNotEmpty && docSalonName != null &&
            salonNames.any((sn) => docSalonName.toLowerCase().contains(sn.toLowerCase()))) {
          isMatch = true;
        } else if (docPartnerId == 'partner_default' || (docPartnerId == null || docPartnerId.isEmpty)) {
          // If no specific partner attached, allow the salon partner to handle it
          isMatch = true;
        }

        if (isMatch) {
          results[doc.id] = PartnerBookingModel.fromMap(data, doc.id);
        }
      }

      final list = results.values.toList();
      list.sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime));
      return list;
    } catch (e) {
      developer.log('Error fetching partner bookings from firestore: $e');
      return const [];
    }
  }

  /// Fetch all financial transactions/ledger belonging to a partner
  Future<List<EarningsTransactionModel>> fetchPartnerTransactions(String partnerId) async {
    try {
      if (partnerId.isEmpty) return const [];
      final snap = await _transactionsCol
          .where('partnerId', isEqualTo: partnerId)
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((doc) => EarningsTransactionModel.fromMap(doc.data(), doc.id))
            .toList();
      }

      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && currentUid.isNotEmpty && currentUid != partnerId) {
        final snap2 = await _transactionsCol
            .where('partnerId', isEqualTo: currentUid)
            .get();
        return snap2.docs
            .map((doc) => EarningsTransactionModel.fromMap(doc.data(), doc.id))
            .toList();
      }
      return const [];
    } catch (e) {
      developer.log('Error fetching partner transactions from firestore: $e');
      return const [];
    }
  }

  /// Save booking to Firestore
  Future<void> saveBooking(PartnerBookingModel booking) async {
    try {
      await _bookingsCol.doc(booking.id).set(
        booking.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      developer.log('Error saving booking to firestore: $e');
    }
  }

  /// Update booking status in Firestore
  Future<void> updateBookingStatus(
    String bookingId,
    PartnerBookingStatus status, {
    DateTime? rescheduledDateTime,
    String? rescheduledNote,
    String? cancellationReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status == PartnerBookingStatus.cancelled ? 'cancelled' : status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (rescheduledDateTime != null) {
        updateData['appointmentDateTime'] = rescheduledDateTime.toIso8601String();
        updateData['date'] = rescheduledDateTime.toIso8601String();
      }
      if (rescheduledNote != null && rescheduledNote.isNotEmpty) {
        updateData['rescheduledNote'] = rescheduledNote;
      }
      if (cancellationReason != null && cancellationReason.isNotEmpty) {
        updateData['cancellationReason'] = cancellationReason;
      }

      await _bookingsCol.doc(bookingId).set(updateData, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error updating booking status in firestore: $e');
    }
  }

  /// Save earnings transaction to Firestore
  Future<void> saveTransaction(EarningsTransactionModel transaction) async {
    try {
      await _transactionsCol.doc(transaction.id).set(
        transaction.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      developer.log('Error saving transaction to firestore: $e');
    }
  }

  /// Create or update a salon location in Firestore
  Future<void> saveSalonLocation(SalonModel salon) async {
    try {
      final docId = salon.salonId.isNotEmpty
          ? salon.salonId
          : 'salon_${DateTime.now().millisecondsSinceEpoch}';

      final currentAuthUid = FirebaseAuth.instance.currentUser?.uid;
      final effectivePartnerId = (currentAuthUid != null && currentAuthUid.isNotEmpty)
          ? currentAuthUid
          : (salon.partnerId.isNotEmpty ? salon.partnerId : 'partner_demo');

      final salonToSave = salon.copyWith(
        salonId: docId,
        partnerId: effectivePartnerId,
      );

      // Primary write to `salons/{salonId}`
      await _salonsCol.doc(docId).set(
            salonToSave.toMap(),
            SetOptions(merge: true),
          );

      developer.log('Salon location saved in Firestore: $docId');
    } catch (e, stack) {
      developer.log('Error saving salon location: $e', error: e, stackTrace: stack);
    }
  }

  /// Toggle active status for a specific salon location
  Future<void> toggleSalonLocationStatus(String salonId, bool isActive) async {
    try {
      await _salonsCol.doc(salonId).update({
        'isActive': isActive,
        'salonStatus': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error toggling salon status: $e');
    }
  }

  /// Fetch all branches belonging to a partner (backward-compatible adapter)
  Future<List<BranchModel>> fetchPartnerBranches(String partnerId) async {
    final salons = await fetchPartnerSalons(partnerId);
    if (salons.isNotEmpty) {
      return salons.map((s) => BranchModel.fromSalon(s)).toList();
    }
    return const [];
  }

  /// Create or update a branch in Firestore (backward-compatible adapter)
  Future<void> saveBranch(BranchModel branch) async {
    final salon = SalonModel(
      salonId: branch.branchId,
      partnerId: branch.partnerId,
      name: branch.branchName,
      description: 'Salon Location - ${branch.branchName}',
      category: 'Unisex Salon',
      address: branch.address,
      city: branch.city,
      state: branch.state,
      postalCode: branch.postalCode,
      latitude: branch.latitude,
      longitude: branch.longitude,
      phone: branch.phone,
      email: branch.email,
      openingHours: branch.openingHours,
      closingHours: branch.closingHours,
      operatingDays: branch.operatingDays,
      serviceRadiusKm: branch.serviceRadiusKm,
      isHomeServiceEnabled: branch.isHomeServiceEnabled,
      salonStatus: branch.isActive,
      assignedManagerUid: branch.managerId,
      managerName: branch.managerName,
      services: branch.services,
    );
    await saveSalonLocation(salon);
  }

  /// Toggle active status for a specific branch (backward-compatible adapter)
  Future<void> toggleBranchStatus(String branchId, bool isActive) async {
    await toggleSalonLocationStatus(branchId, isActive);
  }

  /// Assign manager to a salon location
  Future<void> assignBranchManager({
    required String branchId,
    required String managerId,
    required String managerName,
  }) async {
    try {
      await _salonsCol.doc(branchId).set({
        'assignedManagerUid': managerId,
        'managerId': managerId,
        'managerName': managerName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _managersCol.doc(managerId).set({
        'assignedSalonId': branchId,
        'assignedSalonName': managerName,
        'assignedBranchId': branchId,
        'assignedBranchName': managerName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error assigning salon manager: $e');
    }
  }

  /// Fetch all branch managers assigned by a partner
  Future<List<BranchManagerModel>> fetchBranchManagers(String partnerId) async {
    try {
      final snap = await _managersCol
          .where('assignedPartnerId', isEqualTo: partnerId)
          .get();
      return snap.docs
          .map((doc) => BranchManagerModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      developer.log('Error fetching managers: $e');
      return const [];
    }
  }

  /// Save branch manager
  Future<void> saveBranchManager(BranchManagerModel manager) async {
    try {
      await _managersCol.doc(manager.managerId).set(
            manager.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      developer.log('Error saving branch manager: $e');
    }
  }

  // ==========================================
  // SALON-SPECIFIC SERVICES MANAGEMENT (UNLIMITED)
  // ==========================================

  /// Upload salon service photo to Firebase Storage and return download URL
  Future<String> uploadSalonServicePhoto({
    required String salonId,
    required String serviceId,
    required File file,
  }) async {
    try {
      final fileName = 'srv_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage
          .ref()
          .child('salon_services')
          .child(salonId)
          .child(serviceId)
          .child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'salonId': salonId,
          'serviceId': serviceId,
        },
      );

      final uploadTask = await storageRef.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stack) {
      developer.log('Error uploading salon service photo: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Fetch all services specifically belonging to a salon location
  Future<List<SalonServiceModel>> fetchSalonServices(String salonId) async {
    if (salonId.isEmpty) return const [];
    try {
      // 1. Fetch from subcollection `salons/{salonId}/services`
      final subSnap = await _salonsCol
          .doc(salonId)
          .collection('services')
          .get();

      if (subSnap.docs.isNotEmpty) {
        return subSnap.docs
            .map((doc) => SalonServiceModel.fromMap(doc.data(), doc.id))
            .toList();
      }

      // 2. Backward compatibility fallback: check `services` array on salon document
      final doc = await _salonsCol.doc(salonId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawServices = data['services'];
        if (rawServices is List && rawServices.isNotEmpty) {
          final list = <SalonServiceModel>[];
          for (final s in rawServices) {
            if (s is Map<String, dynamic>) {
              list.add(SalonServiceModel.fromMap(s));
            } else if (s is Map) {
              list.add(SalonServiceModel.fromMap(Map<String, dynamic>.from(s)));
            }
          }
          return list;
        }
      }
      return const [];
    } catch (e) {
      developer.log('Error fetching salon services: $e');
      return const [];
    }
  }

  /// Add or update a salon-specific service in Firestore
  /// (synchronizes both `salons/{salonId}/services/{serviceId}` and the salon's `services` array)
  Future<void> saveSalonService({
    required String salonId,
    required SalonServiceModel service,
    required String partnerId,
  }) async {
    if (salonId.isEmpty) return;
    try {
      final serviceMap = {
        'id': service.id,
        'serviceId': service.id,
        'salonId': salonId,
        'partnerId': partnerId,
        'name': service.name,
        'serviceName': service.name,
        'category': service.category,
        'categoryId': service.category.toLowerCase().replaceAll(' ', '_'),
        'description': service.description,
        'durationMinutes': service.durationMinutes,
        'price': service.price,
        if (service.offerPrice != null) 'offerPrice': service.offerPrice,
        if (service.offerPrice != null) 'discountPrice': service.offerPrice,
        if (service.imageUrl != null) 'imageUrl': service.imageUrl,
        'availableAtSalon': service.availableAtSalon,
        'availableAtHome': service.availableAtHome,
        'isActive': service.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Write to subcollection `salons/{salonId}/services/{service.id}`
      await _salonsCol
          .doc(salonId)
          .collection('services')
          .doc(service.id)
          .set(serviceMap, SetOptions(merge: true));

      // 2. Synchronize to `salons/{salonId}` document's `services` array for backward compatibility
      final salonDoc = await _salonsCol.doc(salonId).get();
      if (salonDoc.exists && salonDoc.data() != null) {
        final data = salonDoc.data()!;
        final raw = data['services'];
        final List<Map<String, dynamic>> currentList = [];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) currentList.add(Map<String, dynamic>.from(item));
          }
        }

        final existingIdx = currentList.indexWhere((s) => s['id'] == service.id || s['serviceId'] == service.id);
        if (existingIdx != -1) {
          currentList[existingIdx] = service.toMap();
        } else {
          currentList.add(service.toMap());
        }

        await _salonsCol.doc(salonId).update({
          'services': currentList,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      developer.log('Salon service saved: ${service.name} for salon $salonId');
    } catch (e, stack) {
      developer.log('Error saving salon service: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Delete a salon-specific service safely from Firestore
  Future<void> deleteSalonService({
    required String salonId,
    required String serviceId,
  }) async {
    if (salonId.isEmpty || serviceId.isEmpty) return;
    try {
      // 1. Delete from subcollection
      await _salonsCol
          .doc(salonId)
          .collection('services')
          .doc(serviceId)
          .delete();

      // 2. Remove from salon document array
      final salonDoc = await _salonsCol.doc(salonId).get();
      if (salonDoc.exists && salonDoc.data() != null) {
        final data = salonDoc.data()!;
        final raw = data['services'];
        if (raw is List) {
          final List<Map<String, dynamic>> currentList = [];
          for (final item in raw) {
            if (item is Map) {
              final mapItem = Map<String, dynamic>.from(item);
              if (mapItem['id'] != serviceId && mapItem['serviceId'] != serviceId) {
                currentList.add(mapItem);
              }
            }
          }
          await _salonsCol.doc(salonId).update({
            'services': currentList,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      developer.log('Salon service deleted: $serviceId from salon $salonId');
    } catch (e, stack) {
      developer.log('Error deleting salon service: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ==========================================
  // HOME SERVICE PROFESSIONAL PROFILE
  // ==========================================

  /// Fetch home service professional profile for a partner
  Future<HomeServiceProfileModel?> getHomeServiceProfile(String partnerId) async {
    try {
      if (partnerId.isEmpty) return null;
      final doc = await _homeServiceCol.doc(partnerId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return HomeServiceProfileModel.fromMap(doc.data()!, doc.id);
    } catch (e, stack) {
      developer.log('Error fetching home service profile: $e', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Save or update home service professional profile
  Future<void> saveHomeServiceProfile(HomeServiceProfileModel profile) async {
    try {
      await _homeServiceCol.doc(profile.partnerId).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
      developer.log('Home service profile saved in Firestore: ${profile.partnerId}');
    } catch (e, stack) {
      developer.log('Error saving home service profile: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Toggle home service availability (Online/Offline)
  Future<void> toggleHomeServiceAvailability(String partnerId, bool isAvailable) async {
    try {
      await _homeServiceCol.doc(partnerId).set({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error toggling home service availability: $e');
    }
  }

  // ==========================================
  // CUSTOMER DISCOVERY (QUERIED BY CUSTOMER APP)
  // ==========================================

  /// Fetch all active branches across all salons for distance calculation and display
  Future<List<BranchModel>> fetchActiveSalonBranches() async {
    try {
      final snap = await _branchesCol.where('isActive', isEqualTo: true).get();
      return snap.docs
          .map((doc) => BranchModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      developer.log('Error fetching active branches for discovery: $e');
      return const [];
    }
  }

  /// Fetch all active home service professional profiles for distance/radius matching
  Future<List<HomeServiceProfileModel>> fetchActiveHomeServiceProviders() async {
    try {
      final snap = await _homeServiceCol.where('isAvailable', isEqualTo: true).get();
      return snap.docs
          .map((doc) => HomeServiceProfileModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      developer.log('Error fetching home service providers for discovery: $e');
      return const [];
    }
  }

  // ==========================================
  // SALON PROFILE MANAGEMENT
  // ==========================================

  /// Fetch primary salon profile by partner UID
  Future<SalonModel?> getSalonProfile(String partnerId) async {
    try {
      final salons = await fetchPartnerSalons(partnerId);
      if (salons.isNotEmpty) return salons.first;

      final doc = await _salonsCol.doc(partnerId).get();
      if (!doc.exists || doc.data() == null) return null;
      return SalonModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      developer.log('Error fetching salon profile: $e');
      return null;
    }
  }

  /// Save salon profile in Firestore
  Future<void> saveSalonProfile(SalonModel salon) async {
    await saveSalonLocation(salon);
  }
}
