import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'osm_geocoding_service.dart';

class GooglePlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  const GooglePlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });

  factory GooglePlacePrediction.fromJson(Map<String, dynamic> json) {
    final sf = json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return GooglePlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      mainText: sf['main_text'] as String? ?? (json['description'] as String? ?? ''),
      secondaryText: sf['secondary_text'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class GooglePlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String postalCode;

  const GooglePlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory GooglePlaceDetails.fromGoogleJson(Map<String, dynamic> result) {
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;

    String city = '';
    String state = '';
    String postalCode = '';

    final comps = result['address_components'] as List? ?? [];
    for (final c in comps) {
      if (c is Map<String, dynamic>) {
        final types = (c['types'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final longName = c['long_name'] as String? ?? '';
        if (types.contains('locality')) {
          city = longName;
        } else if (types.contains('administrative_area_level_2') && city.isEmpty) {
          city = longName;
        } else if (types.contains('administrative_area_level_1')) {
          state = longName;
        } else if (types.contains('postal_code')) {
          postalCode = longName;
        }
      }
    }

    return GooglePlaceDetails(
      placeId: result['place_id'] as String? ?? '',
      name: result['name'] as String? ?? '',
      formattedAddress: result['formatted_address'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      city: city,
      state: state,
      postalCode: postalCode,
    );
  }
}

class GoogleMapsService {
  GoogleMapsService._();
  static final GoogleMapsService instance = GoogleMapsService._();

  static const String apiKey = 'AIzaSyBeIlXiJwZa8kWK0OTczQ0vEuarTHOzThA';

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  /// Search places using Google Places Autocomplete API with country filter (IN)
  /// Falls back to OpenStreetMap Nominatim if Google key is restricted or fails.
  Future<List<GooglePlacePrediction>> searchPlaces(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return const [];

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': cleanQuery,
          'components': 'country:in',
          'key': apiKey,
        },
      );

      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final status = json['status'] as String? ?? '';

        if (status == 'OK' && json['predictions'] is List) {
          final list = (json['predictions'] as List)
              .map((p) => GooglePlacePrediction.fromJson(p as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } else {
          developer.log('Google Places returned status: $status, using geocoding fallback.');
        }
      }
    } catch (e) {
      developer.log('Google Places Autocomplete error: $e. Falling back to OSM search.');
    }

    // High reliability fallback using existing OSM Geocoding Service
    try {
      final osmResults = await OsmGeocodingService.instance.searchAddress(cleanQuery);
      return osmResults.map((loc) {
        return GooglePlacePrediction(
          placeId: 'osm_${loc.latitude}_${loc.longitude}_${loc.displayName.hashCode}',
          mainText: loc.shortTitle,
          secondaryText: '${loc.city ?? ""}, ${loc.state ?? ""}'.trim(),
          description: loc.displayName,
        );
      }).toList();
    } catch (e) {
      developer.log('Fallback geocoding also failed: $e');
      return const [];
    }
  }

  /// Retrieve place details (lat, lng, formatted address) by placeId
  Future<GooglePlaceDetails?> getPlaceDetails(String placeId, {String? fallbackDescription}) async {
    if (placeId.startsWith('osm_')) {
      final parts = placeId.split('_');
      if (parts.length >= 3) {
        final lat = double.tryParse(parts[1]) ?? 26.4719;
        final lng = double.tryParse(parts[2]) ?? 80.3524;
        return GooglePlaceDetails(
          placeId: placeId,
          name: fallbackDescription ?? 'Selected Location',
          formattedAddress: fallbackDescription ?? 'Selected Location, Kanpur, Uttar Pradesh',
          latitude: lat,
          longitude: lng,
          city: 'Kanpur',
          state: 'Uttar Pradesh',
          postalCode: '208001',
        );
      }
    }

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'fields': 'formatted_address,geometry,address_components,name',
          'key': apiKey,
        },
      );

      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['status'] == 'OK' && json['result'] is Map<String, dynamic>) {
          return GooglePlaceDetails.fromGoogleJson(json['result'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      developer.log('Google Place Details error: $e');
    }

    // Fallback: search OSM by description if available
    if (fallbackDescription != null && fallbackDescription.isNotEmpty) {
      try {
        final results = await OsmGeocodingService.instance.searchAddress(fallbackDescription);
        if (results.isNotEmpty) {
          final first = results.first;
          return GooglePlaceDetails(
            placeId: placeId,
            name: first.shortTitle,
            formattedAddress: first.displayName,
            latitude: first.latitude,
            longitude: first.longitude,
            city: first.city ?? 'Kanpur',
            state: first.state ?? 'Uttar Pradesh',
            postalCode: first.postalCode ?? '208001',
          );
        }
      } catch (_) {}
    }

    return null;
  }

  /// Reverse geocode coordinates to human-readable address
  Future<GooglePlaceDetails?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'latlng': '$lat,$lng',
          'key': apiKey,
        },
      );

      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['status'] == 'OK' && json['results'] is List && (json['results'] as List).isNotEmpty) {
          final first = (json['results'] as List).first as Map<String, dynamic>;
          return GooglePlaceDetails.fromGoogleJson(first);
        }
      }
    } catch (e) {
      developer.log('Google Reverse Geocode error: $e');
    }

    // Fallback to OSM
    try {
      final loc = await OsmGeocodingService.instance.reverseGeocode(latitude: lat, longitude: lng);
      if (loc != null) {
        return GooglePlaceDetails(
          placeId: 'osm_${lat}_$lng',
          name: loc.shortTitle,
          formattedAddress: loc.displayName,
          latitude: loc.latitude,
          longitude: loc.longitude,
          city: loc.city ?? 'Kanpur',
          state: loc.state ?? 'Uttar Pradesh',
          postalCode: loc.postalCode ?? '208001',
        );
      }
    } catch (e) {
      developer.log('Fallback reverse geocode error: $e');
    }

    return null;
  }

  /// Generate a Google Static Map preview image URL
  String getStaticMapUrl(double lat, double lng, {int zoom = 16, int width = 600, int height = 300}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=$zoom&size=${width}x$height&markers=color:red%7C$lat,$lng&key=$apiKey';
  }
}
