import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/role_theme.dart';

class HomeHeader extends StatelessWidget {
  final String avatarPath;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    required this.avatarPath,
    this.onMenuTap,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Drawer Hamburger Button + "The Salon Times" Branding
          Expanded(
            child: Row(
              children: [
                // 1. Drawer Hamburger Menu Button
                GestureDetector(
                  onTap: onMenuTap,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: colors.border, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_rounded,
                        color: colors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Leaf Monogram Logo + "The Salon Times" Name Design
                SvgPicture.asset(
                  AssetConstants.leafLogo,
                  width: 24,
                  height: 30,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'THE SALON TIMES',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'PREMIUM BEAUTY & GROOMING',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right: Notification Bell & Profile Avatar
          Row(
            children: [
              // Notification Button
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: colors.textPrimary,
                        size: 22,
                      ),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Profile Avatar Button
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.secondary, width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: colors.secondary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: Image.asset(
                      avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colors.surface,
                          child: Icon(Icons.person, color: colors.primary),
                        );
                      },
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
}
