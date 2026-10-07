import '../../../../core/constants/asset_constants.dart';
import '../models/product_model.dart';

class ProductData {
  ProductData._();

  static const List<ProductModel> femaleProducts = [
    ProductModel(
      id: 'fp_1',
      name: 'Hydrating Glow Serum',
      category: 'Skincare',
      rating: 4.9,
      price: 699,
      originalPrice: 999,
      imagePath: AssetConstants.femaleLoginIllu,
      isBestSeller: true,
    ),
    ProductModel(
      id: 'fp_2',
      name: 'Rosewater Hydrosol Mist',
      category: 'Facial Care',
      rating: 4.8,
      price: 499,
      originalPrice: 650,
      imagePath: AssetConstants.prefFemale,
      isBestSeller: false,
    ),
    ProductModel(
      id: 'fp_3',
      name: 'Nourishing Argan Hair Oil',
      category: 'Haircare',
      rating: 4.7,
      price: 899,
      originalPrice: 1200,
      imagePath: AssetConstants.onboarding2,
      isBestSeller: true,
    ),
  ];
}
