import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../models/category_model.dart';
import 'category_item.dart';

class CategorySection extends StatefulWidget {
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel>? onCategorySelected;

  const CategorySection({
    super.key,
    required this.categories,
    this.onCategorySelected,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Explore Categories',
            style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 86,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final cat = widget.categories[index];
              return CategoryItem(
                category: cat,
                isSelected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(cat);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
