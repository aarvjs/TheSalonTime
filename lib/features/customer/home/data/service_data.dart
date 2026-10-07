import '../../../../core/constants/asset_constants.dart';
import '../models/service_model.dart';

class ServiceData {
  ServiceData._();

  static const List<ServiceModel> maleServices = [
    ServiceModel(
      id: 'msv_1',
      name: 'Classic Haircut & Wash',
      duration: '45 min',
      price: 399,
      rating: 4.8,
      imagePath: AssetConstants.maleBanner1,
      category: 'Haircut',
    ),
    ServiceModel(
      id: 'msv_2',
      name: 'Beard Trim & Hot Towel',
      duration: '30 min',
      price: 299,
      rating: 4.9,
      imagePath: AssetConstants.onboarding2,
      category: 'Beard',
    ),
    ServiceModel(
      id: 'msv_3',
      name: 'Detox Charcoal Facial',
      duration: '50 min',
      price: 799,
      rating: 4.7,
      imagePath: AssetConstants.prefMale,
      category: 'Facial',
    ),
  ];

  static const List<ServiceModel> femaleServices = [
    ServiceModel(
      id: 'fsv_1',
      name: 'Luxury Hair Styling & Blowdry',
      duration: '45 min',
      price: 599,
      rating: 4.9,
      imagePath: AssetConstants.onboarding2,
      category: 'Hair',
    ),
    ServiceModel(
      id: 'fsv_2',
      name: 'Hydra Glow Facial Therapy',
      duration: '60 min',
      price: 1299,
      rating: 4.9,
      imagePath: AssetConstants.onboarding3,
      category: 'Facial',
    ),
    ServiceModel(
      id: 'fsv_3',
      name: 'Rose Gel Pedicure & Polish',
      duration: '50 min',
      price: 699,
      rating: 4.8,
      imagePath: AssetConstants.prefFemale,
      category: 'Pedicure',
    ),
  ];
}
