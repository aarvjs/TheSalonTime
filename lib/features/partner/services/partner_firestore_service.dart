import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../auth/services/partner_auth_service.dart';
import '../models/partner_models.dart';

class PartnerFirestoreService {
  PartnerFirestoreService._();
  static final PartnerFirestoreService instance = PartnerFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('partners');

  /// Fetch partner document from Firestore
  Future<PartnerModel?> getPartnerProfile(String uid) async {
    try {
      if (uid.isEmpty) return null;
      final doc = await _collection.doc(uid).get();
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
      );

      await _collection.doc(uid).set(partner.toMap(isNew: true));
      developer.log('Partner profile document created in Firestore: $uid');
      return partner;
    } catch (e, stack) {
      developer.log('Error creating partner profile: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update only permitted profile fields in Firestore (fullName, businessName, profilePhoto)
  Future<void> updatePartnerProfile(
    String uid, {
    String? fullName,
    String? businessName,
    String? profilePhoto,
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

      await _collection.doc(uid).set(updateData, SetOptions(merge: true));
      developer.log('Partner profile updated in Firestore: $uid');
    } catch (e, stack) {
      developer.log('Error updating partner profile: $e', error: e, stackTrace: stack);
      rethrow;
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

      await _collection.doc(uid).set(docData, SetOptions(merge: true));
      developer.log('Partner verification submitted in Firestore: $uid');

      // Fetch fresh updated partner
      final updatedPartner = await getPartnerProfile(uid);
      if (updatedPartner != null) {
        return updatedPartner;
      }

      // Fallback
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
}
