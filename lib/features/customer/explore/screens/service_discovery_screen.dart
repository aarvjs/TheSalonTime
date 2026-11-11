import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../home/models/featured_service_model.dart';
import '../../home/models/salon_model.dart';
import '../../home/services/customer_location_state.dart';
import '../../home/services/featured_service_service.dart';
import '../../home/widgets/location_picker_modal.dart';
import '../../home/widgets/salon_card.dart';
import '../../salon/screens/customer_salon_details_screen.dart';

class ServiceDiscoveryScreen extends StatefulWidget {
  final FeaturedServiceModel featuredService;

  const ServiceDiscoveryScreen({
    super.key,
    required this.featuredService,
  });

  @override
  State<ServiceDiscoveryScreen> createState() => _ServiceDiscoveryScreenState();
}

class _ServiceDiscoveryScreenState extends State<ServiceDiscoveryScreen> {
  bool _isLoading = true;
  List<SalonModel> _matchingSalons = [];

  @override
  void initState() {
    super.initState();
    _filterSalonsForService();
  }

  Future<void> _filterSalonsForService() async {
    setState(() => _isLoading = true);

    final locState = CustomerLocationState.instance;
    final allSalons = locState.strictlyNearestSalons;
    final userLat = locState.userLat;
    final userLng = locState.userLng;

    final List<SalonModel> eligible = [];

    for (final salon in allSalons) {
      // 1. Must be active/open
      if (!salon.isOpen) continue;

      // 2. Haversine distance from customer coordinates
      final distKm = DistanceCalculator.haversineDistanceKm(
        lat1: userLat,
        lon1: userLng,
        lat2: salon.latitude,
        lon2: salon.longitude,
      );

      // 3. Must be within the salon's configured service radius
      final radiusKm = salon.serviceRadiusKm > 0 ? salon.serviceRadiusKm : 10.0;
      if (distKm > radiusKm) {
        continue;
      }

      // 4. Must actually offer the selected featured service
      final offersService = await FeaturedServiceService.instance.doesSalonOfferService(
        salon: salon,
        featuredService: widget.featuredService,
      );

      if (offersService) {
        eligible.add(salon.copyWith(
          distance: DistanceCalculator.formatDistance(distKm),
          distanceKm: distKm,
        ));
      }
    }

    // Sort closest nearest salon first
    eligible.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (mounted) {
      setState(() {
        _matchingSalons = eligible;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final locState = CustomerLocationState.instance;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.featuredService.name} Salons',
              style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 11, color: colors.primary),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    'Near ${locState.locationTitle}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location_rounded, color: colors.primary, size: 20),
            tooltip: 'Change Location',
            onPressed: () async {
              await LocationPickerModal.show(context);
              if (mounted) _filterSalonsForService();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Promotional Banner Strip for the Featured Service
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                border: Border(
                  bottom: BorderSide(color: colors.primary.withValues(alpha: 0.15)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(widget.featuredService.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.featuredService.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.featuredService.description.isNotEmpty
                              ? widget.featuredService.description
                              : 'Discover premium verified salons offering ${widget.featuredService.name}.',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      '${_matchingSalons.length} available',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Salons List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.primary,
                      ),
                    )
                  : _matchingSalons.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.storefront_outlined,
                                    size: 32,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Salons Offering "${widget.featuredService.name}" Near You',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No verified salon within your location radius currently has this service listed. Try changing your location or checking back soon.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.my_location_rounded, size: 16),
                                  label: const Text('Change Location', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    await LocationPickerModal.show(context);
                                    if (mounted) _filterSalonsForService();
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: _matchingSalons.length,
                          itemBuilder: (context, index) {
                            final salon = _matchingSalons[index];
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
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
