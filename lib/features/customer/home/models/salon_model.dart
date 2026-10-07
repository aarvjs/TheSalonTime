class SalonModel {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String distance;
  final String priceTier;
  final String category;
  final bool isOpen;
  final String imagePath;
  final String address;
  final bool isFavorite;

  const SalonModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.priceTier,
    required this.category,
    required this.isOpen,
    required this.imagePath,
    required this.address,
    this.isFavorite = false,
  });
}
