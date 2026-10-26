import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileModel {
  final String uid;
  final String phoneNumber;
  final String displayName;
  final String gender;
  final String? photoUrl;
  final bool profileCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;
  final String? locationPermissionStatus;

  const CustomerProfileModel({
    required this.uid,
    required this.phoneNumber,
    this.displayName = '',
    this.gender = 'Prefer not to say',
    this.photoUrl,
    this.profileCompleted = false,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
    this.locationPermissionStatus,
  });

  CustomerProfileModel copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? gender,
    String? photoUrl,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    DateTime? locationUpdatedAt,
    String? locationPermissionStatus,
  }) {
    return CustomerProfileModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
      locationPermissionStatus: locationPermissionStatus ?? this.locationPermissionStatus,
    );
  }

  Map<String, dynamic> toMap({bool isNew = false}) {
    final map = <String, dynamic>{
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName.trim(),
      'gender': gender,
      'profileCompleted': profileCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Strictly omit null photoUrl so it satisfies Firestore Rules without failing 'photoUrl is string'
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      map['photoUrl'] = photoUrl!.trim();
    }

    if (latitude != null) {
      map['latitude'] = latitude;
    }
    if (longitude != null) {
      map['longitude'] = longitude;
    }
    if (locationPermissionStatus != null) {
      map['locationPermissionStatus'] = locationPermissionStatus;
    }

    // Only set createdAt for brand new documents, never update or touch on existing
    if (isNew) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }
    return map;
  }

  factory CustomerProfileModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return CustomerProfileModel(
      uid: docId.isNotEmpty ? docId : (map['uid'] as String? ?? ''),
      phoneNumber: map['phoneNumber'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      gender: map['gender'] as String? ?? 'Prefer not to say',
      photoUrl: map['photoUrl'] as String?,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: parseDate(map['locationUpdatedAt']),
      locationPermissionStatus: map['locationPermissionStatus'] as String?,
    );
  }
}
