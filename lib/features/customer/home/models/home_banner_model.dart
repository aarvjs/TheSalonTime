import 'package:flutter/material.dart';

class HomeBannerModel {
  final String id;
  final String smallLabel;
  final String title;
  final String description;
  final String ctaText;
  final String imagePath;
  final List<Color> bgGradientColors;
  final Color textColor;
  final Color accentColor;

  const HomeBannerModel({
    required this.id,
    required this.smallLabel,
    required this.title,
    required this.description,
    required this.ctaText,
    required this.imagePath,
    required this.bgGradientColors,
    this.textColor = Colors.white,
    this.accentColor = const Color(0xFFD4AF37),
  });
}
