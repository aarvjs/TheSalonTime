import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/branch_manager_state.dart';

class ManagerDrawer extends StatelessWidget {
  final int currentTabIndex;
  final ValueChanged<int> onSelectTab;

  const ManagerDrawer({
    super.key,
    required this.currentTabIndex,
    required this.onSelectTab,
  });

  void _confirmLogout(BuildContext context) {
    Navigator.pop(context); // Close drawer
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out of Branch Console?',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to exit your Branch Manager session?',
          style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.managerEmerald,
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

  @override
  Widget build(BuildContext context) {
    final state = BranchManagerState.instance;
    final session = state.session;

    return Drawer(
      backgroundColor: AppColors.warmIvory,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBE6DF), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.managerEmerald, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AssetConstants.managerLoginIllu,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.managerName,
                              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Branch Operations Manager',
                              style: TextStyle(
                                color: AppColors.managerEmerald,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Assigned Branch Info with Salon Photo Thumbnail
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.managerEmeraldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.managerBorder),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            session.assignedBranchImage,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.assignedSalonName,
                                style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                session.assignedBranchName,
                                style: TextStyle(
                                  color: AppColors.managerEmerald,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Read-Only Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.managerGoldLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.managerGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.remove_red_eye_outlined, size: 12, color: Color(0xFF8A6C1C)),
                        SizedBox(width: 4),
                        Text(
                          'READ-ONLY BUSINESS PROFILE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A6C1C),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: currentTabIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(0);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month_rounded,
                    title: 'Branch Bookings',
                    isSelected: currentTabIndex == 1,
                    badgeCount: state.pendingBookingsCount,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(1);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.spa_outlined,
                    activeIcon: Icons.spa_rounded,
                    title: 'Branch Services (View Only)',
                    isSelected: currentTabIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(2);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_rounded,
                    title: 'Staff Overview (View Only)',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.managerStaff);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_outlined,
                    activeIcon: Icons.notifications_rounded,
                    title: 'Notifications',
                    isSelected: false,
                    badgeCount: state.unreadNotificationsCount,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.managerNotifications);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    title: 'Manager Profile',
                    isSelected: currentTabIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(3);
                    },
                  ),
                ],
              ),
            ),

            // Footer Logout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEBE6DF))),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Sign Out of Branch',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.managerEmerald.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.managerEmerald : AppColors.charcoal,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.managerEmerald : AppColors.warmBlack,
          ),
        ),
        trailing: badgeCount != null && badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.managerEmerald,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
