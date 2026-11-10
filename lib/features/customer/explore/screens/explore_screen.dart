import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../partner/models/partner_models.dart' hide SalonModel;
import '../../../partner/services/partner_firestore_service.dart';
import '../../home/models/salon_model.dart';
import '../../home/services/customer_location_state.dart';
import '../../home/widgets/home_search_bar.dart';
import '../../home/widgets/location_picker_modal.dart';
import '../../home/widgets/salon_card.dart';
import '../../salon/screens/customer_salon_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = const ['All Nearest', 'Salons', 'Home Services', 'Top Rated'];

  List<HomeServiceProfileModel> _homeProviders = [];
  bool _isLoadingHome = false;

  @override
  void initState() {
    super.initState();
    _fetchHomeProviders();
  }

  Future<void> _fetchHomeProviders() async {
    setState(() => _isLoadingHome = true);
    try {
      final providers = await PartnerFirestoreService.instance.fetchActiveHomeServiceProviders();
      if (mounted) setState(() => _homeProviders = providers);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingHome = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return ListenableBuilder(
      listenable: CustomerLocationState.instance,
      builder: (context, _) {
        final locState = CustomerLocationState.instance;
        final rawSalons = locState.nearbySalons;

        // Apply filter chips
        List<SalonModel> displayedSalons = List.from(rawSalons);
        if (_selectedFilterIndex == 1) {
          // Salons only
          displayedSalons = rawSalons.where((s) => s.isOpen).toList();
        } else if (_selectedFilterIndex == 3) {
          // Top Rated
          displayedSalons = List.from(rawSalons)
            ..sort((a, b) => b.rating.compareTo(a.rating));
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header & Current Location Status
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => LocationPickerModal.show(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore Nearest',
                                  style: AppTextStyles.h1(color: colors.textPrimary).copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 13, color: colors.primary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        locState.locationTitle,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: colors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: colors.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => LocationPickerModal.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.my_location_rounded,
                                  size: 14,
                                  color: locState.isGpsActive ? Colors.green : colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  locState.isGpsActive ? 'GPS Live' : 'Change Location',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: locState.isGpsActive ? Colors.green : colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  const HomeSearchBar(
                    hintText: 'Search nearest salons, treatments or experts...',
                  ),

                  // Filter Chips
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilterIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary : colors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.border,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _filters[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : colors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Content View (Salons vs Home Service Providers)
                  Expanded(
                    child: _selectedFilterIndex == 2
                        ? _buildHomeServiceDiscoveryView(colors, locState)
                        : (displayedSalons.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.storefront_outlined, size: 48, color: colors.textMuted),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No salons found near ${locState.locationTitle}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Try changing your location or expanding search radius.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                      ),
                                      const SizedBox(height: 14),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        icon: const Icon(Icons.my_location_rounded, size: 16),
                                        label: const Text('Change Location'),
                                        onPressed: () => LocationPickerModal.show(context),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: displayedSalons.length,
                                itemBuilder: (context, index) {
                                  final salon = displayedSalons[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SalonCard(
                                      salon: salon,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CustomerSalonDetailsScreen(salon: salon),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeServiceDiscoveryView(AppColorsData colors, CustomerLocationState locState) {
    if (_isLoadingHome) {
      return const Center(child: CircularProgressIndicator(color: AppColors.copper));
    }

    // Filter providers whose radius covers customer coordinates
    final matchingProviders = _homeProviders.where((p) {
      final distKm = DistanceCalculator.haversineDistanceKm(
        lat1: locState.userLat,
        lon1: locState.userLng,
        lat2: p.latitude,
        lon2: p.longitude,
      );
      return distKm <= p.serviceRadiusKm;
    }).toList();

    if (matchingProviders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded, size: 44, color: AppColors.mutedTextGray),
              const SizedBox(height: 12),
              Text(
                'No Home Service Experts in Immediate Radius',
                style: AppTextStyles.h2(color: colors.textPrimary).copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Expand search or book appointments directly at the nearest salon branches.',
                style: AppTextStyles.caption(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.location_on_rounded, size: 16),
                label: const Text('Change Location'),
                onPressed: () => LocationPickerModal.show(context),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: matchingProviders.length,
      itemBuilder: (context, index) {
        final p = matchingProviders[index];
        final distKm = DistanceCalculator.haversineDistanceKm(
          lat1: locState.userLat,
          lon1: locState.userLng,
          lat2: p.latitude,
          lon2: p.longitude,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.person, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.professionalName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.textPrimary),
                        ),
                        Text(
                          '${DistanceCalculator.formatDistance(distKm)} • Within ${p.serviceRadiusKm.toStringAsFixed(0)} km radius',
                          style: TextStyle(fontSize: 11, color: colors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
