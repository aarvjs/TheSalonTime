import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../shared/widgets/app_image.dart';
import '../models/home_banner_model.dart';
import '../models/home_slider_model.dart';
import '../services/customer_location_state.dart';
import '../services/home_slider_service.dart';

class HomeBannerCard extends StatelessWidget {
  final HomeBannerModel? banner;
  final HomeSliderModel? slider;
  final VoidCallback? onTap;

  const HomeBannerCard({
    super.key,
    this.banner,
    this.slider,
    this.onTap,
  }) : assert(banner != null || slider != null, 'Either banner or slider must be provided');

  @override
  Widget build(BuildContext context) {
    // 1. Resolve visual fields from slider or fallback banner
    final String title = slider?.title ?? banner?.title ?? '';
    final String description = slider?.subtitle ?? banner?.description ?? '';
    final String ctaText = slider?.buttonText.isNotEmpty == true
        ? slider!.buttonText
        : (banner?.ctaText ?? 'Explore Salon');
    final String imagePath = slider?.imageUrl.isNotEmpty == true
        ? slider!.imageUrl
        : (banner?.imagePath ?? '');

    final Color textColor = banner?.textColor ?? Colors.white;
    final Color accentColor = banner?.accentColor ?? const Color(0xFFD4AF37);
    final List<Color> bgGradientColors = banner?.bgGradientColors ??
        const [
          Color(0xFF0F172A),
          Color(0xFF1B2A47),
        ];

    // Compute distance / small label badge
    String smallLabel = banner?.smallLabel ?? 'EXCLUSIVE OFFER';
    if (slider != null) {
      if (slider!.isGlobal) {
        smallLabel = 'FEATURED PROMO';
      } else {
        final userLat = CustomerLocationState.instance.userLat;
        final userLng = CustomerLocationState.instance.userLng;
        final dist = slider!.distanceKm(userLat, userLng);
        final distText = DistanceCalculator.formatDistance(dist);
        smallLabel = slider!.salonName.isNotEmpty
            ? '$distText • ${slider!.salonName}'
            : distText;
      }
    }

    final VoidCallback clickAction = onTap ??
        () {
          if (slider != null) {
            HomeSliderService.instance.handleSliderClick(context, slider!);
          }
        };

    return GestureDetector(
      onTap: clickAction,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: bgGradientColors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image on the right
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.46,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          bgGradientColors.first,
                          Colors.transparent,
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcATop,
                    child: AppImage(
                      imagePath: imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Text Content on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: MediaQuery.of(context).size.width * 0.40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          smallLabel.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h2(color: textColor).copyWith(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // CTA Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              ctaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
