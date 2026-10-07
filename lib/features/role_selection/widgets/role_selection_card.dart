import 'package:flutter/material.dart';
import '../../../shared/widgets/role_card.dart';

class RoleSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      title: title,
      description: description,
      imagePath: imagePath,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
