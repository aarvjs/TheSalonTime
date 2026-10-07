class ProductModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double price;
  final double originalPrice;
  final String imagePath;
  final bool isBestSeller;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.price,
    required this.originalPrice,
    required this.imagePath,
    this.isBestSeller = false,
  });
}
