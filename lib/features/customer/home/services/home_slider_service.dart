import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/home_slider_model.dart';
import '../models/salon_model.dart';
import '../../salon/screens/customer_salon_details_screen.dart';
import 'customer_location_state.dart';

class HomeSliderService {
  HomeSliderService._();
  static final HomeSliderService instance = HomeSliderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _slidersCol =>
      _firestore.collection('homeSliders');

  // Session ID for anonymous / safe analytics correlation without storing customer coordinates
  final String _sessionId =
      'sess_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 9000)}';

  // In-memory debouncing map: sliderId -> lastClickTimestamp
  final Map<String, DateTime> _lastClickMap = {};

  /// Real-time stream of all promotional sliders from Cloud Firestore
  Stream<List<HomeSliderModel>> streamActiveSliders() {
    return _slidersCol
        .orderBy('displayOrder', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HomeSliderModel.fromMap(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      developer.log('Error streaming homeSliders from Firestore: $error');
      return <HomeSliderModel>[];
    });
  }

  /// Filter sliders eligible for the current customer based on their location,
  /// slider active state, scheduled promotion windows, and custom radius.
  List<HomeSliderModel> filterEligibleSliders({
    required List<HomeSliderModel> sliders,
    required double? userLat,
    required double? userLng,
    required bool hasSavedLocation,
    required bool isGpsActive,
    required bool isSkipped,
    List<SalonModel>? registeredSalons,
  }) {
    if (sliders.isEmpty) return const [];

    final now = DateTime.now();
    final bool hasValidCustomerLocation =
        (hasSavedLocation || isGpsActive) && !isSkipped && userLat != null && userLng != null;

    final eligible = <HomeSliderModel>[];

    for (final slider in sliders) {
      // 1. Must be marked active by Super Admin
      if (!slider.isActive) continue;

      // 2. Must be within promotional schedule window (if configured)
      if (!slider.isScheduledActive(now)) continue;

      // 3. Verify target salon availability (if target salon is in registered list)
      if (registeredSalons != null && registeredSalons.isNotEmpty && slider.salonId.isNotEmpty) {
        final matchingSalon = registeredSalons.where((s) => s.id == slider.salonId).firstOrNull;
        if (matchingSalon != null && !matchingSalon.isActive) {
          // If the target salon is explicitly marked inactive/paused, hide slider
          continue;
        }
      }

      // 4. Location-Based Radius Visibility Check
      if (slider.isGlobal) {
        // Global sliders are visible to all users regardless of customer location
        eligible.add(slider);
      } else {
        // Location-restricted slider:
        if (!hasValidCustomerLocation) {
          // Customer has no location permission / skipped:
          // Strictly HIDE location-restricted sliders (Do NOT expose to everyone)
          continue;
        }

        // Customer has location: calculate actual distance against slider's custom radius
        final distanceKm = slider.distanceKm(userLat, userLng);
        if (distanceKm <= slider.visibilityRadiusKm) {
          eligible.add(slider);
        }
      }
    }

    // 5. Sort eligible sliders by Super Admin displayOrder ascending
    eligible.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return eligible;
  }

  /// Record atomic slider click in Firestore (increment clickCount + log click event)
  Future<void> recordClick(HomeSliderModel slider) async {
    // 1. Debounce check: prevent accidental duplicate clicks within 3 seconds
    final now = DateTime.now();
    final lastClick = _lastClickMap[slider.id];
    if (lastClick != null && now.difference(lastClick).inMilliseconds < 3000) {
      developer.log('Debounced duplicate click on slider: ${slider.id}');
      return;
    }
    _lastClickMap[slider.id] = now;

    try {
      // 2. Increment clickCount atomically on the slider document
      _slidersCol.doc(slider.id).update({
        'clickCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((err) {
        developer.log('Notice incrementing clickCount on slider ${slider.id}: $err');
      });

      // 3. Record click event in subcollection with safe metadata (no sensitive coordinates)
      final clickData = {
        'sliderId': slider.id,
        'customerId': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
        'sessionId': _sessionId,
        'clickedAt': FieldValue.serverTimestamp(),
      };

      _slidersCol
          .doc(slider.id)
          .collection('clicks')
          .add(clickData)
          .catchError((err) {
        developer.log('Notice recording click subcollection event: $err');
        return _slidersCol.doc(slider.id);
      });

      developer.log('Click recorded successfully for slider: ${slider.id} (${slider.title})');
    } catch (e) {
      developer.log('Error recording slider click: $e');
    }
  }

  /// Handle slider tap: record analytics and navigate to target salon details page
  Future<void> handleSliderClick(BuildContext context, HomeSliderModel slider) async {
    // Record click telemetry
    recordClick(slider);

    if (slider.salonId.isEmpty) {
      developer.log('Slider ${slider.id} has no target salonId linked.');
      return;
    }

    // 1. First check in memory registered / nearby salons
    final localSalons = CustomerLocationState.instance.strictlyNearestSalons;
    SalonModel? targetSalon = localSalons.where((s) => s.id == slider.salonId).firstOrNull;

    // 2. If not in memory, fetch directly from Firestore `salons/{salonId}`
    if (targetSalon == null) {
      try {
        final docSnap = await _firestore.collection('salons').doc(slider.salonId).get();
        if (docSnap.exists && docSnap.data() != null) {
          targetSalon = SalonModel.fromFirestore(
            data: docSnap.data()!,
            docId: docSnap.id,
            userLat: CustomerLocationState.instance.userLat,
            userLon: CustomerLocationState.instance.userLng,
          );
        }
      } catch (e) {
        developer.log('Error fetching salon for slider navigation: $e');
      }
    }

    // 3. Fallback: if salon document is missing or offline, construct from slider metadata
    if (targetSalon == null && slider.salonName.isNotEmpty) {
      final distKm = slider.distanceKm(
        CustomerLocationState.instance.userLat,
        CustomerLocationState.instance.userLng,
      );
      targetSalon = SalonModel(
        id: slider.salonId,
        name: slider.salonName,
        address: slider.salonAddress.isNotEmpty ? slider.salonAddress : 'Salon Location',
        category: 'Unisex Salon',
        rating: 4.8,
        reviewCount: 120,
        priceTier: '₹₹',
        distance: '${distKm.toStringAsFixed(1)} km',
        distanceKm: distKm,
        imagePath: slider.imageUrl,
        latitude: slider.targetLatitude,
        longitude: slider.targetLongitude,
        isOpen: true,
      );
    }

    // 4. Open salon details screen
    if (targetSalon != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerSalonDetailsScreen(salon: targetSalon!),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target salon location details are currently unavailable.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

