import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/google_maps_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../services/customer_location_state.dart';

class LocationPickerModal extends StatefulWidget {
  const LocationPickerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LocationPickerModal(),
    );
  }

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<GooglePlacePrediction> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _quickLocations = [
    {
      'title': 'Civil Lines, Kanpur',
      'lat': 26.4719,
      'lng': 80.3524,
      'icon': Icons.apartment_rounded,
    },
    {
      'title': 'Swaroop Nagar, Kanpur',
      'lat': 26.4850,
      'lng': 80.3150,
      'icon': Icons.storefront_rounded,
    },
    {
      'title': 'Kakadeo, Kanpur',
      'lat': 26.4880,
      'lng': 80.2950,
      'icon': Icons.location_city_rounded,
    },
    {
      'title': 'Hazratganj, Lucknow',
      'lat': 26.8467,
      'lng': 80.9462,
      'icon': Icons.account_balance_rounded,
    },
    {
      'title': 'Gomti Nagar, Lucknow',
      'lat': 26.8500,
      'lng': 80.9900,
      'icon': Icons.villa_rounded,
    },
    {
      'title': 'Connaught Place, Delhi',
      'lat': 28.6304,
      'lng': 77.2177,
      'icon': Icons.hub_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await GoogleMapsService.instance.searchPlaces(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _selectPlace(GooglePlacePrediction pred) async {
    setState(() => _isSearching = true);
    try {
      final details = await GoogleMapsService.instance.getPlaceDetails(
        pred.placeId,
        fallbackDescription: pred.description,
      );

      if (details != null && mounted) {
        final label = pred.mainText.isNotEmpty ? pred.mainText : details.name;
        await CustomerLocationState.instance.setManualLocation(
          lat: details.latitude,
          lng: details.longitude,
          title: label,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.copper,
            content: Text('Location updated: $label', style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (_) {}
    if (mounted) setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag pill
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.my_location_rounded, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Your Location',
                          style: AppTextStyles.h2(color: colors.textPrimary).copyWith(fontSize: 17),
                        ),
                        Text(
                          'लोकेशन सेव रहेगी और सिर्फ पास के सैलून दिखेंगे',
                          style: AppTextStyles.caption(color: colors.textSecondary).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Primary GPS Button (One-click Auto Detect)
              ListenableBuilder(
                listenable: CustomerLocationState.instance,
                builder: (context, _) {
                  final state = CustomerLocationState.instance;
                  final isBusy = state.isLoading;

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: isBusy
                            ? null
                            : () async {
                                final success = await state.enableGpsLocation(context);
                                if (context.mounted) {
                                  if (success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.copper,
                                        content: Text(
                                          'GPS Location updated & saved: ${state.locationTitle}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else if (state.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red.shade700,
                                        content: Text(state.errorMessage!),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isBusy)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else
                                const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                isBusy ? 'Detecting Live GPS...' : 'Use Current GPS Location (ऑटो-डिटेक्ट)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Google Places Autocomplete Search Bar
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: colors.primary, size: 20),
                    hintText: 'Search colony, landmark or city...',
                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 12.5),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Search results list from Google Places API
              if (_isSearching) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ] else if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'MATCHING PLACES (GOOGLE MAPS)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                ..._searchResults.map((pred) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(
                      pred.mainText,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
                    ),
                    subtitle: Text(
                      pred.description,
                      style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectPlace(pred),
                  );
                }),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Quick Popular Areas
              Text(
                'OR SELECT POPULAR AREAS (शहर चुनें)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickLocations.map((loc) {
                  final title = loc['title'] as String;
                  final lat = loc['lat'] as double;
                  final lng = loc['lng'] as double;
                  final isCurrent = CustomerLocationState.instance.locationTitle == title;

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      CustomerLocationState.instance.setManualLocation(
                        lat: lat,
                        lng: lng,
                        title: title,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.copper,
                          content: Text('Location set to: $title', style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? colors.primary.withValues(alpha: 0.12) : colors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? colors.primary : colors.border,
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            loc['icon'] as IconData,
                            size: 15,
                            color: isCurrent ? colors.primary : colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
