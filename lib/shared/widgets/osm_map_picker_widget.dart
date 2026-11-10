import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/osm_geocoding_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Interactive OpenStreetMap Location Picker with Search, Slippy Tiles & Zero Google API Key
class OsmMapPickerWidget extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String? initialAddress;
  final ValueChanged<LocationResult> onLocationConfirmed;

  const OsmMapPickerWidget({
    super.key,
    this.initialLat = 26.4719, // Kanpur center
    this.initialLng = 80.3524,
    this.initialAddress,
    required this.onLocationConfirmed,
  });

  @override
  State<OsmMapPickerWidget> createState() => _OsmMapPickerWidgetState();
}

class _OsmMapPickerWidgetState extends State<OsmMapPickerWidget> {
  late double _currentLat;
  late double _currentLng;
  int _zoom = 15;

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  Timer? _reverseGeocodeTimer;

  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  List<LocationResult> _searchResults = [];
  String _resolvedAddress = '';

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
    _resolvedAddress = widget.initialAddress ?? 'Detecting address...';

    if (widget.initialAddress == null || widget.initialAddress!.isEmpty) {
      _triggerReverseGeocode();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    _reverseGeocodeTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final results = await OsmGeocodingService.instance.searchAddress(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectSearchResult(LocationResult result) {
    setState(() {
      _currentLat = result.latitude;
      _currentLng = result.longitude;
      _resolvedAddress = result.displayName;
      _searchResults = [];
      _searchCtrl.text = result.shortTitle;
    });
    FocusScope.of(context).unfocus();
  }

  void _triggerReverseGeocode() {
    _reverseGeocodeTimer?.cancel();
    _reverseGeocodeTimer = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isReverseGeocoding = true);
      final res = await OsmGeocodingService.instance.reverseGeocode(
        latitude: _currentLat,
        longitude: _currentLng,
      );
      if (mounted) {
        setState(() {
          _isReverseGeocoding = false;
          if (res != null) {
            _resolvedAddress = res.displayName;
          }
        });
      }
    });
  }

  Future<void> _fetchCurrentGps() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied || req == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission not granted.')),
            );
          }
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      });
      _triggerReverseGeocode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch GPS: $e')),
        );
      }
    }
  }

  // Convert lat/lng to OpenStreetMap slippy tile URL
  String _getTileUrl(int x, int y, int z) {
    return 'https://tile.openstreetmap.org/$z/$x/$y.png';
  }

  // Math helper for tile conversion
  int _longToTileX(double lon, int z) {
    return ((lon + 180.0) / 360.0 * (1 << z)).floor();
  }

  int _latToTileY(double lat, int z) {
    final latRad = lat * math.pi / 180.0;
    return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * (1 << z)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final centerTileX = _longToTileX(_currentLng, _zoom);
    final centerTileY = _latToTileY(_currentLat, _zoom);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6D0C7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pin Exact Location on Map',
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                    ),
                    Text(
                      'Drag map to position pin or search by area/street',
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.warmBlack),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBE6DF)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search city, landmark, or street in India...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedTextGray),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.copper, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Search Auto-complete dropdown
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.copper),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBE6DF)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = _searchResults[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.copper, size: 18),
                    title: Text(
                      item.shortTitle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.displayName,
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSearchResult(item),
                  );
                },
              ),
            ),

          // Interactive Map Area
          Expanded(
            child: Stack(
              children: [
                // 3x3 Slippy Tile Grid with Pan Gesture Detector
                GestureDetector(
                  onPanUpdate: (details) {
                    // Pan sensitivity adjusted by zoom
                    final factor = 360.0 / (256.0 * (1 << _zoom));
                    setState(() {
                      _currentLng -= details.delta.dx * factor * 0.5;
                      _currentLat += details.delta.dy * factor * 0.5;
                      // Clamp
                      _currentLat = _currentLat.clamp(-85.0, 85.0);
                      _currentLng = _currentLng.clamp(-180.0, 180.0);
                    });
                    _triggerReverseGeocode();
                  },
                  child: ClipRect(
                    child: Container(
                      color: const Color(0xFFE5E3DF),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          final col = index % 3 - 1; // -1, 0, 1
                          final row = index ~/ 3 - 1; // -1, 0, 1
                          final tileX = centerTileX + col;
                          final tileY = centerTileY + row;

                          return Image.network(
                            _getTileUrl(tileX, tileY, _zoom),
                            headers: const {
                              'User-Agent': 'TheSalonTimes/1.0 (contact@thesalontimes.com)',
                            },
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: const Color(0xFFE8E5E0),
                              child: const Center(
                                child: Icon(Icons.map_outlined, color: Color(0xFFBFB8AD), size: 28),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Center Pin with Floating Badge
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warmBlack,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          _isReverseGeocoding ? 'Detecting...' : 'Pin Location',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.location_pin,
                        size: 44,
                        color: AppColors.copper,
                      ),
                      Container(
                        width: 12,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 38), // Offset pin point to exact center
                    ],
                  ),
                ),

                // Zoom Controls & Current GPS Button
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Column(
                    children: [
                      // GPS Button
                      FloatingActionButton.small(
                        heroTag: 'osm_gps',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.copper,
                        onPressed: _fetchCurrentGps,
                        child: const Icon(Icons.my_location_rounded, size: 20),
                      ),
                      const SizedBox(height: 8),
                      // Zoom In
                      FloatingActionButton.small(
                        heroTag: 'osm_zoom_in',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.warmBlack,
                        onPressed: _zoom < 18
                            ? () {
                                setState(() => _zoom++);
                              }
                            : null,
                        child: const Icon(Icons.add, size: 20),
                      ),
                      const SizedBox(height: 6),
                      // Zoom Out
                      FloatingActionButton.small(
                        heroTag: 'osm_zoom_out',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.warmBlack,
                        onPressed: _zoom > 10
                            ? () {
                                setState(() => _zoom--);
                              }
                            : null,
                        child: const Icon(Icons.remove, size: 20),
                      ),
                    ],
                  ),
                ),

                // OSM Mandatory Attribution Bar
                Positioned(
                  bottom: 4,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 9, color: Color(0xFF555555), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Details & Confirmation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEBE6DF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place_rounded, color: AppColors.copper, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resolvedAddress.isNotEmpty ? _resolvedAddress : 'No address resolved',
                            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lat: ${_currentLat.toStringAsFixed(5)}° N, Long: ${_currentLng.toStringAsFixed(5)}° E',
                            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.copper,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final confirmedLocation = LocationResult(
                        displayName: _resolvedAddress.isNotEmpty ? _resolvedAddress : 'Selected Location',
                        latitude: _currentLat,
                        longitude: _currentLng,
                      );
                      widget.onLocationConfirmed(confirmedLocation);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Confirm Location Pin',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

