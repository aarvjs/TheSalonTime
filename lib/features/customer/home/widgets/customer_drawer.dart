import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/role_theme.dart';
import '../../auth/services/customer_auth_service.dart';
import '../../location/services/customer_location_service.dart';
import '../../profile/models/customer_profile_model.dart';
import '../../profile/services/customer_profile_service.dart';

class CustomerDrawer extends StatefulWidget {
  const CustomerDrawer({super.key});

  @override
  State<CustomerDrawer> createState() => _CustomerDrawerState();
}

class _CustomerDrawerState extends State<CustomerDrawer> {
  bool _isRefreshingLocation = false;
  bool _isSwitchingGender = false;

  Future<void> _handleRefreshLocation() async {
    if (_isRefreshingLocation) return;
    setState(() => _isRefreshingLocation = true);

    try {
      await CustomerLocationService.instance.manualRefreshLocation(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            content: Text('Location error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshingLocation = false);
      }
    }
  }

  Future<void> _handleGenderSwitch(String targetGender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isSwitchingGender) return;

    final themeController = RoleTheme.controllerOf(context);
    final targetMode = (targetGender == 'Male')
        ? AppRoleThemeMode.customerMale
        : AppRoleThemeMode.customerFemale;

    if (themeController.mode == targetMode) return;

    setState(() => _isSwitchingGender = true);

    try {
      await CustomerProfileService.instance.updateGender(user.uid, targetGender);
      if (!mounted) return;
      themeController.setThemeMode(targetMode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            content: Text('Could not update style preference: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSwitchingGender = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Are you sure you want to sign out of your account?', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
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
      Navigator.pop(context); // Close drawer
      await CustomerAuthService.instance.signOut();
      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(AppRoutes.chooseRole, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final themeController = RoleTheme.controllerOf(context);
    final isMale = themeController.mode == AppRoleThemeMode.customerMale;
    final defaultAvatar = isMale ? AssetConstants.prefMale : AssetConstants.roleCustomer;
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: colors.background,
      elevation: 16,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Drawer Luxury Header with User Info
            ValueListenableBuilder<CustomerProfileModel?>(
              valueListenable: CustomerProfileService.instance.currentProfileNotifier,
              builder: (context, profile, _) {
                final displayName = (profile != null && profile.displayName.isNotEmpty)
                    ? profile.displayName
                    : (user?.displayName ?? 'Valued Customer');
                final phone = (profile != null && profile.phoneNumber.isNotEmpty)
                    ? profile.phoneNumber
                    : (user?.phoneNumber ?? '+91 ••••• •••••');
                final hasPhoto = profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    border: Border(
                      bottom: BorderSide(color: colors.border.withValues(alpha: 0.6)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Brand Monogram & Close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AssetConstants.leafLogo,
                                width: 22,
                                height: 26,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'THE SALON TIMES',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // User Avatar & Name
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.primary, width: 2),
                              image: hasPhoto
                                  ? DecorationImage(
                                      image: NetworkImage(profile.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: AssetImage(defaultAvatar),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isMale ? '👑 Grooming Member' : '✨ Beauty Member',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // 2. Scrollable Menu Items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  // Location Status Card inside Drawer
                  ValueListenableBuilder<CustomerProfileModel?>(
                    valueListenable: CustomerProfileService.instance.currentProfileNotifier,
                    builder: (context, profile, _) {
                      final hasCoords = profile?.latitude != null && profile?.longitude != null;
                      final coordsText = hasCoords
                          ? '${profile!.latitude!.toStringAsFixed(3)}°, ${profile.longitude!.toStringAsFixed(3)}°'
                          : 'Not synced';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasCoords
                                ? Colors.green.withValues(alpha: 0.3)
                                : colors.border.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: (hasCoords ? Colors.green : colors.primary).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                hasCoords ? Icons.my_location_rounded : Icons.location_on_outlined,
                                color: hasCoords ? Colors.green.shade700 : colors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Device Location',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hasCoords ? 'Coords: $coordsText' : 'Tap to sync for nearby salons',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: hasCoords ? Colors.green.shade700 : colors.textMuted,
                                      fontWeight: hasCoords ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: _handleRefreshLocation,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: _isRefreshingLocation
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                                        ),
                                      )
                                    : Icon(Icons.sync_rounded, size: 20, color: colors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Experience Switcher (Female vs Male)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STYLE EXPERIENCE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: colors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _handleGenderSwitch('Female'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isMale ? AppColors.copper : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: !isMale ? AppColors.copper : colors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.face_3_rounded, size: 15, color: !isMale ? Colors.white : colors.textMuted),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Female',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: !isMale ? FontWeight.bold : FontWeight.w500,
                                          color: !isMale ? Colors.white : colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _handleGenderSwitch('Male'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isMale ? AppColors.deepNavy : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isMale ? AppColors.deepNavy : colors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.face_rounded, size: 15, color: isMale ? Colors.white : colors.textMuted),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Male',
                                        style: TextStyle(
                                          fontSize: 11.5,
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
                  ),

                  // Menu Items
                  _buildDrawerTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile',
                    subtitle: 'Edit details & personal preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.customerProfileSetup);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.calendar_today_rounded,
                    title: 'My Appointments',
                    subtitle: 'Upcoming & past bookings',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.favorite_border_rounded,
                    title: 'Favorite Salons',
                    subtitle: 'Saved stylists & beauty centers',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Offers, alerts & booking updates',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: '24/7 customer care & FAQs',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Terms of service & privacy',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // 3. Drawer Bottom / Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: _handleSignOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.redAccent, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = RoleTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: colors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: colors.textMuted,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, size: 18, color: colors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
