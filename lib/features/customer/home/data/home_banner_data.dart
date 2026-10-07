import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../models/home_banner_model.dart';

class HomeBannerData {
  HomeBannerData._();

  static const List<HomeBannerModel> maleBanners = [
    HomeBannerModel(
      id: 'mb_1',
      smallLabel: 'LIMITED OFFER',
      title: 'Premium Haircut & Styling',
      description: 'Look sharp. Feel confident with master barbers.',
      ctaText: 'Explore Now',
      imagePath: AssetConstants.maleBanner1,
      bgGradientColors: [
        Color(0xFF0F172A),
        Color(0xFF1B2A47),
      ],
      accentColor: Color(0xFFD4AF37),
    ),
    HomeBannerModel(
      id: 'mb_2',
      smallLabel: 'EXPRESS SERVICE',
      title: 'Beard Grooming & Spa',
      description: 'Professional beard sculpting near you.',
      ctaText: 'Book Slot',
      imagePath: AssetConstants.onboarding2,
      bgGradientColors: [
        Color(0xFF1B2A47),
        Color(0xFF2C4066),
      ],
      accentColor: Color(0xFFE6C687),
    ),
    HomeBannerModel(
      id: 'mb_3',
      smallLabel: 'EXCLUSIVE OFFERS',
      title: 'Men\'s Grooming Packages',
      description: 'Flat 25% OFF on luxury grooming rituals.',
      ctaText: 'Claim Offer',
      imagePath: AssetConstants.onboarding1,
      bgGradientColors: [
        Color(0xFF2C2C2C),
        Color(0xFF1A1A1A),
      ],
      accentColor: Color(0xFFC86D51),
    ),
  ];

  static const List<HomeBannerModel> femaleBanners = [
    HomeBannerModel(
      id: 'fb_1',
      smallLabel: 'LUXURY SALONS',
      title: 'Beauty & Hair Couture',
      description: 'Your beauty, your way with top salon stylists.',
      ctaText: 'Explore Salons',
      imagePath: AssetConstants.onboarding2,
      bgGradientColors: [
        Color(0xFFC58276),
        Color(0xFFD98880),
      ],
      accentColor: Color(0xFFF6ECE9),
    ),
    HomeBannerModel(
      id: 'fb_2',
      smallLabel: 'SKIN & GLOW',
      title: 'Hair Spa & Skincare',
      description: 'Premium beauty & rejuvenation near you.',
      ctaText: 'Book Service',
      imagePath: AssetConstants.onboarding3,
      bgGradientColors: [
        Color(0xFFD98880),
        Color(0xFFE8A598),
      ],
      accentColor: Color(0xFFD4AF37),
    ),
    HomeBannerModel(
      id: 'fb_3',
      smallLabel: 'CURATED PRODUCTS',
      title: 'Beauty Products',
      description: 'Discover skincare & haircare you\'ll love.',
      ctaText: 'Shop Now',
      imagePath: AssetConstants.prefFemale,
      bgGradientColors: [
        Color(0xFFB86B63),
        Color(0xFFC0736B),
      ],
      accentColor: Color(0xFFFDFBF7),
    ),
  ];
}
