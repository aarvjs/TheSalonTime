import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../partner/models/partner_models.dart' show SalonServiceModel;
import '../../home/models/salon_model.dart';
import '../widgets/customer_booking_modal.dart';

class CustomerSalonDetailsScreen extends StatefulWidget {
  final SalonModel salon;

  const CustomerSalonDetailsScreen({super.key, required this.salon});

  @override
  State<CustomerSalonDetailsScreen> createState() => _CustomerSalonDetailsScreenState();
}

class _CustomerSalonDetailsScreenState extends State<CustomerSalonDetailsScreen> {
  late SalonModel _salon;
  List<SalonServiceModel> _services = [];
  final Set<String> _selectedServiceIds = {};
  bool _isLoadingServices = true;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Hair', 'Beard', 'Facial', 'Spa', 'Treatment'];

  @override
  void initState() {
    super.initState();
    _salon = widget.salon;
    _fetchSalonServices();
  }

  Future<void> _fetchSalonServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('salons').doc(_salon.id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawServices = data['services'];
        if (rawServices is List && rawServices.isNotEmpty) {
          final List<SalonServiceModel> loaded = [];
          for (final s in rawServices) {
            if (s is Map<String, dynamic>) {
              loaded.add(SalonServiceModel(
                id: s['id'] ?? 'srv_${DateTime.now().millisecondsSinceEpoch}',
                name: s['name'] ?? 'Salon Service',
                category: s['category'] ?? 'Hair',
                description: s['description'] ?? '',
                durationMinutes: (s['durationMinutes'] as num?)?.toInt() ?? 30,
                price: (s['price'] as num?)?.toDouble() ?? 299.0,
                availableAtSalon: s['availableAtSalon'] ?? true,
                availableAtHome: s['availableAtHome'] ?? false,
              ));
            }
          }
          if (loaded.isNotEmpty && mounted) {
            setState(() {
              _services = loaded;
              _isLoadingServices = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      developer.log('Error fetching salon services: $e');
    }

    // Fallback standard catalogue if salon hasn't added custom services yet
    if (mounted) {
      setState(() {
        _services = _buildDefaultServices();
        _isLoadingServices = false;
      });
    }
  }

  List<SalonServiceModel> _buildDefaultServices() {
    return [
      const SalonServiceModel(
        id: 'srv_hc',
        name: 'Classic Haircut & Hair Wash',
        category: 'Hair',
        description: 'Precision haircut with head wash, blowdry and styling',
        durationMinutes: 40,
        price: 349.0,
        availableAtSalon: true,
        availableAtHome: true,
      ),
      const SalonServiceModel(
        id: 'srv_bt',
        name: 'Beard Grooming & Hot Towel',
        category: 'Beard',
        description: 'Beard shaping, razor sharp lining and soothing hot towel wrap',
        durationMinutes: 25,
        price: 249.0,
        availableAtSalon: true,
        availableAtHome: true,
      ),
      const SalonServiceModel(
        id: 'srv_fc',
        name: 'Detox Charcoal Cleanse & Facial',
        category: 'Facial',
        description: 'Deep pore dirt removal, blackhead extraction and skin hydration',
        durationMinutes: 50,
        price: 699.0,
        availableAtSalon: true,
        availableAtHome: true,
      ),
      const SalonServiceModel(
        id: 'srv_hs',
        name: 'Anti-Dandruff Herbal Hair Spa',
        category: 'Spa',
        description: 'Deep nourishing scalp massage and steam conditioning',
        durationMinutes: 45,
        price: 599.0,
        availableAtSalon: true,
        availableAtHome: false,
      ),
      const SalonServiceModel(
        id: 'srv_cl',
        name: 'Hair Colour & Grey Blending',
        category: 'Treatment',
        description: 'Ammonia-free organic shade application with shampoo wash',
        durationMinutes: 60,
        price: 899.0,
        availableAtSalon: true,
        availableAtHome: true,
      ),
    ];
  }

  void _toggleServiceSelection(SalonServiceModel srv) {
    setState(() {
      if (_selectedServiceIds.contains(srv.id)) {
        _selectedServiceIds.remove(srv.id);
      } else {
        _selectedServiceIds.add(srv.id);
      }
    });
  }

  List<SalonServiceModel> get _selectedServicesList {
    return _services.where((s) => _selectedServiceIds.contains(s.id)).toList();
  }

  double get _totalPrice {
    return _selectedServicesList.fold(0.0, (sum, s) => sum + s.price);
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final displayedServices = _selectedCategory == 'All'
        ? _services
        : _services.where((s) => s.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Hero Image Header
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      AppImage(
                        imagePath: _salon.imagePath,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 260,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      // Top Action Bar
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              child: IconButton(
                                icon: Icon(
                                  _salon.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: _salon.isFavorite ? Colors.red : Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _salon = _salon.copyWith(isFavorite: !_salon.isFavorite);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(_salon.isFavorite ? 'Saved to Favorites' : 'Removed from Favorites'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom Hero Details
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _salon.category.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _salon.name,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${_salon.rating}',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${_salon.reviewCount} reviews)',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_rounded, color: Colors.white, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        _salon.distance,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Salon Overview Card (Address, Hours, Home Service)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.place_rounded, size: 18, color: colors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _salon.address.isNotEmpty ? _salon.address : 'Kanpur, Uttar Pradesh',
                                style: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 17, color: colors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Open Today: ${_salon.openingHours} - ${_salon.closingHours}',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (_salon.isHomeServiceEnabled) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.secondary.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.home_repair_service_rounded, size: 16, color: colors.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Doorstep Home Services Available (Within ${_salon.serviceRadiusKm.toStringAsFixed(0)} km)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 3. Service Category Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Services (सर्विस चुनें)',
                          style: AppTextStyles.h2(color: colors.textPrimary).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategory == cat;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? colors.primary : colors.cardBackground,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? colors.primary : colors.border,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : colors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Services List
                if (_isLoadingServices)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = displayedServices[index];
                          final isSelected = _selectedServiceIds.contains(service.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      if (service.description.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          service.description,
                                          style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            '₹${service.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: colors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.schedule_rounded, size: 14, color: colors.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${service.durationMinutes} mins',
                                            style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => _toggleServiceSelection(service),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? colors.primary : colors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: colors.primary),
                                    ),
                                    child: Text(
                                      isSelected ? 'ADDED ✓' : 'ADD +',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : colors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: displayedServices.length,
                      ),
                    ),
                  ),
              ],
            ),

            // Floating Bottom Bar for Booking Confirmation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedServiceIds.isEmpty
                                ? 'No Service Selected'
                                : '${_selectedServiceIds.length} Service(s) Selected',
                            style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _selectedServiceIds.isEmpty ? 'Pick services' : '₹${_totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AppButton(
                        text: 'Book Slot (बुक करें)',
                        backgroundColor: colors.primary,
                        width: 160,
                        height: 44,
                        onPressed: _selectedServiceIds.isEmpty
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select at least 1 service to book')),
                                );
                              }
                            : () {
                                CustomerBookingModal.show(
                                  context: context,
                                  salon: _salon,
                                  selectedServices: _selectedServicesList,
                                  totalAmount: _totalPrice,
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

