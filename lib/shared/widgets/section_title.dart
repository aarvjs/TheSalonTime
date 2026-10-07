import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/asset_constants.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/role_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSeparator;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.showSeparator = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.h1(color: colors.textPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimensions.xs),
          Text(
            subtitle!,
            style: AppTextStyles.subtitle(color: colors.textSecondary),
          ),
        ],
        if (showSeparator) ...[
          const SizedBox(height: AppDimensions.sm),
          SvgPicture.asset(
            AssetConstants.separator,
            width: 120,
          ),
        ],
      ],
    );
  }
}
