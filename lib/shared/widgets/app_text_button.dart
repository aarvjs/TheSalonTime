import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/role_theme.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isBold;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final buttonColor = color ?? colors.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: AppTextStyles.textButton(color: buttonColor).copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }
}
