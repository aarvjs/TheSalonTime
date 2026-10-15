import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_text_button.dart';
import '../models/salon_model.dart';
import 'salon_card.dart';

class SalonSection extends StatelessWidget {
  final String title;
  final List<SalonModel> salons;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<SalonModel>? onSalonTap;

  const SalonSection({
    super.key,
    this.title = 'Salons Near You',
    required this.salons,
    this.onSeeAllTap,
    this.onSalonTap,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppTextButton(
                text: 'See All →',
                color: colors.primary,
                onPressed: onSeeAllTap ?? () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 256,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: salons.length,
            itemBuilder: (context, index) {
              final salon = salons[index];
              return SalonCard(
                salon: salon,
                onTap: () {
                  if (onSalonTap != null) onSalonTap!(salon);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
