import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/role_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final themeController = RoleTheme.controllerOf(context);
    final isMale = themeController.mode == AppRoleThemeMode.customerMale;
    final avatarAsset = isMale ? AssetConstants.prefMale : AssetConstants.roleCustomer;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary, width: 2),
                        image: DecorationImage(
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
                            isMale ? 'Arvind Sharma' : 'Ananya Roy',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+91 98765 43210',
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
              ),

              // Menu Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'ACCOUNT'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'My Profile',
                      subtitle: 'Personal details & preference',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'My Addresses',
                      subtitle: 'Saved homes & offices',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.payment_rounded,
                      title: 'Payment Methods',
                      subtitle: 'UPI, Cards & Wallets',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Offers & booking updates',
                    ),

                    const SizedBox(height: 16),
                    _buildSectionHeader(context, 'SAVED & ACTIVITY'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.bookmark_outline_rounded,
                      title: 'Saved Salons',
                      subtitle: 'Your favorite parlors & stylists',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.star_outline_rounded,
                      title: 'My Reviews',
                      subtitle: 'Ratings & feedback given',
                    ),

                    const SizedBox(height: 16),
                    _buildSectionHeader(context, 'PREFERENCES & HELP'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: isMale ? Icons.female_rounded : Icons.male_rounded,
                      title: 'Switch Style Mode',
                      subtitle: isMale ? 'Current: Male Grooming' : 'Current: Female Beauty',
                      onTap: () {
                        themeController.setThemeMode(
                          isMale
                              ? AppRoleThemeMode.customerFemale
                              : AppRoleThemeMode.customerMale,
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs & customer assistance',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences & security',
                    ),

                    const SizedBox(height: 16),
                    // Logout tile
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/choose-role',
                          (route) => false,
                        );
                      },
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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                            const Icon(
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
