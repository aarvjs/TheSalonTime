import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_text_button.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class ProductSection extends StatelessWidget {
  final List<ProductModel> products;
  final VoidCallback? onSeeAllTap;

  const ProductSection({
    super.key,
    required this.products,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beauty Picks For You',
                    style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Products curated for your beauty routine',
                    style: AppTextStyles.subtitle(color: colors.textMuted).copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              AppTextButton(
                text: 'See All →',
                color: colors.primary,
                onPressed: onSeeAllTap ?? () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 238,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onAddToCart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: colors.primary,
                      content: Text('${products[index].name} added to cart!'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
