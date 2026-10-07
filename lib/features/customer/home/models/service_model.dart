class ServiceModel {
  final String id;
  final String name;
  final String duration;
  final double price;
  final double rating;
  final String imagePath;
  final String category;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.rating,
    required this.imagePath,
    required this.category,
  });
}
