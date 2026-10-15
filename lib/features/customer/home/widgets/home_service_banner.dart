import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';

class HomeServiceBanner extends StatelessWidget {
  final bool? isMale;
  final VoidCallback? onExploreTap;

  const HomeServiceBanner({
    super.key,
    this.isMale,
    this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final themeController = RoleTheme.controllerOf(context);
    final isMaleMode = isMale ?? (themeController.mode == AppRoleThemeMode.customerMale);

    final tag = isMaleMode ? 'GROOMING AT HOME' : 'BEAUTY AT YOUR DOORSTEP';
    final title = isMaleMode ? 'Grooming at Your Doorstep' : 'Beauty at Your Doorstep';
    final description = isMaleMode
        ? 'Professional grooming services delivered right to your home.'
        : 'Professional beauty services from the comfort of your home.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    Icon(Icons.home_work_rounded, size: 15, color: colors.primary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle(color: colors.textSecondary).copyWith(
                    fontSize: 11.5,
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
            width: 75,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                isMaleMode ? AssetConstants.onboarding2 : AssetConstants.onboarding3,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
