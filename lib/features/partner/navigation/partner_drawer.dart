import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/partner_state.dart';
import '../models/partner_models.dart';

class PartnerDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const PartnerDrawer({
    super.key,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out of Partner Portal?',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        content: Text(
          'You will need to sign in again to manage your salon and accept appointments.',
          style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.chooseRole, (r) => false);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showBranchSwitcher(BuildContext context) {
    final branches = PartnerState.instance.branches;
    final currentSelected = PartnerState.instance.selectedBranchId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Active Branch',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(
                'Select branch to view localized appointments and staff',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.apartment_rounded, color: AppColors.copper),
                title: const Text('All Branches (Aggregated)'),
                trailing: currentSelected == 'all'
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.copper)
                    : null,
                onTap: () {
                  PartnerState.instance.selectBranch('all');
                  Navigator.pop(ctx);
                },
              ),
              ...branches.map((b) {
                final isSelected = currentSelected == b.branchId;
                return ListTile(
                  leading: const Icon(Icons.storefront_outlined, color: AppColors.copper),
                  title: Text(b.branchName),
                  subtitle: Text('${b.areaOrCity} • Manager: ${b.managerName ?? "Unassigned"}'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.copper)
                      : null,
                  onTap: () {
                    PartnerState.instance.selectBranch(b.branchId);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final partner = PartnerState.instance.partner;
        final salon = PartnerState.instance.salon;
        final isVerified = partner.verificationStatus == PartnerVerificationStatus.approved;
        final currentBranch = PartnerState.instance.currentBranch;

        return Drawer(
          backgroundColor: AppColors.warmIvory,
          child: SafeArea(
            child: Column(
              children: [
                // Drawer Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFEBE6DF), width: 1.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            AssetConstants.leafLogo,
                            width: 26,
                            height: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isVerified ? Colors.green.shade50 : AppColors.champagneGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isVerified ? Colors.green.shade300 : AppColors.champagneGold.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified ? Icons.verified_rounded : Icons.pending_outlined,
                                  size: 13,
                                  color: isVerified ? Colors.green.shade800 : const Color(0xFF9E7D1A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'VERIFIED' : 'PENDING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isVerified ? Colors.green.shade800 : const Color(0xFF9E7D1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        partner.businessName,
                        style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Owner: ${partner.fullName}',
                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      // Branch Switcher Pill
                      InkWell(
                        onTap: () => _showBranchSwitcher(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warmGray,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEBE6DF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 15, color: AppColors.copper),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  PartnerState.instance.selectedBranchId == 'all'
                                      ? 'All Branches (${salon.branches.length})'
                                      : (currentBranch?.branchName ?? 'Main Branch'),
                                  style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.unfold_more_rounded, size: 14, color: AppColors.mutedTextGray),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Drawer Links List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard_rounded,
                        title: 'Dashboard (डैशबोर्ड)',
                        isSelected: selectedIndex == 0,
                        onTap: () {
                          Navigator.pop(context);
                          if (onDestinationSelected != null) onDestinationSelected!(0);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.add_business_rounded,
                        activeIcon: Icons.add_business_rounded,
                        title: '+ Create Salon (सैलून जोड़ें)',
                        isSelected: false,
                        iconColor: AppColors.copper,
                        textColor: AppColors.copper,
                        badge: 'SETUP',
                        badgeColor: AppColors.copper.withValues(alpha: 0.15),
                        badgeTextColor: AppColors.copper,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.store_outlined,
                        activeIcon: Icons.store_rounded,
                        title: 'My Salon Profile',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerSalonDetails);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.alt_route_rounded,
                        activeIcon: Icons.alt_route_rounded,
                        title: 'Manage Branches (${salon.branches.length})',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerBranches);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.spa_outlined,
                        activeIcon: Icons.spa_rounded,
                        title: 'Services & Catalog',
                        isSelected: selectedIndex == 2,
                        onTap: () {
                          Navigator.pop(context);
                          if (onDestinationSelected != null) onDestinationSelected!(2);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.home_repair_service_outlined,
                        activeIcon: Icons.home_repair_service_rounded,
                        title: 'Home Service Settings',
                        isSelected: false,
                        badge: salon.isHomeServiceEnabled ? 'ON' : 'OFF',
                        badgeColor: salon.isHomeServiceEnabled ? Colors.green.shade50 : AppColors.warmGray,
                        badgeTextColor: salon.isHomeServiceEnabled ? Colors.green.shade800 : AppColors.mutedTextGray,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerHomeService);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today_rounded,
                        title: 'Bookings & Appointments',
                        isSelected: selectedIndex == 1,
                        badge: '${PartnerState.instance.bookings.length}',
                        badgeColor: AppColors.copper.withValues(alpha: 0.12),
                        badgeTextColor: AppColors.copper,
                        onTap: () {
                          Navigator.pop(context);
                          if (onDestinationSelected != null) onDestinationSelected!(1);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.badge_outlined,
                        activeIcon: Icons.badge_rounded,
                        title: 'Staff & Branch Managers',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerStaff);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.payments_outlined,
                        activeIcon: Icons.payments_rounded,
                        title: 'Earnings & Payouts',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerEarnings);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.notifications_none_rounded,
                        activeIcon: Icons.notifications_rounded,
                        title: 'Notifications',
                        isSelected: false,
                        badge: PartnerState.instance.unreadNotificationsCount > 0
                            ? '${PartnerState.instance.unreadNotificationsCount}'
                            : null,
                        badgeColor: AppColors.copper,
                        badgeTextColor: Colors.white,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerNotifications);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        title: 'Partner Profile & Business',
                        isSelected: selectedIndex == 3,
                        onTap: () {
                          Navigator.pop(context);
                          if (onDestinationSelected != null) onDestinationSelected!(3);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.verified_user_outlined,
                        activeIcon: Icons.verified_user_rounded,
                        title: 'Verification Status',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.partnerVerificationStatus);
                        },
                      ),
                      const Divider(height: 20, color: Color(0xFFEBE6DF)),
                      _buildDrawerItem(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        iconColor: Colors.red.shade400,
                        textColor: Colors.red.shade600,
                        isSelected: false,
                        onTap: () => _confirmLogout(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    IconData? activeIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
    Color? badgeTextColor,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.copper.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected ? (activeIcon ?? icon) : icon,
          size: 21,
          color: isSelected ? AppColors.copper : (iconColor ?? AppColors.charcoal),
        ),
        title: Text(
          title,
          style: AppTextStyles.body(
            color: isSelected ? AppColors.copper : (textColor ?? AppColors.warmBlack),
          ).copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.warmGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor ?? AppColors.charcoal,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

extension _BranchExt on BranchModel {
  String get areaOrCity {
    if (address.contains(',')) {
      final parts = address.split(',');
      return parts.first.trim();
    }
    return city;
  }
}
