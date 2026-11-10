import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

/// Location result representing a geocoded or reverse-geocoded place
class LocationResult {
  final String displayName;
  final String? road;
  final String? neighbourhood;
  final String? suburb;
  final String? city;
  final String? state;
  final String? postalCode;
  final String country;
  final double latitude;
  final double longitude;

  const LocationResult({
    required this.displayName,
    this.road,
    this.neighbourhood,
    this.suburb,
    this.city,
    this.state,
    this.postalCode,
    this.country = 'India',
    required this.latitude,
    required this.longitude,
  });

  /// Short human-readable title (e.g. "Civil Lines, Kanpur")
  String get shortTitle {
    final parts = <String>[];
    if (neighbourhood != null && neighbourhood!.isNotEmpty) {
      parts.add(neighbourhood!);
    } else if (suburb != null && suburb!.isNotEmpty) {
      parts.add(suburb!);
    } else if (road != null && road!.isNotEmpty) {
      parts.add(road!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0;
    final address = json['address'] as Map<String, dynamic>? ?? {};

    final city = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['municipality'] ??
        address['county'] ??
        address['state_district'];

    return LocationResult(
      displayName: json['display_name'] as String? ?? 'Selected Location',
      road: address['road'] as String?,
      neighbourhood: address['neighbourhood'] as String?,
      suburb: address['suburb'] as String?,
      city: city as String?,
      state: address['state'] as String?,
      postalCode: address['postcode'] as String?,
      country: address['country'] as String? ?? 'India',
      latitude: lat,
      longitude: lon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'road': road,
      'neighbourhood': neighbourhood,
      'suburb': suburb,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Abstract location service interface for search and reverse geocoding
/// Designed for zero vendor lock-in so OpenStreetMap can be swapped if needed.
abstract class ILocationService {
  Future<List<LocationResult>> searchAddress(String query);
  Future<LocationResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

/// OpenStreetMap Nominatim implementation
/// Follows Nominatim Usage Policy:
/// - Custom User-Agent header
/// - Request caching to minimize upstream load
/// - Debounce protection
/// - Max 1 request per second throttling
class OsmGeocodingService implements ILocationService {
  OsmGeocodingService._();
  static final OsmGeocodingService instance = OsmGeocodingService._();

  static const String _userAgent = 'TheSalonTimes/1.0 (contact@thesalontimes.com)';
  static const String _nominatimBase = 'nominatim.openstreetmap.org';

  // In-memory cache for search queries and reverse lookups
  final Map<String, List<LocationResult>> _searchCache = {};
  final Map<String, LocationResult> _reverseCache = {};

  // Rate limiting timestamp
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  Future<void> _throttle() async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRequestTime);
    if (elapsed.inMilliseconds < 1000) {
      await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
    }
    _lastRequestTime = DateTime.now();
  }

  @override
  Future<List<LocationResult>> searchAddress(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 3) return const [];

    final cacheKey = cleanQuery.toLowerCase();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    try {
      await _throttle();

      final uri = Uri.https(
        _nominatimBase,
        '/search',
        {
          'q': cleanQuery,
          'format': 'json',
          'addressdetails': '1',
          'limit': '6',
          'countrycodes': 'in',
        },
      );

      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', _userAgent);
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != HttpStatus.ok) {
        developer.log('Nominatim search failed: HTTP ${response.statusCode}');
        return const [];
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = json.decode(responseBody);

      if (decoded is List) {
        final results = decoded
            .map((item) => LocationResult.fromJson(item as Map<String, dynamic>))
            .where((loc) => loc.latitude != 0.0 && loc.longitude != 0.0)
            .toList();

        // Cache results (max 100 items in cache)
        if (_searchCache.length > 100) _searchCache.clear();
        _searchCache[cacheKey] = results;

        return results;
      }
      return const [];
    } catch (e, stack) {
      developer.log('Nominatim search error: $e', error: e, stackTrace: stack);
      return const [];
    }
  }

  @override
  Future<LocationResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';
    if (_reverseCache.containsKey(cacheKey)) {
      return _reverseCache[cacheKey];
    }

    try {
      await _throttle();

      final uri = Uri.https(
        _nominatimBase,
        '/reverse',
        {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      );

      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', _userAgent);
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != HttpStatus.ok) {
        developer.log('Nominatim reverse failed: HTTP ${response.statusCode}');
        return null;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = json.decode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final result = LocationResult.fromJson(decoded);

        if (_reverseCache.length > 100) _reverseCache.clear();
        _reverseCache[cacheKey] = result;

        return result;
      }
      return null;
    } catch (e, stack) {
      developer.log('Nominatim reverse error: $e', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Free HTTP client resources
  void dispose() {
    _httpClient.close();
  }
}

