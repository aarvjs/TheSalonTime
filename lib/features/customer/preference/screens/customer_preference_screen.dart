import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';

enum GenderPreference { female, male, neutral }

class CustomerPreferenceScreen extends StatefulWidget {
  const CustomerPreferenceScreen({super.key});

  @override
  State<CustomerPreferenceScreen> createState() =>
      _CustomerPreferenceScreenState();
}

class _CustomerPreferenceScreenState extends State<CustomerPreferenceScreen> {
  GenderPreference _selectedPreference = GenderPreference.female;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoleTheme.controllerOf(context)
          .setThemeMode(AppRoleThemeMode.customerFemale);
    });
  }

  void _onPreferenceSelected(GenderPreference preference) {
    setState(() {
      _selectedPreference = preference;
    });

    final themeController = RoleTheme.controllerOf(context);
    switch (preference) {
      case GenderPreference.female:
        themeController.setThemeMode(AppRoleThemeMode.customerFemale);
        break;
      case GenderPreference.male:
        themeController.setThemeMode(AppRoleThemeMode.customerMale);
        break;
      case GenderPreference.neutral:
        themeController.setThemeMode(AppRoleThemeMode.customerNeutral);
        break;
    }

    // Auto-navigate after selecting preference, matching customer flow
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.customerLogin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Bottom Decorative Leaf Curves
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.35,
                child: SvgPicture.asset(
                  AssetConstants.silkLines,
                  fit: BoxFit.cover,
                  height: 180,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Navigation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SvgPicture.asset(
                        AssetConstants.leafLogo,
                        width: 28,
                        height: 34,
                      ),
                      const SizedBox(width: 48), // Balance spacing
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title & Subtitle
                  Text(
                    'Choose Your Style',
                    style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Personalize your salon experience.',
                    style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Two Main Vertical Cards: Female & Male Side by Side
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        // 1. Female Card (Left)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onPreferenceSelected(GenderPreference.female),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _selectedPreference == GenderPreference.female
                                      ? AppColors.softRose
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedPreference == GenderPreference.female
                                        ? AppColors.softRose.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      AssetConstants.prefFemale,
                                      fit: BoxFit.cover,
                                    ),
                                    // Bottom Gradient Overlay & Label
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              AppColors.softRose.withValues(alpha: 0.85),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Female',
                                              style: AppTextStyles.h3(color: Colors.white).copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(alpha: 0.3),
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: _selectedPreference == GenderPreference.female
                                                  ? const Center(
                                                      child: CircleAvatar(
                                                        radius: 5,
                                                        backgroundColor: Colors.white,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 2. Male Card (Right)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onPreferenceSelected(GenderPreference.male),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _selectedPreference == GenderPreference.male
                                      ? AppColors.deepNavy
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedPreference == GenderPreference.male
                                        ? AppColors.deepNavy.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      AssetConstants.prefMale,
                                      fit: BoxFit.cover,
                                    ),
                                    // Bottom Gradient Overlay & Label
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              AppColors.deepNavy.withValues(alpha: 0.9),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Male',
                                              style: AppTextStyles.h3(color: Colors.white).copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(alpha: 0.3),
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: _selectedPreference == GenderPreference.male
                                                  ? const Center(
                                                      child: CircleAvatar(
                                                        radius: 5,
                                                        backgroundColor: Colors.white,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 3. Prefer Not To Say Horizontal Card (Bottom)
                  GestureDetector(
                    onTap: () => _onPreferenceSelected(GenderPreference.neutral),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedPreference == GenderPreference.neutral
                              ? AppColors.copper
                              : const Color(0xFFEBE6DF),
                          width: _selectedPreference == GenderPreference.neutral ? 1.8 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.softCream,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.warmBlack,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prefer not to say',
                                  style: AppTextStyles.h3(color: AppColors.warmBlack).copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Get a personalized experience',
                                  style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedPreference == GenderPreference.neutral
                                    ? AppColors.copper
                                    : const Color(0xFFD0C9C0),
                                width: 2,
                              ),
                            ),
                            child: _selectedPreference == GenderPreference.neutral
                                ? const Center(
                                    child: CircleAvatar(
                                      radius: 5,
                                      backgroundColor: AppColors.copper,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
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
