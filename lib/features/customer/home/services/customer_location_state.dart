import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/google_maps_service.dart';
import '../models/salon_model.dart';

class CustomerLocationState extends ChangeNotifier {
  static final CustomerLocationState instance = CustomerLocationState._internal();
  factory CustomerLocationState() => instance;

  CustomerLocationState._internal() {
    init();
  }

  // File for persistent disk storage
  File get _storageFile => File('${Directory.systemTemp.path}/salon_customer_saved_location.json');

  // Default coordinate (fallback before detection)
  double _userLat = 26.4719;
  double _userLng = 80.3524;
  String _locationTitle = 'Locating...';
  bool _isGpsActive = false;
  bool _isLoading = false;
  bool _hasSavedLocation = false;
  bool _isSkipped = false;
  List<SalonModel> _nearbySalons = [];
  String? _errorMessage;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _salonsSubscription;

  // Getters
  double get userLat => _userLat;
  double get userLng => _userLng;
  String get locationTitle => _locationTitle;
  bool get isGpsActive => _isGpsActive;
  bool get isLoading => _isLoading;
  bool get hasSavedLocation => _hasSavedLocation;
  bool get isSkipped => _isSkipped;
  List<SalonModel> get nearbySalons => List.unmodifiable(_nearbySalons);
  String? get errorMessage => _errorMessage;

  void setSkipped(bool val) {
    _isSkipped = val;
    notifyListeners();
  }

  Future<void> clearSavedLocation() async {
    _hasSavedLocation = false;
    _isGpsActive = false;
    _isSkipped = false;
    try {
      if (await _storageFile.exists()) {
        await _storageFile.delete();
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Salons sorted nearest first (never hides registered salons)
  List<SalonModel> get strictlyNearestSalons {
    if (_nearbySalons.isEmpty) return const [];
    return List.unmodifiable(_nearbySalons);
  }

  /// Initial boot check: load saved location from disk first, then check GPS & attach real-time stream
  Future<void> init() async {
    // 1. First, load persisted location from disk
    await _loadSavedLocationFromDisk();

    // 2. Check if device location service & permission is already active
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (isServiceEnabled) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          _isGpsActive = true;
          _isSkipped = false;
          await _reverseGeocodeWithGoogle(pos.latitude, pos.longitude);
          await _saveLocationToDisk();
        }
      }
    } catch (e) {
      developer.log('Silent GPS init check: $e');
    }

    // 3. If still 'Locating...' and no saved location, resolve default coords using Google Maps API
    if (_locationTitle == 'Locating...') {
      await _reverseGeocodeWithGoogle(_userLat, _userLng);
    }

    // 4. Attach real-time Firestore stream to listen for live salon updates
    _listenToSalonsRealtime();
    await fetchNearbySalonsFromFirestore();
  }

  /// Real-time live listener for Firestore salons
  void _listenToSalonsRealtime() {
    _salonsSubscription?.cancel();
    _salonsSubscription = FirebaseFirestore.instance
        .collection('salons')
        .snapshots()
        .listen((snap) {
      final List<SalonModel> parsedSalons = [];

      for (final doc in snap.docs) {
        // Exclude system platform metadata documents
        if (doc.id == 'featured_services_data' ||
            (doc.data()['isSystemDoc'] as bool? ?? false) ||
            doc.data()['isSalon'] == false) {
          continue;
        }

        final data = doc.data();
        final isOpen = (data['isActive'] as bool?) ?? (data['salonStatus'] as bool?) ?? true;
        if (!isOpen) continue;

        final salon = SalonModel.fromFirestore(
          data: data,
          docId: doc.id,
          userLat: _userLat,
          userLon: _userLng,
        );

        parsedSalons.add(salon);
      }

      parsedSalons.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      _nearbySalons = parsedSalons;
      notifyListeners();
    }, onError: (e) {
      developer.log('Error in salons real-time stream: $e');
    });
  }

  /// Request and enable device GPS location with OS permission dialog
  Future<bool> enableGpsLocation([BuildContext? context]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          _errorMessage = 'Location services are disabled on your device.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission was denied by user.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied. Please allow in Settings.';
        _isLoading = false;
        notifyListeners();
        await Geolocator.openAppSettings();
        return false;
      }

      // Fetch high accuracy GPS position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _userLat = position.latitude;
      _userLng = position.longitude;
      _isGpsActive = true;
      _hasSavedLocation = true;
      _isSkipped = false;

      // Reverse geocode with Google Maps Geocoding API (using Google API key)
      await _reverseGeocodeWithGoogle(position.latitude, position.longitude);

      // Save permanently to local storage
      await _saveLocationToDisk();

      // Re-fetch and sort all salons based on new GPS location
      await fetchNearbySalonsFromFirestore();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('Error enabling GPS location: $e');
      _errorMessage = 'Could not fetch current GPS location. Please check settings.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Manually select a city or coordinate and save permanently
  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String title,
  }) async {
    _userLat = lat;
    _userLng = lng;
    _locationTitle = title;
    _isGpsActive = false;
    _hasSavedLocation = true;
    _isSkipped = false;
    notifyListeners();

    // Save permanently to disk
    await _saveLocationToDisk();

    // Re-fetch salons from Firestore sorted by distance
    await fetchNearbySalonsFromFirestore();
  }

  /// Reverse geocode coordinates using Google Maps API (with OSM fallback)
  Future<void> _reverseGeocodeWithGoogle(double lat, double lng) async {
    try {
      final details = await GoogleMapsService.instance.reverseGeocode(lat, lng);
      if (details != null && details.formattedAddress.isNotEmpty) {
        // Build concise, clean location label e.g. "Civil Lines, Kanpur" or "Swaroop Nagar, Kanpur"
        final addr = details.formattedAddress;
        final parts = addr.split(',');
        if (parts.length >= 2) {
          final p0 = parts[0].trim();
          final p1 = parts[1].trim();
          // Filter out generic plus codes like "7MR3+XX"
          if (p0.contains('+')) {
            _locationTitle = '${details.city.isNotEmpty ? details.city : p1}, ${details.state}';
          } else {
            _locationTitle = '$p0, $p1';
          }
        } else {
          _locationTitle = addr;
        }
      } else {
        _locationTitle = 'GPS: ${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}';
      }
    } catch (e) {
      developer.log('Error in Google reverse geocoding: $e');
      _locationTitle = 'GPS: ${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}';
    }
    notifyListeners();
  }

  /// Save location to local disk file so it persists across app restarts
  Future<void> _saveLocationToDisk() async {
    try {
      final data = {
        'lat': _userLat,
        'lng': _userLng,
        'title': _locationTitle,
        'isGps': _isGpsActive,
        'savedAt': DateTime.now().toIso8601String(),
      };
      await _storageFile.writeAsString(jsonEncode(data));
      _hasSavedLocation = true;
      developer.log('Saved location to disk: $_locationTitle ($_userLat, $_userLng)');
    } catch (e) {
      developer.log('Error saving location to disk: $e');
    }
  }

  /// Load location from local disk file
  Future<void> _loadSavedLocationFromDisk() async {
    try {
      if (await _storageFile.exists()) {
        final content = await _storageFile.readAsString();
        if (content.isNotEmpty) {
          final map = jsonDecode(content) as Map<String, dynamic>;
          _userLat = (map['lat'] as num?)?.toDouble() ?? _userLat;
          _userLng = (map['lng'] as num?)?.toDouble() ?? _userLng;
          _locationTitle = map['title'] as String? ?? _locationTitle;
          _isGpsActive = (map['isGps'] as bool?) ?? false;
          _hasSavedLocation = true;
          developer.log('Restored saved location from disk: $_locationTitle ($_userLat, $_userLng)');
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log('Error loading saved location from disk: $e');
    }
  }

  /// Fetch all active salons from Firestore, calculate distance, and sort nearest first
  Future<void> fetchNearbySalonsFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('salons')
          .get();

      final List<SalonModel> parsedSalons = [];

      for (final doc in snap.docs) {
        // Exclude system platform metadata documents
        if (doc.id == 'featured_services_data' ||
            (doc.data()['isSystemDoc'] as bool? ?? false) ||
            doc.data()['isSalon'] == false) {
          continue;
        }

        final data = doc.data();
        final isOpen = (data['isActive'] as bool?) ?? (data['salonStatus'] as bool?) ?? true;
        if (!isOpen) continue; // Only show active salons

        final salon = SalonModel.fromFirestore(
          data: data,
          docId: doc.id,
          userLat: _userLat,
          userLon: _userLng,
        );

        parsedSalons.add(salon);
      }

      // Sort ascending by distance (closest nearest salon first)
      parsedSalons.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      _nearbySalons = parsedSalons;
      notifyListeners();
      developer.log('Fetched ${_nearbySalons.length} real Firestore salons for user at ($_userLat, $_userLng)');
    } catch (e, stack) {
      developer.log('Error fetching salons from Firestore: $e', error: e, stackTrace: stack);
    }
  }
}
