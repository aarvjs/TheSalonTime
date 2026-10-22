import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final managers = PartnerState.instance.managers;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Staff & Branch Managers (${managers.length})',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.copper),
                tooltip: 'Add Branch Manager',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.partnerCreateManager);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Info Notice Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.copper.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.copper, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Branch-Level Permissions',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                            ),
                            Text(
                              'Branch managers are delegated to supervise daily appointments and staff for their assigned branch.',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Manager Cards List
                ...managers.map((m) => _buildManagerCard(context, m)),

                const SizedBox(height: 16),
                AppButton(
                  text: 'Add Another Branch Manager',
                  icon: Icons.person_add_rounded,
                  backgroundColor: AppColors.copper,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.partnerCreateManager);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManagerCard(BuildContext context, BranchManagerModel manager) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.copper.withValues(alpha: 0.12),
                    child: Text(
                      manager.fullName.isNotEmpty ? manager.fullName[0] : 'M',
                      style: const TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager.fullName,
                        style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 15),
                      ),
                      Text(
                        'Branch Manager',
                        style: AppTextStyles.caption(color: AppColors.copper).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: manager.isActive ? Colors.green.shade50 : AppColors.warmGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  manager.isActive ? 'Active' : 'Suspended',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: manager.isActive ? Colors.green.shade800 : AppColors.mutedTextGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 10),

          // Assigned branch
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 16, color: AppColors.mutedTextGray),
              const SizedBox(width: 6),
              Text(
                'Assigned Branch:',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  manager.assignedBranchName,
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Contact details
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 15, color: AppColors.mutedTextGray),
              const SizedBox(width: 6),
              Text(
                manager.phone,
                style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.email_outlined, size: 15, color: AppColors.mutedTextGray),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  manager.email,
                  style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: manager.isActive ? Colors.red.shade600 : Colors.green.shade700,
                  side: BorderSide(
                    color: manager.isActive ? Colors.red.shade300 : Colors.green.shade400,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () {
                  PartnerState.instance.toggleManagerStatus(manager.managerId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.copper,
                      content: Text(
                        'Manager ${manager.fullName} status updated to ${!manager.isActive ? "Active" : "Suspended"}.',
                      ),
                    ),
                  );
                },
                child: Text(
                  manager.isActive ? 'Deactivate' : 'Reactivate',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
