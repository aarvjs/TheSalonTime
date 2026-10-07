import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/role_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final bg = backgroundColor ?? colors.primary;
    final fg = textColor ?? colors.buttonText;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: isOutlined || onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutlined ? Colors.transparent : bg,
            foregroundColor: isOutlined ? bg : fg,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              side: isOutlined
                  ? BorderSide(color: bg, width: 1.5)
                  : BorderSide.none,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined ? bg : fg,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: AppTextStyles.button(
                        color: isOutlined ? bg : fg,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: AppDimensions.sm),
                      Icon(icon, size: 18, color: isOutlined ? bg : fg),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
