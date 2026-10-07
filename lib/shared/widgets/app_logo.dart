import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/asset_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  final double scale;
  final bool showLeafMark;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.scale = 1.0,
    this.showLeafMark = true,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLeafMark) ...[
          SvgPicture.asset(
            AssetConstants.leafLogo,
            width: 32 * scale,
            height: 38 * scale,
          ),
          SizedBox(height: 14 * scale),
        ],
        // "The"
        Text(
          'The',
          style: AppTextStyles.logoThe(color: AppColors.warmBlack).copyWith(
            fontSize: 22 * scale,
            fontStyle: FontStyle.normal,
            letterSpacing: 0.5,
          ),
        ),
        // "Salon"
        Text(
          'Salon',
          style: AppTextStyles.logoSalon(color: AppColors.warmBlack).copyWith(
            fontSize: 48 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0 * scale,
            height: 1.0,
          ),
        ),
        // "Times"
        Text(
          'Times',
          style: AppTextStyles.logoTimes(color: AppColors.warmBlack).copyWith(
            fontSize: 24 * scale,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            letterSpacing: 1.5 * scale,
            height: 1.0,
          ),
        ),
        if (showTagline) ...[
          SizedBox(height: 18 * scale),
          Text(
            'BEAUTY • GROOMING • WELLNESS',
            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
              fontSize: 9 * scale,
              letterSpacing: 2.8 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
