import 'package:flutter/material.dart';
import '../../../../shared/widgets/preference_card.dart';

class PreferenceOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final bool isSelected;
  final Color activeAccentColor;
  final Color activeCardBg;
  final VoidCallback onTap;

  const PreferenceOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
    required this.isSelected,
    required this.activeAccentColor,
    required this.activeCardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PreferenceCard(
      title: title,
      description: description,
      iconData: iconData,
      isSelected: isSelected,
      activeAccentColor: activeAccentColor,
      activeCardBg: activeCardBg,
      onTap: onTap,
    );
  }
}
