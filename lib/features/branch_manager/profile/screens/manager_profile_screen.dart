import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/branch_manager_state.dart';

class ManagerProfileScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const ManagerProfileScreen({super.key, this.onOpenDrawer});

  void _confirmLogout(BuildContext context) {
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
          'Are you sure you want to end your manager session for this branch?',
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
    return ListenableBuilder(
      listenable: BranchManagerState.instance,
      builder: (context, _) {
        final state = BranchManagerState.instance;
        final session = state.session;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            leading: onOpenDrawer != null
                ? IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.warmBlack),
                    onPressed: onOpenDrawer,
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: Text(
              'Manager Profile',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // Manager Avatar Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
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
                        width: 64,
                        height: 64,
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.managerName,
                              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              session.role,
                              style: AppTextStyles.caption(color: AppColors.managerEmerald).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade700,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ACTIVE ASSIGNMENT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Read-Only Status Notice Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.champagneGold),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock_outlined, size: 16, color: Color(0xFF9E7D1A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Read-Only Business Profile: Role permissions and salon associations are managed by Partner ${session.assignedPartnerName}.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Assigned Branch Information Card
                _buildSectionHeader('Assigned Branch Details'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDFE7E2)),
                  ),
                  child: Column(
                    children: [
                      // Branch Facade Image Preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.asset(
                              session.assignedBranchImage,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.managerEmerald.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.verified_rounded, size: 12, color: AppColors.managerGold),
                                    SizedBox(width: 4),
                                    Text('Verified Branch', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(Icons.storefront_outlined, 'Salon Name', session.assignedSalonName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.store_mall_directory_outlined, 'Assigned Branch', session.assignedBranchName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.pin_drop_outlined, 'Branch Address', session.assignedBranchAddress),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.access_time_rounded, 'Operating Hours', session.openingHours),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.verified_user_outlined, 'Operating Status', session.operatingStatus),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Manager Contact Information
                _buildSectionHeader('Manager Contact Details'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDFE7E2)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(Icons.email_outlined, 'Manager Email', session.email),
                      const Divider(height: 16, color: Color(0xFFDFE7E2)),
                      _buildInfoTile(Icons.phone_outlined, 'Mobile Number', session.phone),
                      const Divider(height: 16, color: Color(0xFFDFE7E2)),
                      _buildInfoTile(Icons.badge_outlined, 'Manager ID', session.managerId.toUpperCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reset Demo State
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDFE7E2)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: AppColors.managerEmerald),
                    title: const Text('Reset Branch Demo State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Reverts local booking updates and history', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      BranchManagerState.instance.resetDefaults();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.managerEmerald,
                          content: Text('Branch demo state reset to default bookings and staff.'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),

                // Logout Button
                AppButton(
                  text: 'Sign Out of Branch Console',
                  isOutlined: true,
                  backgroundColor: Colors.red.shade600,
                  textColor: Colors.red.shade600,
                  icon: Icons.logout_rounded,
                  onPressed: () => _confirmLogout(context),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.managerEmerald, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
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
