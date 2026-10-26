import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../profile/services/customer_profile_service.dart';

class CustomerLocationService {
  CustomerLocationService._();
  static final CustomerLocationService instance = CustomerLocationService._();

  /// Flag to ensure we don't repeatedly show the prompt on screen rebuilds during a single app session
  bool hasPromptedInSession = false;

  /// Check and prompt for customer location after login
  /// If [forceManual] is true (e.g. user clicked in Profile), will always prompt regardless of session flag
  Future<void> checkAndPromptLocation(
    BuildContext context, {
    bool forceManual = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Do not request location before login
      return;
    }

    if (!forceManual && hasPromptedInSession) {
      // Avoid prompting repeatedly on every rebuild or tab switch
      return;
    }

    hasPromptedInSession = true;

    try {
      // Check existing permission first
      LocationPermission permission = await Geolocator.checkPermission();

      // Case 1: Permission is ALREADY granted from previous login
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Refresh coordinates silently without showing any dialog
        await refreshLocationSilently(user.uid);
        return;
      }

      // Case 2: Permission is permanently denied
      if (permission == LocationPermission.deniedForever) {
        if (forceManual && context.mounted) {
          _showPermanentlyDeniedDialog(context);
        }
        await CustomerProfileService.instance.updateLocationPermissionStatus(
          user.uid,
          'deniedForever',
        );
        return;
      }

      // Case 3: Need to prompt the user with short, clear explanation
      if (!context.mounted) return;

      final userAgreed = await _showLocationRationaleSheet(context);
      if (userAgreed != true) {
        // User tapped "Not Now" / dismissed
        await CustomerProfileService.instance.updateLocationPermissionStatus(
          user.uid,
          'denied',
        );
        return;
      }

      // User agreed to share location -> verify location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          _showServiceDisabledDialog(context);
        }
        await CustomerProfileService.instance.updateLocationPermissionStatus(
          user.uid,
          'unknown',
        );
        return;
      }

      // Request native permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        await CustomerProfileService.instance.updateLocationPermissionStatus(
          user.uid,
          'denied',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Location permission was denied. You can enable it anytime from your Profile.',
              ),
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        await CustomerProfileService.instance.updateLocationPermissionStatus(
          user.uid,
          'deniedForever',
        );
        if (context.mounted) {
          _showPermanentlyDeniedDialog(context);
        }
        return;
      }

      // Permission granted: retrieve current coordinates
      if ((permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) &&
          context.mounted) {
        await _fetchAndSaveCurrentPosition(context, user.uid);
      }
    } catch (e, stack) {
      developer.log('Error handling location request: $e',
          error: e, stackTrace: stack);
    }
  }

  /// Silently retrieves and refreshes location coordinates in Firestore
  Future<Position?> refreshLocationSilently(String uid) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      await CustomerProfileService.instance.updateLocation(
        uid,
        latitude: position.latitude,
        longitude: position.longitude,
        status: 'granted',
      );

      return position;
    } catch (e, stack) {
      developer.log('Silent location refresh failed: $e',
          error: e, stackTrace: stack);
      return null;
    }
  }

  /// Manual refresh triggered from Profile or Settings
  Future<bool> manualRefreshLocation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) _showServiceDisabledDialog(context);
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) _showPermanentlyDeniedDialog(context);
        return false;
      }

      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Location permission is required to find nearby salons.'),
            ),
          );
        }
        return false;
      }

      if (!context.mounted) return false;
      return await _fetchAndSaveCurrentPosition(context, user.uid);
    } catch (e) {
      developer.log('manualRefreshLocation error: $e');
      if (context.mounted) {
        final isMissingPlugin = e.toString().contains('MissingPluginException');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
            content: Text(
              isMissingPlugin
                  ? 'Location plugin requires full app restart. In terminal press "q" and run "flutter run".'
                  : 'Location error: $e',
            ),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> _fetchAndSaveCurrentPosition(
      BuildContext context, String uid) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      await CustomerProfileService.instance.updateLocation(
        uid,
        latitude: position.latitude,
        longitude: position.longitude,
        status: 'granted',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade800,
            content: Text(
              'Location updated (${position.latitude.toStringAsFixed(3)}°, ${position.longitude.toStringAsFixed(3)}°)',
            ),
          ),
        );
      }
      return true;
    } catch (e) {
      developer.log('Error obtaining current position: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Could not get device location. Please ensure GPS is active and retry.',
            ),
          ),
        );
      }
      return false;
    }
  }

  /// Short, elegant rationale modal bottom sheet explaining why location is requested
  Future<bool?> _showLocationRationaleSheet(BuildContext context) {
    final colors = RoleTheme.of(context);

    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull handle
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Icon Badge
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 36,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Find Nearby Salons',
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Explanation
                Text(
                  'The Salon Times uses your device location to discover premium salons, top-rated stylists, and exclusive packages closest to you.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Share Current Location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Not Now',
                    style: TextStyle(
                      color: AppColors.mutedTextGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showServiceDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Device GPS or Location Services are turned off. Please turn them on in your settings to view nearby salons.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Location Permission Needed'),
        content: const Text(
          'Location access is permanently disabled for The Salon Times. Please enable location permission in your device App Settings to explore salons near you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    );
  }
}
