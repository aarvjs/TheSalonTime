import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final isMale = RoleTheme.controllerOf(context).mode == AppRoleThemeMode.customerMale;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'My Bookings',
                  style: AppTextStyles.h1(color: colors.textPrimary).copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Segmented Tab Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: colors.border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, 'Upcoming', colors),
                      _buildTabItem(1, 'Completed', colors),
                      _buildTabItem(2, 'Cancelled', colors),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Bookings Cards List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildBookingCard(
                      context,
                      salonName: isMale ? 'The Groom Room' : 'Glow Beauty Studio',
                      serviceName: isMale ? 'Classic Haircut & Beard Trim' : 'Hair Spa & Hydra Facial',
                      dateTime: 'Today • 6:30 PM',
                      isHomeService: false,
                      status: 'Confirmed',
                      imagePath: isMale ? AssetConstants.onboarding1 : AssetConstants.onboarding3,
                      colors: colors,
                    ),
                    const SizedBox(height: 14),
                    _buildBookingCard(
                      context,
                      salonName: isMale ? 'Royalty Barber Lounge' : 'Maison De Élégance',
                      serviceName: isMale ? 'Detox Charcoal Facial' : 'Luxury Makeup & Styling',
                      dateTime: 'Tomorrow • 11:00 AM',
                      isHomeService: true,
                      status: 'Confirmed',
                      imagePath: isMale ? AssetConstants.prefMale : AssetConstants.prefFemale,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, AppColorsData colors) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context, {
    required String salonName,
    required String serviceName,
    required String dateTime,
    required bool isHomeService,
    required String status,
    required String imagePath,
    required AppColorsData colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(
                  imagePath: imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          salonName,
                          style: AppTextStyles.h3(color: colors.textPrimary).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isHomeService
                                ? colors.secondary.withValues(alpha: 0.2)
                                : colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isHomeService ? colors.secondary : colors.primary,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            isHomeService ? 'HOME SERVICE' : 'SALON VISIT',
                            style: TextStyle(
                              color: isHomeService ? colors.secondary : colors.primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: AppTextStyles.subtitle(color: colors.textSecondary).copyWith(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: colors.primary),
                        const SizedBox(width: 4),
                        Text(
                          dateTime,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              AppButton(
                text: 'View Details',
                height: 36,
                width: 110,
                isOutlined: true,
                backgroundColor: colors.primary,
                textColor: colors.primary,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
