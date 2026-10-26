import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/role_theme.dart';
import '../data/category_data.dart';
import '../data/home_banner_data.dart';
import '../data/product_data.dart';
import '../data/salon_data.dart';
import '../data/service_data.dart';
import '../widgets/category_section.dart';
import '../widgets/customer_drawer.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_service_banner.dart';
import '../widgets/product_section.dart';
import '../widgets/salon_section.dart';
import '../widgets/service_section.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final themeController = RoleTheme.controllerOf(context);
    final isMale = themeController.mode == AppRoleThemeMode.customerMale;

    final banners = isMale ? HomeBannerData.maleBanners : HomeBannerData.femaleBanners;
    final categories = isMale ? CategoryData.maleCategories : CategoryData.femaleCategories;
    final salons = isMale ? SalonData.maleSalons : SalonData.femaleSalons;
    final featuredSalons = isMale ? SalonData.featuredMaleSalons : SalonData.featuredFemaleSalons;
    final services = isMale ? ServiceData.maleServices : ServiceData.femaleServices;
    final products = ProductData.femaleProducts;

    final avatarAsset = isMale ? AssetConstants.prefMale : AssetConstants.roleCustomer;

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

                    // Promotional Banner Slider
                    HomeBannerSlider(banners: banners),
                    const SizedBox(height: 24),

                    // Explore Categories (Compact circular)
                    CategorySection(
                      categories: categories,
                      onCategorySelected: (cat) {},
                    ),
                    const SizedBox(height: 24),

                    // Salons Near You
                    SalonSection(
                      title: 'Salons Near You',
                      salons: salons,
                      onSeeAllTap: () {},
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

                    // Featured Salons
                    SalonSection(
                      title: 'Featured Salons',
                      salons: featuredSalons,
                      onSeeAllTap: () {},
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
