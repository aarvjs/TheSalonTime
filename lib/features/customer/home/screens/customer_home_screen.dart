import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/role_theme.dart';
import '../data/category_data.dart';
import '../data/home_banner_data.dart';
import '../data/product_data.dart';
import '../data/salon_data.dart';
import '../data/service_data.dart';
import '../widgets/category_section.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header & Greeting
              HomeHeader(
                locationName: 'Kanpur',
                greetingText: isMale ? 'Good evening, Arvind' : 'Good evening, Ananya',
                avatarPath: avatarAsset,
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
                onProfileTap: () {},
              ),
              const SizedBox(height: 6),

              // 2. Search Bar
              HomeSearchBar(
                hintText: isMale
                    ? 'Search salons, grooming or services'
                    : 'Search salons, services or products',
              ),
              const SizedBox(height: 16),

              // 3. ONE Promotional Banner Slider
              HomeBannerSlider(banners: banners),
              const SizedBox(height: 24),

              // 4. Explore Categories (Compact circular)
              CategorySection(
                categories: categories,
                onCategorySelected: (cat) {},
              ),
              const SizedBox(height: 24),

              // 5. Salons Near You
              SalonSection(
                title: 'Salons Near You',
                salons: salons,
                onSeeAllTap: () {},
              ),
              const SizedBox(height: 24),

              // 6 & 7. Grooming Services (Male) vs Beauty Picks & Popular Services (Female)
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

              // 8. Home Service Banner
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

              // 9. Featured Salons
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
    );
  }
}
