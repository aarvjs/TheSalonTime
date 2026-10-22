import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class SalonDetailsScreen extends StatelessWidget {
  const SalonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final salon = PartnerState.instance.salon;
        final isVerified = salon.verificationStatus == PartnerVerificationStatus.approved;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'My Salon Details',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.copper),
                tooltip: 'Edit Salon Details',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.partnerEditSalon);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Salon Image & Badges
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        Image.asset(
                          AssetConstants.partnerLoginIllu,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isVerified ? Colors.green.shade600 : AppColors.champagneGold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'Verified Business' : 'Verification Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                salon.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                salon.category,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Capability Highlights
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCapabilityItem(
                          icon: Icons.storefront_rounded,
                          title: 'Salon Visits',
                          subtitle: 'Open 7 Days',
                          color: AppColors.copper,
                        ),
                        Container(height: 30, width: 1, color: const Color(0xFFEBE6DF)),
                        _buildCapabilityItem(
                          icon: Icons.home_repair_service_rounded,
                          title: 'Home Service',
                          subtitle: salon.isHomeServiceEnabled ? 'Active (12km)' : 'Disabled',
                          color: salon.isHomeServiceEnabled ? Colors.green.shade700 : AppColors.mutedTextGray,
                        ),
                        Container(height: 30, width: 1, color: const Color(0xFFEBE6DF)),
                        _buildCapabilityItem(
                          icon: Icons.alt_route_rounded,
                          title: 'Branches',
                          subtitle: '${salon.branches.length} Locations',
                          color: AppColors.champagneGold,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // About Section
                  _buildSectionTitle('About Salon'),
                  const SizedBox(height: 6),
                  Text(
                    salon.description,
                    style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 18),

                  // Contact & Location Card
                  _buildSectionTitle('Location & Contact'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: '${salon.address}, ${salon.city}, ${salon.state} - ${salon.postalCode}',
                        ),
                        const Divider(height: 16, color: Color(0xFFEBE6DF)),
                        _buildInfoRow(
                          icon: Icons.gps_fixed_rounded,
                          label: 'Coordinates',
                          value: '${salon.latitude.toStringAsFixed(4)}° N, ${salon.longitude.toStringAsFixed(4)}° E',
                        ),
                        const Divider(height: 16, color: Color(0xFFEBE6DF)),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Primary Phone',
                          value: salon.phone,
                        ),
                        const Divider(height: 16, color: Color(0xFFEBE6DF)),
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Business Email',
                          value: salon.email,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Timings & Working Days
                  _buildSectionTitle('Operational Timings'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Hours:',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${salon.openingHours} – ${salon.closingHours}',
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Operating Days:',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                            ),
                            Expanded(
                              child: Text(
                                salon.operatingDays.join(', '),
                                textAlign: TextAlign.right,
                                style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Facilities List
                  _buildSectionTitle('Facilities & Amenities'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: salon.facilities.map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEBE6DF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.copper),
                            const SizedBox(width: 6),
                            Text(
                              f,
                              style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Edit Action Button
                  AppButton(
                    text: 'Edit Salon Details',
                    icon: Icons.edit_outlined,
                    backgroundColor: AppColors.copper,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.partnerEditSalon);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
    );
  }

  Widget _buildCapabilityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
        ),
        Text(
          subtitle,
          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.copper),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
