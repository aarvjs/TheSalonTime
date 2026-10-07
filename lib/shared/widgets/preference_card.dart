import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class PreferenceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final bool isSelected;
  final Color activeAccentColor;
  final Color activeCardBg;
  final VoidCallback onTap;

  const PreferenceCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
    required this.isSelected,
    required this.activeAccentColor,
    required this.activeCardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: isSelected ? activeCardBg : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isSelected ? activeAccentColor : const Color(0xFFE6E1DA),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? activeAccentColor.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 16 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeAccentColor.withValues(alpha: 0.15)
                        : const Color(0xFFF9F6F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 26,
                    color: isSelected ? activeAccentColor : const Color(0xFF7A7571),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3(
                          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF2C2C2C),
                        ).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTextStyles.caption(
                          color: const Color(0xFF7A7571),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? activeAccentColor : const Color(0xFFE6E1DA),
                      width: isSelected ? 7 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
