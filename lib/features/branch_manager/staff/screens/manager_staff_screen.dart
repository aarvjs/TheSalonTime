import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/branch_manager_state.dart';
import '../../models/branch_manager_models.dart';

class ManagerStaffScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const ManagerStaffScreen({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BranchManagerState.instance,
      builder: (context, _) {
        final state = BranchManagerState.instance;
        final staffList = state.staff;
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
              'Branch Staff Directory',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Read-Only Delegation Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.champagneGold),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF9E7D1A)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'View-Only Staff Directory: Stylist onboarding, payroll and branch transfers are controlled by Salon Partner (${session.assignedPartnerName}).',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Assigned Branch Info Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stylists at ${session.assignedBranchName}',
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 14),
                    ),
                    Text(
                      '${staffList.length} Professionals',
                      style: AppTextStyles.caption(color: AppColors.managerEmerald).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Staff Cards List
                ...staffList.map((member) => _buildStaffCard(context, member, session.assignedBranchName)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffCard(BuildContext context, BranchManagerStaffModel member, String branchName) {
    Color availBg = Colors.green.shade50;
    Color availFg = Colors.green.shade800;

    if (member.availability == 'On Duty') {
      availBg = AppColors.managerEmeraldBg;
      availFg = AppColors.managerEmerald;
    } else if (member.availability == 'On Break') {
      availBg = const Color(0xFFFFF9E6);
      availFg = const Color(0xFFB78103);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Staff Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEBE6DF), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                member.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: availBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        member.availability.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: availFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Rating and Experience
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rate_rounded, size: 14, color: Color(0xFFB78103)),
                        const SizedBox(width: 2),
                        Text(
                          '${member.rating}',
                          style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '• ${member.experienceYears} Years Exp.',
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '• ${member.phone}',
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
