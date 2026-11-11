import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/distance_calculator.dart';
import 'home_banner_model.dart';

class HomeSliderModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String salonId;
  final String salonName;
  final String salonAddress;
  final String partnerId;
  final double targetLatitude;
  final double targetLongitude;
  final double visibilityRadiusKm;
  final bool isGlobal;
  final bool isActive;
  final int displayOrder;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int clickCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HomeSliderModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.buttonText = 'Explore Salon',
    required this.salonId,
    this.salonName = '',
    this.salonAddress = '',
    this.partnerId = '',
    this.targetLatitude = 26.4719,
    this.targetLongitude = 80.3524,
    this.visibilityRadiusKm = 5.0,
    this.isGlobal = false,
    this.isActive = true,
    this.displayOrder = 0,
    this.startsAt,
    this.endsAt,
    this.clickCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if promotion is within its scheduled running window
  bool isScheduledActive([DateTime? now]) {
    final current = now ?? DateTime.now();
    if (startsAt != null && current.isBefore(startsAt!)) {
      return false;
    }
    if (endsAt != null && current.isAfter(endsAt!)) {
      return false;
    }
    return true;
  }

  /// Calculate actual distance in kilometers from customer coordinates
  double distanceKm(double userLat, double userLng) {
    return DistanceCalculator.haversineDistanceKm(
      lat1: userLat,
      lon1: userLng,
      lat2: targetLatitude,
      lon2: targetLongitude,
    );
  }

  /// Check whether customer is within this slider's custom visibility radius
  bool isWithinRadius(double userLat, double userLng) {
    if (isGlobal) return true;
    final dist = distanceKm(userLat, userLng);
    return dist <= visibilityRadiusKm;
  }

  /// Factory from Cloud Firestore Document
  factory HomeSliderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return HomeSliderModel(
      id: docId,
      title: map['title'] as String? ?? 'Exclusive Salon Offer',
      subtitle: map['subtitle'] as String? ?? 'Explore appointments at nearest branches.',
      imageUrl: map['imageUrl'] as String? ?? '',
      buttonText: map['buttonText'] as String? ?? 'Explore Salon',
      salonId: map['salonId'] as String? ?? '',
      salonName: map['salonName'] as String? ?? '',
      salonAddress: map['salonAddress'] as String? ?? '',
      partnerId: map['partnerId'] as String? ?? '',
      targetLatitude: (map['targetLatitude'] as num?)?.toDouble() ?? 26.4719,
      targetLongitude: (map['targetLongitude'] as num?)?.toDouble() ?? 80.3524,
      visibilityRadiusKm: (map['visibilityRadiusKm'] as num?)?.toDouble() ?? 5.0,
      isGlobal: map['isGlobal'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      startsAt: parseDate(map['startsAt']),
      endsAt: parseDate(map['endsAt']),
      clickCount: (map['clickCount'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'salonId': salonId,
      'salonName': salonName,
      'salonAddress': salonAddress,
      'partnerId': partnerId,
      'targetLatitude': targetLatitude,
      'targetLongitude': targetLongitude,
      'visibilityRadiusKm': visibilityRadiusKm,
      'isGlobal': isGlobal,
      'isActive': isActive,
      'displayOrder': displayOrder,
      if (startsAt != null) 'startsAt': startsAt!.toIso8601String(),
      if (endsAt != null) 'endsAt': endsAt!.toIso8601String(),
      'clickCount': clickCount,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to HomeBannerModel for visual banner rendering
  HomeBannerModel toBannerModel([double? userLat, double? userLng]) {
    String label = buttonText.toUpperCase();
    if (userLat != null && userLng != null && !isGlobal) {
      final dist = distanceKm(userLat, userLng);
      label = '${DistanceCalculator.formatDistance(dist).toUpperCase()} • $label';
    } else if (isGlobal) {
      label = 'FEATURED • $label';
    }

    return HomeBannerModel(
      id: id,
      smallLabel: label,
      title: title,
      description: subtitle,
      ctaText: buttonText,
      imagePath: imageUrl,
      bgGradientColors: const [
        Color(0xFF0F172A),
        Color(0xFF1E293B),
      ],
      textColor: Colors.white,
      accentColor: const Color(0xFFD4AF37),
    );
  }

  HomeSliderModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? buttonText,
    String? salonId,
    String? salonName,
    String? salonAddress,
    String? partnerId,
    double? targetLatitude,
    double? targetLongitude,
    double? visibilityRadiusKm,
    bool? isGlobal,
    bool? isActive,
    int? displayOrder,
    DateTime? startsAt,
    DateTime? endsAt,
    int? clickCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeSliderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      buttonText: buttonText ?? this.buttonText,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      salonAddress: salonAddress ?? this.salonAddress,
      partnerId: partnerId ?? this.partnerId,
      targetLatitude: targetLatitude ?? this.targetLatitude,
      targetLongitude: targetLongitude ?? this.targetLongitude,
      visibilityRadiusKm: visibilityRadiusKm ?? this.visibilityRadiusKm,
      isGlobal: isGlobal ?? this.isGlobal,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      clickCount: clickCount ?? this.clickCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

