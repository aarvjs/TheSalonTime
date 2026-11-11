import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../explore/screens/service_discovery_screen.dart';
import '../models/featured_service_model.dart';
import '../services/featured_service_service.dart';

class FeaturedServicesSection extends StatefulWidget {
  final ValueChanged<FeaturedServiceModel>? onServiceSelected;

  const FeaturedServicesSection({
    super.key,
    this.onServiceSelected,
  });

  @override
  State<FeaturedServicesSection> createState() => _FeaturedServicesSectionState();
}

class _FeaturedServicesSectionState extends State<FeaturedServicesSection> {
  late final Stream<List<FeaturedServiceModel>> _servicesStream;

  @override
  void initState() {
    super.initState();
    _servicesStream = FeaturedServiceService.instance.streamActiveFeaturedServices();
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return StreamBuilder<List<FeaturedServiceModel>>(
      stream: _servicesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return _buildLoadingSkeleton(colors);
        }

        final services = snapshot.data ?? FeaturedServiceService.defaultFeaturedServices;

        if (services.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Services',
                    style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tap to discover',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 104,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(context, service, colors);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    FeaturedServiceModel service,
    AppColorsData colors,
  ) {
    return GestureDetector(
      onTap: () {
        if (widget.onServiceSelected != null) {
          widget.onServiceSelected!(service);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDiscoveryScreen(featuredService: service),
            ),
          );
        }
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rounded Premium Image Card
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      imagePath: service.imageUrl.trim().isNotEmpty
                          ? service.imageUrl.trim()
                          : 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                    ),
                    // Subtle vignette overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Service Name
            Text(
              service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(AppColorsData colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 140,
            height: 18,
            decoration: BoxDecoration(
              color: colors.border.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 72,
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.border.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.border.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

