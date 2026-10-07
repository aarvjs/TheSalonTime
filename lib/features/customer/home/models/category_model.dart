import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData iconData;
  final String? imagePath;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconData,
    this.imagePath,
  });
}
