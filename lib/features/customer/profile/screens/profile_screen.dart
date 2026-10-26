import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/role_theme.dart';
import '../../auth/services/customer_auth_service.dart';
import '../../location/services/customer_location_service.dart';
import '../models/customer_profile_model.dart';
import '../services/customer_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdatingGender = false;
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await CustomerProfileService.instance.getCustomerProfile(user.uid);
    }
  }

  Future<void> _handleGenderSwitch(String targetGender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isUpdatingGender) return;

    final themeController = RoleTheme.controllerOf(context);
    final previousMode = themeController.mode;
    final targetMode = (targetGender == 'Male')
        ? AppRoleThemeMode.customerMale
        : AppRoleThemeMode.customerFemale;

    if (previousMode == targetMode) return;

    setState(() {
      _isUpdatingGender = true;
    });

    try {
      // 1. Safe update: modifies ONLY the `gender` field in Firestore
      await CustomerProfileService.instance.updateGender(user.uid, targetGender);

      if (!mounted) return;

      // 2. Immediately update the app's current theme & feature configuration
      themeController.setThemeMode(targetMode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: targetGender == 'Male' ? AppColors.deepNavy : AppColors.copper,
          duration: const Duration(seconds: 2),
          content: Text(
            targetGender == 'Male'
                ? 'Switched to Male Grooming experience'
                : 'Switched to Female Beauty & Wellness experience',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // 3. Restore previous selection on failure instead of displaying false success
      themeController.setThemeMode(previousMode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: Text('Failed to update gender preference: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingGender = false;
        });
      }
    }
  }

  Future<void> _handleManualLocationRefresh() async {
    if (_isUpdatingLocation) return;
    setState(() => _isUpdatingLocation = true);

    try {
      await CustomerLocationService.instance.manualRefreshLocation(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            content: Text('Could not refresh location: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingLocation = false);
      }
    }
  }

  Future<void> _confirmLogout() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await CustomerAuthService.instance.signOut();
      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.chooseRole,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final themeController = RoleTheme.controllerOf(context);
    final isMale = themeController.mode == AppRoleThemeMode.customerMale;
    final avatarAsset = isMale ? AssetConstants.prefMale : AssetConstants.roleCustomer;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ValueListenableBuilder<CustomerProfileModel?>(
          valueListenable: CustomerProfileService.instance.currentProfileNotifier,
          builder: (context, profile, _) {
            final displayName = (profile != null && profile.displayName.isNotEmpty)
                ? profile.displayName
                : (user?.displayName ?? 'Valued Customer');

            final phone = (profile != null && profile.phoneNumber.isNotEmpty)
                ? profile.phoneNumber
                : (user?.phoneNumber ?? '+91 ••••• •••••');

            final hasCustomPhoto = profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty;
            final isProfileIncomplete = profile == null || !profile.profileCompleted;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.primary, width: 2),
                                image: hasCustomPhoto
                                    ? DecorationImage(
                                        image: NetworkImage(profile.photoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: AssetImage(avatarAsset),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isMale ? '👑 Premium Grooming Member' : '✨ Premium Beauty Member',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Incomplete Profile Banner / Edit Profile CTA
                        if (isProfileIncomplete) ...[
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.customerProfileSetup);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 18, color: colors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Complete profile to unlock personalized perks',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: colors.primary),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.customerProfileSetup);
                              },
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menu List Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'EXPERIENCE & PREFERENCES'),
                        const SizedBox(height: 10),

                        // Interactive Gender Switcher Card (Male vs Female)
                        _buildGenderSwitchCard(context, colors, isMale),
                        const SizedBox(height: 10),

                        // Device Location Status & Refresh Item
                        _buildLocationItem(context, colors, profile),
                        const SizedBox(height: 10),

                        _buildMenuItem(
                          context,
                          icon: Icons.notifications_none_rounded,
                          title: 'Notification Settings',
                          subtitle: 'Appointment alerts and promotions',
                        ),

                        const SizedBox(height: 18),
                        _buildSectionHeader(context, 'BOOKINGS & SAVED'),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context,
                          icon: Icons.calendar_today_rounded,
                          title: 'My Appointments',
                          subtitle: 'View upcoming and past appointments',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite_border_rounded,
                          title: 'Saved Salons',
                          subtitle: 'Your favorite salons and stylists',
                        ),

                        const SizedBox(height: 18),
                        _buildSectionHeader(context, 'SUPPORT & LEGAL'),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline_rounded,
                          title: 'Help Center',
                          subtitle: 'FAQs and 24/7 customer support',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'How we protect your salon data',
                        ),

                        const SizedBox(height: 20),

                        // Sign Out Button
                        GestureDetector(
                          onTap: _confirmLogout,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Interactive Gender Switcher Card allowing immediate toggle between Female Beauty and Male Grooming
  Widget _buildGenderSwitchCard(BuildContext context, dynamic colors, bool isMale) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_outlined, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Experience Preference',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_isUpdatingGender)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isMale ? 'Male Grooming' : 'Female Beauty',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Segmented Switch Options
          Row(
            children: [
              // 1. Female Option
              Expanded(
                child: GestureDetector(
                  onTap: _isUpdatingGender ? null : () => _handleGenderSwitch('Female'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isMale ? AppColors.copper : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !isMale ? AppColors.copper : colors.border,
                        width: !isMale ? 1.5 : 1.0,
                      ),
                      boxShadow: !isMale
                          ? [
                              BoxShadow(
                                color: AppColors.copper.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.face_3_rounded,
                          size: 18,
                          color: !isMale ? Colors.white : colors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Female Beauty',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: !isMale ? FontWeight.bold : FontWeight.w500,
                            color: !isMale ? Colors.white : colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 2. Male Option
              Expanded(
                child: GestureDetector(
                  onTap: _isUpdatingGender ? null : () => _handleGenderSwitch('Male'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isMale ? AppColors.deepNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMale ? AppColors.deepNavy : colors.border,
                        width: isMale ? 1.5 : 1.0,
                      ),
                      boxShadow: isMale
                          ? [
                              BoxShadow(
                                color: AppColors.deepNavy.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.face_rounded,
                          size: 18,
                          color: isMale ? Colors.white : colors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Male Grooming',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isMale ? FontWeight.bold : FontWeight.w500,
                            color: isMale ? Colors.white : colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Location item showing coordinates or permission status, with manual refresh/retry capability
  Widget _buildLocationItem(
    BuildContext context,
    dynamic colors,
    CustomerProfileModel? profile,
  ) {
    final hasCoords = profile?.latitude != null && profile?.longitude != null;
    final status = profile?.locationPermissionStatus;

    String subtitleText;
    if (hasCoords) {
      subtitleText =
          'Saved: ${profile!.latitude!.toStringAsFixed(3)}°, ${profile.longitude!.toStringAsFixed(3)}° • Tap to refresh';
    } else if (status == 'denied_forever') {
      subtitleText = 'Permission disabled in settings • Tap to open settings';
    } else if (status == 'denied' || status == 'denied_by_user') {
      subtitleText = 'Permission not granted • Tap to retry for nearby salons';
    } else if (status == 'service_disabled') {
      subtitleText = 'GPS service disabled • Tap to enable in settings';
    } else {
      subtitleText = 'Enable device location to find nearby salons';
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        onTap: _handleManualLocationRefresh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (hasCoords ? Colors.green : colors.primary).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasCoords ? Icons.my_location_rounded : Icons.location_on_outlined,
            color: hasCoords ? Colors.green.shade700 : colors.primary,
            size: 20,
          ),
        ),
        title: Text(
          'Current Device Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: TextStyle(
            fontSize: 12,
            color: hasCoords ? Colors.green.shade700 : colors.textMuted,
            fontWeight: hasCoords ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: _isUpdatingLocation
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              )
            : Icon(
                hasCoords ? Icons.refresh_rounded : Icons.chevron_right_rounded,
                color: colors.textMuted,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = RoleTheme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: colors.textMuted,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final colors = RoleTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title tapped')),
              );
            },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colors.textMuted,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}
