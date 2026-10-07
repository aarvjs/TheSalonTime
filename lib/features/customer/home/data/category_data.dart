import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryData {
  CategoryData._();

  static const List<CategoryModel> maleCategories = [
    CategoryModel(id: 'mc_1', name: 'Haircut', iconData: Icons.content_cut_rounded),
    CategoryModel(id: 'mc_2', name: 'Beard', iconData: Icons.face_rounded),
    CategoryModel(id: 'mc_3', name: 'Hair Styling', iconData: Icons.style_rounded),
    CategoryModel(id: 'mc_4', name: 'Shaving', iconData: Icons.brush_rounded),
    CategoryModel(id: 'mc_5', name: 'Facial', iconData: Icons.clean_hands_rounded),
    CategoryModel(id: 'mc_6', name: 'Hair Spa', iconData: Icons.spa_rounded),
    CategoryModel(id: 'mc_7', name: 'Grooming', iconData: Icons.dry_cleaning_rounded),
  ];

  static const List<CategoryModel> femaleCategories = [
    CategoryModel(id: 'fc_1', name: 'Hair', iconData: Icons.content_cut_rounded),
    CategoryModel(id: 'fc_2', name: 'Facial', iconData: Icons.face_3_rounded),
    CategoryModel(id: 'fc_3', name: 'Makeup', iconData: Icons.brush_rounded),
    CategoryModel(id: 'fc_4', name: 'Nails', iconData: Icons.back_hand_rounded),
    CategoryModel(id: 'fc_5', name: 'Skin Care', iconData: Icons.clean_hands_rounded),
    CategoryModel(id: 'fc_6', name: 'Hair Spa', iconData: Icons.spa_rounded),
    CategoryModel(id: 'fc_7', name: 'Waxing', iconData: Icons.auto_awesome_rounded),
    CategoryModel(id: 'fc_8', name: 'Bridal', iconData: Icons.diamond_rounded),
  ];
}
