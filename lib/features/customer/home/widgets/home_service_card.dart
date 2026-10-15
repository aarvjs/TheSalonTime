import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';

class HomeServiceCard extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const HomeServiceCard({
    super.key,
    this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.home_work_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'HOME SERVICE AVAILABLE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Beauty at Your Doorstep',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enjoy professional salon services from the comfort of your home.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle(color: colors.textSecondary).copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                AppButton(
                  text: 'Explore Home Service',
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: colors.primary,
                  onPressed: onExploreTap ?? () {},
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Illustration Image
          Container(
            width: 80,
            height: 95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                AssetConstants.onboarding3,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
