import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_text_button.dart';
import '../models/service_model.dart';
import 'service_card.dart';

class ServiceSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ServiceModel> services;
  final VoidCallback? onSeeAllTap;

  const ServiceSection({
    super.key,
    this.title = 'Popular Services',
    this.subtitle,
    required this.services,
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
                    title,
                    style: AppTextStyles.h2(color: colors.textPrimary).copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.subtitle(color: colors.textMuted).copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
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
          height: 218,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];
              return ServiceCard(
                service: s,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: colors.primary,
                      content: Text('Selected ${s.name}'),
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
