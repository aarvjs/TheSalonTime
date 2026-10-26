import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/customer_profile_model.dart';

class CustomerProfileService {
  CustomerProfileService._();
  static final CustomerProfileService instance = CustomerProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('customers');

  final ValueNotifier<CustomerProfileModel?> currentProfileNotifier =
      ValueNotifier<CustomerProfileModel?>(null);

  CustomerProfileModel? get currentProfile => currentProfileNotifier.value;

  /// Fetch customer profile from Firestore
  Future<CustomerProfileModel?> getCustomerProfile(String uid) async {
    try {
      if (uid.isEmpty) return null;
      final doc = await _collection.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        currentProfileNotifier.value = null;
        return null;
      }
      final profile = CustomerProfileModel.fromMap(doc.data()!, doc.id);
      currentProfileNotifier.value = profile;
      return profile;
    } catch (e, stack) {
      developer.log('Error fetching customer profile: $e', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Upload optional photo to Firebase Storage and return download URL
  Future<String?> uploadProfilePhoto(String uid, File photoFile) async {
    try {
      final ref = _storage.ref().child('customer_photos').child('$uid.jpg');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': uid},
      );
      final uploadTask = await ref.putFile(photoFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stack) {
      developer.log('Error uploading customer photo: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Save or update customer profile strictly compliant with Firestore Security Rules
  Future<CustomerProfileModel> saveCustomerProfile(
    CustomerProfileModel profile, {
    File? newPhotoFile,
  }) async {
    try {
      String? photoUrl = profile.photoUrl;
      if (newPhotoFile != null) {
        photoUrl = await uploadProfilePhoto(profile.uid, newPhotoFile);
      }

      final docRef = _collection.doc(profile.uid);
      final docSnap = await docRef.get();
      final isNew = !docSnap.exists;

      final updatedProfile = profile.copyWith(photoUrl: photoUrl);
      final dataMap = updatedProfile.toMap(isNew: isNew);

      if (isNew) {
        await docRef.set(dataMap);
      } else {
        // Safe update: ensure createdAt is never modified or sent in affectedKeys
        dataMap.remove('createdAt');
        await docRef.set(dataMap, SetOptions(merge: true));
      }

      // Re-fetch to get server timestamps
      final fresh = await getCustomerProfile(profile.uid) ?? updatedProfile;
      currentProfileNotifier.value = fresh;
      return fresh;
    } catch (e, stack) {
      developer.log('Error saving customer profile: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Save the initially selected gender upon successful login without overwriting existing fields
  Future<void> saveInitialGender({
    required String uid,
    required String phoneNumber,
    required String gender,
  }) async {
    try {
      final docRef = _collection.doc(uid);
      final docSnap = await docRef.get();
      if (docSnap.exists && docSnap.data() != null) {
        // Document already exists, only update gender and updatedAt safely
        await docRef.set({
          'gender': gender,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (currentProfileNotifier.value != null) {
          currentProfileNotifier.value =
              currentProfileNotifier.value!.copyWith(gender: gender);
        } else {
          await getCustomerProfile(uid);
        }
      } else {
        // New customer document
        final initialProfile = CustomerProfileModel(
          uid: uid,
          phoneNumber: phoneNumber,
          gender: gender,
          profileCompleted: false,
        );
        await docRef.set(initialProfile.toMap(isNew: true));
        currentProfileNotifier.value = initialProfile;
      }
    } catch (e, stack) {
      developer.log('Error saving initial customer gender: $e',
          error: e, stackTrace: stack);
    }
  }

  /// Update ONLY the gender field in Firestore, preserving all other profile data
  Future<void> updateGender(String uid, String newGender) async {
    try {
      await _collection.doc(uid).set({
        'gender': newGender,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (currentProfileNotifier.value != null) {
        currentProfileNotifier.value =
            currentProfileNotifier.value!.copyWith(gender: newGender);
      } else {
        await getCustomerProfile(uid);
      }
    } catch (e, stack) {
      developer.log('Error updating gender: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Save or update device location coordinates for the customer
  Future<void> updateLocation(
    String uid, {
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    try {
      await _collection.doc(uid).set({
        'latitude': latitude,
        'longitude': longitude,
        'locationPermissionStatus': status,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (currentProfileNotifier.value != null) {
        currentProfileNotifier.value = currentProfileNotifier.value!.copyWith(
          latitude: latitude,
          longitude: longitude,
          locationPermissionStatus: status,
          locationUpdatedAt: DateTime.now(),
        );
      }
    } catch (e, stack) {
      developer.log('Error updating customer location: $e',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update permission status without coordinates
  Future<void> updateLocationPermissionStatus(
    String uid,
    String status,
  ) async {
    try {
      await _collection.doc(uid).set({
        'locationPermissionStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (currentProfileNotifier.value != null) {
        currentProfileNotifier.value = currentProfileNotifier.value!.copyWith(
          locationPermissionStatus: status,
        );
      }
    } catch (e, stack) {
      developer.log('Error updating location permission status: $e',
          error: e, stackTrace: stack);
    }
  }

  /// Record skipped profile setup with profileCompleted = false
  Future<void> recordProfileSkipped(String uid, String phoneNumber) async {
    try {
      final docRef = _collection.doc(uid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        final partial = CustomerProfileModel(
          uid: uid,
          phoneNumber: phoneNumber,
          profileCompleted: false,
        );
        await docRef.set(partial.toMap(isNew: true));
        currentProfileNotifier.value = partial;
      }
    } catch (e, stack) {
      developer.log('Error recording skipped profile: $e', error: e, stackTrace: stack);
    }
  }

  void clearLocalProfile() {
    currentProfileNotifier.value = null;
  }
}
