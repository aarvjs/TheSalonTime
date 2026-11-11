import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/role_theme.dart';
import '../data/category_data.dart';
import '../data/home_banner_data.dart';
import '../data/product_data.dart';
import '../data/service_data.dart';
import '../services/customer_location_state.dart';
import '../widgets/category_section.dart';
import '../widgets/customer_drawer.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_service_banner.dart';
import '../widgets/location_picker_modal.dart';
import '../widgets/product_section.dart';
import '../widgets/salon_section.dart';
import '../widgets/service_section.dart';
import '../../salon/screens/customer_salon_details_screen.dart';
import '../models/home_slider_model.dart';
import '../services/home_slider_service.dart';
import '../widgets/featured_services_section.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final themeController = RoleTheme.controllerOf(context);
    final isMale = themeController.mode == AppRoleThemeMode.customerMale;

    final banners = isMale ? HomeBannerData.maleBanners : HomeBannerData.femaleBanners;
    final categories = isMale ? CategoryData.maleCategories : CategoryData.femaleCategories;
    final services = isMale ? ServiceData.maleServices : ServiceData.femaleServices;
    final products = ProductData.femaleProducts;

    final avatarAsset = isMale ? AssetConstants.prefMale : AssetConstants.roleCustomer;

    return ListenableBuilder(
      listenable: CustomerLocationState.instance,
      builder: (context, _) {
        final locationState = CustomerLocationState.instance;
        final nearestSalons = locationState.strictlyNearestSalons;
        final featuredSalons = nearestSalons.length > 2
            ? nearestSalons.skip(1).take(3).toList()
            : const <dynamic>[];

        return Scaffold(
          backgroundColor: colors.background,
          drawer: const CustomerDrawer(),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Top Brand Header with Drawer Hamburger & The Salon Times Design
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Builder(
                        builder: (innerContext) {
                          return HomeHeader(
                            avatarPath: avatarAsset,
                            onMenuTap: () {
                              Scaffold.of(innerContext).openDrawer();
                            },
                            onNotificationTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No new notifications')),
                              );
                            },
                            onProfileTap: () {
                              Scaffold.of(innerContext).openDrawer();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 4),

                      // Location Bar with GPS / City selector modal trigger
                      GestureDetector(
                        onTap: () => LocationPickerModal.show(context),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.location_on_rounded, color: colors.primary, size: 17),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 4,
                                      runSpacing: 2,
                                      children: [
                                        Text(
                                          'DELIVERING & SALONS NEAR',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: colors.textSecondary,
                                            letterSpacing: 0.7,
                                          ),
                                        ),
                                        if (locationState.isGpsActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'GPS LIVE',
                                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      locationState.locationTitle,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Change',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: colors.primary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),

                // 2. Sticky / Static Search Bar (Pins to top when scrolled)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySearchBarDelegate(
                    height: 72,
                    builder: (context, isPinned) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colors.background,
                          boxShadow: isPinned
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: HomeSearchBar(
                          hintText: isMale
                              ? 'Search salons, grooming or services'
                              : 'Search salons, services or products',
                        ),
                      );
                    },
                  ),
                ),

                // 3. Scrollable Main Page Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Promotional Dynamic Banner Slider (Controlled by Super Admin & Filtered by Location)
                        StreamBuilder<List<HomeSliderModel>>(
                          stream: HomeSliderService.instance.streamActiveSliders(),
                          builder: (context, snapshot) {
                            final allDynamicSliders = snapshot.data ?? [];

                            // Filter eligible sliders based on customer's actual coordinates & custom radius
                            final eligibleSliders = HomeSliderService.instance.filterEligibleSliders(
                              sliders: allDynamicSliders,
                              userLat: locationState.userLat,
                              userLng: locationState.userLng,
                              hasSavedLocation: locationState.hasSavedLocation,
                              isGpsActive: locationState.isGpsActive,
                              isSkipped: locationState.isSkipped,
                              registeredSalons: locationState.strictlyNearestSalons,
                            );

                            return HomeBannerSlider(
                              dynamicSliders: eligibleSliders.isNotEmpty ? eligibleSliders : null,
                              banners: eligibleSliders.isEmpty ? banners : null,
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Turn on GPS Banner prompt if location is not GPS active and user skipped or has no saved location
                        if (!locationState.isGpsActive && (!locationState.hasSavedLocation || locationState.isSkipped)) ...[
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.my_location_rounded, color: colors.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    locationState.isSkipped
                                        ? 'Location skipped. Showing all salons. Tap to set your location.'
                                        : 'Enable GPS to see nearest salons with live distance.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => LocationPickerModal.show(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Set Location',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Dynamic Featured Services (Images managed by Super Admin, filtered by location on tap)
                        const FeaturedServicesSection(),
                        const SizedBox(height: 24),

                        // Salons Near You (100% Dynamic from Firebase, sorted by distance)
                        SalonSection(
                          title: 'Salons Near You (पास के सैलून)',
                          salons: nearestSalons,
                          onSalonTap: (salon) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerSalonDetailsScreen(salon: salon),
                              ),
                            );
                          },
                          onSeeAllTap: () {
                            // If navigation shell is present, switch to Explore tab
                          },
                        ),
                        const SizedBox(height: 24),

                        // Grooming Services (Male) vs Beauty Picks & Popular Services (Female)
                        if (isMale) ...[
                          // Popular Grooming Services
                          ServiceSection(
                            title: 'Popular Grooming Services',
                            subtitle: 'Trending grooming services for men',
                            services: services,
                            onSeeAllTap: () {},
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          // Beauty Picks For You
                          ProductSection(
                            products: products,
                            onSeeAllTap: () {},
                          ),
                          const SizedBox(height: 24),
                          // Popular Beauty Services
                          ServiceSection(
                            title: 'Popular Beauty Services',
                            subtitle: 'Top rated pampering services',
                            services: services,
                            onSeeAllTap: () {},
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Home Service Banner
                        HomeServiceBanner(
                          onExploreTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: colors.primary,
                                content: Text(
                                  isMale
                                      ? 'Exploring At-Home Grooming Services...'
                                      : 'Exploring At-Home Beauty Services...',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Featured Salons (Only if multiple salons are registered)
                        if (featuredSalons.isNotEmpty) ...[
                          SalonSection(
                            title: 'Featured Salons in Your City',
                            salons: featuredSalons.cast(),
                            onSalonTap: (salon) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerSalonDetailsScreen(salon: salon),
                                ),
                              );
                            },
                            onSeeAllTap: () {},
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext context, bool isPinned) builder;
  final double height;

  _StickySearchBarDelegate({
    required this.builder,
    this.height = 72.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: builder(context, shrinkOffset > 5),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}
