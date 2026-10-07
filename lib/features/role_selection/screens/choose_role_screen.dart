import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/role_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/role_selection_card.dart';

enum AppUserRole { customer, partner, manager }

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  AppUserRole _selectedRole = AppUserRole.customer;

  void _onContinue() {
    final themeController = RoleTheme.controllerOf(context);

    switch (_selectedRole) {
      case AppUserRole.customer:
        themeController.setThemeMode(AppRoleThemeMode.defaultBrand);
        Navigator.pushNamed(context, AppRoutes.customerPreference);
        break;
      case AppUserRole.partner:
        themeController.setThemeMode(AppRoleThemeMode.partner);
        Navigator.pushNamed(context, AppRoutes.partnerLogin);
        break;
      case AppUserRole.manager:
        themeController.setThemeMode(AppRoleThemeMode.manager);
        Navigator.pushNamed(context, AppRoutes.managerLogin);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Corner Botanical Watermark Accents
            Positioned(
              top: 60,
              left: -15,
              child: Opacity(
                opacity: 0.12,
                child: SvgPicture.asset(
                  AssetConstants.leafLogo,
                  width: 70,
                  height: 80,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              right: -15,
              child: Opacity(
                opacity: 0.12,
                child: SvgPicture.asset(
                  AssetConstants.leafLogo,
                  width: 80,
                  height: 90,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Top Golden Leaf Logo Mark
                  SvgPicture.asset(
                    AssetConstants.leafLogo,
                    width: 32,
                    height: 38,
                  ),
                  const SizedBox(height: 20),
                  // Editorial Header Title & Subtitle
                  Text(
                    'How would you like\nto continue?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                      fontSize: 28,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your role to get started',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 3 Role Cards List
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          RoleSelectionCard(
                            title: 'Customer',
                            description:
                                'Discover salons, explore services and book appointments.',
                            imagePath: AssetConstants.roleCustomer,
                            isSelected: _selectedRole == AppUserRole.customer,
                            onTap: () {
                              setState(() {
                                _selectedRole = AppUserRole.customer;
                              });
                            },
                          ),
                          RoleSelectionCard(
                            title: 'Partner',
                            description:
                                'Manage your salon, services, staff and bookings.',
                            imagePath: AssetConstants.rolePartner,
                            isSelected: _selectedRole == AppUserRole.partner,
                            onTap: () {
                              setState(() {
                                _selectedRole = AppUserRole.partner;
                              });
                            },
                          ),
                          RoleSelectionCard(
                            title: 'Branch Manager',
                            description:
                                'Manage your assigned branch, appointments and daily operations.',
                            imagePath: AssetConstants.roleManager,
                            isSelected: _selectedRole == AppUserRole.manager,
                            onTap: () {
                              setState(() {
                                _selectedRole = AppUserRole.manager;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Full Width Continue CTA Button
                  AppButton(
                    text: 'Continue',
                    backgroundColor: AppColors.copper,
                    onPressed: _onContinue,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
