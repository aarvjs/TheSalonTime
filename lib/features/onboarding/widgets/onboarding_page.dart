import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/page_indicator.dart';
import '../models/onboarding_model.dart';
import 'onboarding_image.dart';
import 'onboarding_next_button.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const OnboardingPage({
    super.key,
    required this.model,
    required this.pageIndex,
    required this.totalPages,
    required this.onNext,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = pageIndex == totalPages - 1;

    return Stack(
      children: [
        // Upper Photo Area
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 240,
          child: OnboardingImage(
            imagePath: model.imagePath,
            showBackButton: pageIndex > 0,
            onBack: onBack,
            onSkip: onSkip,
            isLastPage: isLastPage,
          ),
        ),
        // Bottom Curved Content Container
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 310,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Wave curve top edge
              Positioned(
                top: -55,
                left: 0,
                right: 0,
                height: 60,
                child: CustomPaint(
                  painter: WaveCurvePainter(color: AppColors.warmIvory),
                ),
              ),
              // Main content body
              Container(
                color: AppColors.warmIvory,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leaf Watermark
                    Align(
                      alignment: Alignment.topRight,
                      child: Opacity(
                        opacity: 0.15,
                        child: SvgPicture.asset(
                          AssetConstants.leafLogo,
                          width: 36,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Title Heading
                    Text(
                      model.title,
                      style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                        fontSize: 28,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle Description
                    Text(
                      model.description,
                      style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const Spacer(),
                    // Bottom Row: Page Indicator (Left) & Next/Get Started Button (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PageIndicator(
                          count: totalPages,
                          currentIndex: pageIndex,
                        ),
                        OnboardingNextButton(
                          isLastPage: isLastPage,
                          onPressed: onNext,
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WaveCurvePainter extends CustomPainter {
  final Color color;

  WaveCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.45);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.05,
      size.width * 0.65,
      size.height * 0.85,
      size.width,
      size.height * 0.35,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveCurvePainter oldDelegate) =>
      oldDelegate.color != color;
}
