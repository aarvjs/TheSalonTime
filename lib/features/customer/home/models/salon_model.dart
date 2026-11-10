import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/distance_calculator.dart';

class SalonModel {
  final String id;
  final String partnerId;
  final String name;
  final double rating;
  final int reviewCount;
  final String distance;
  final double distanceKm;
  final String priceTier;
  final String category;
  final bool isOpen;
  final String imagePath;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double serviceRadiusKm;
  final String phone;
  final List<String> photos;
  final String openingHours;
  final String closingHours;
  final List<String> facilities;
  final bool isHomeServiceEnabled;
  final bool isFavorite;

  const SalonModel({
    required this.id,
    this.partnerId = '',
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.distanceKm = 0.0,
    required this.priceTier,
    required this.category,
    required this.isOpen,
    required this.imagePath,
    required this.address,
    this.city = 'Kanpur',
    this.latitude = 26.4719,
    this.longitude = 80.3524,
    this.serviceRadiusKm = 10.0,
    this.phone = '',
    this.photos = const [],
    this.openingHours = '09:00 AM',
    this.closingHours = '09:00 PM',
    this.facilities = const [],
    this.isHomeServiceEnabled = false,
    this.isFavorite = false,
  });

  SalonModel copyWith({
    String? id,
    String? partnerId,
    String? name,
    double? rating,
    int? reviewCount,
    String? distance,
    double? distanceKm,
    String? priceTier,
    String? category,
    bool? isOpen,
    String? imagePath,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    double? serviceRadiusKm,
    String? phone,
    List<String>? photos,
    String? openingHours,
    String? closingHours,
    List<String>? facilities,
    bool? isHomeServiceEnabled,
    bool? isFavorite,
  }) {
    return SalonModel(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      distanceKm: distanceKm ?? this.distanceKm,
      priceTier: priceTier ?? this.priceTier,
      category: category ?? this.category,
      isOpen: isOpen ?? this.isOpen,
      imagePath: imagePath ?? this.imagePath,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      phone: phone ?? this.phone,
      photos: photos ?? this.photos,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      facilities: facilities ?? this.facilities,
      isHomeServiceEnabled: isHomeServiceEnabled ?? this.isHomeServiceEnabled,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Factory constructor to convert Firestore document into Customer SalonModel
  factory SalonModel.fromFirestore({
    required Map<String, dynamic> data,
    required String docId,
    required double userLat,
    required double userLon,
  }) {
    final lat = (data['latitude'] as num?)?.toDouble() ?? 26.4719;
    final lon = (data['longitude'] as num?)?.toDouble() ?? 80.3524;
    final distKm = DistanceCalculator.haversineDistanceKm(
      lat1: userLat,
      lon1: userLon,
      lat2: lat,
      lon2: lon,
    );

    final photosList = <String>[];
    if (data['photos'] is List) {
      for (final p in data['photos'] as List) {
        if (p is String && p.isNotEmpty) photosList.add(p);
      }
    }
    final imagePath = photosList.isNotEmpty
        ? photosList.first
        : (data['logoUrl'] as String? ?? AssetConstants.maleBanner1);

    final facilitiesList = <String>[];
    if (data['facilities'] is List) {
      for (final f in data['facilities'] as List) {
        if (f != null) facilitiesList.add(f.toString());
      }
    }

    return SalonModel(
      id: docId,
      partnerId: (data['partnerId'] as String?) ??
          (data['ownerId'] as String?) ??
          '',
      name: (data['name'] as String?)?.trim() ??
          (data['salonName'] as String?)?.trim() ??
          'Salon',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 24,
      distance: DistanceCalculator.formatDistance(distKm),
      distanceKm: distKm,
      priceTier: (data['priceTier'] as String?) ?? '₹₹',
      category: (data['category'] as String?) ?? 'Unisex Salon',
      isOpen: (data['isActive'] as bool?) ??
          (data['salonStatus'] as bool?) ??
          true,
      imagePath: imagePath,
      address: (data['address'] as String?) ?? '',
      city: (data['city'] as String?) ?? 'Kanpur',
      latitude: lat,
      longitude: lon,
      serviceRadiusKm: (data['serviceRadiusKm'] as num?)?.toDouble() ?? 10.0,
      phone: (data['phone'] as String?) ?? (data['contactNumber'] as String?) ?? '',
      photos: photosList,
      openingHours: (data['openingHours'] as String?) ?? '09:00 AM',
      closingHours: (data['closingHours'] as String?) ?? '09:00 PM',
      facilities: facilitiesList,
      isHomeServiceEnabled: (data['isHomeServiceEnabled'] as bool?) ?? false,
    );
  }

  /// Recalculate distance and return updated model for a given user coordinate
  SalonModel withUserCoordinates(double uLat, double uLon) {
    final distKm = DistanceCalculator.haversineDistanceKm(
      lat1: uLat,
      lon1: uLon,
      lat2: latitude,
      lon2: longitude,
    );
    return copyWith(
      distance: DistanceCalculator.formatDistance(distKm),
      distanceKm: distKm,
    );
  }
}
