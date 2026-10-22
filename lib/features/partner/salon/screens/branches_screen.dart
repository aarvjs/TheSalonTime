import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  void _showAddBranchSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Kanpur');
    final phoneCtrl = TextEditingController();
    bool enableHome = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Salon Branch',
                          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Branch Name',
                        hintText: 'e.g. Kakadeo Outpost',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Street Address',
                        hintText: 'Shop No, Commercial Road',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Branch Phone',
                              hintText: '+91 512...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable Home Service for this branch'),
                      value: enableHome,
                      activeThumbColor: AppColors.copper,
                      onChanged: (val) => setSheetState(() => enableHome = val),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Create Branch',
                      backgroundColor: AppColors.copper,
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final newBranch = BranchModel(
                          branchId: 'branch_${DateTime.now().millisecondsSinceEpoch}',
                          branchName: nameCtrl.text.trim(),
                          address: addressCtrl.text.trim().isNotEmpty
                              ? addressCtrl.text.trim()
                              : 'Commercial Plaza, ${cityCtrl.text}',
                          city: cityCtrl.text.trim(),
                          state: 'Uttar Pradesh',
                          postalCode: '208005',
                          phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+91 99000 11223',
                          email: 'branch@velvetsalon.com',
                          latitude: 26.4800,
                          longitude: 80.3200,
                          isHomeServiceEnabled: enableHome,
                          isActive: true,
                        );

                        PartnerState.instance.addBranch(newBranch);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.copper,
                            content: Text('Branch "${newBranch.branchName}" created!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final branches = PartnerState.instance.branches;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Salon Branches (${branches.length})',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Info Banner
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
                        child: const Icon(Icons.alt_route_rounded, color: AppColors.copper, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Multi-Branch Management',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                            ),
                            Text(
                              'Each branch has dedicated managers, appointments, and operating hours.',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Branch Cards List
                ...branches.map((b) => _buildBranchCard(context, b)),

                const SizedBox(height: 16),
                AppButton(
                  text: 'Add Another Branch',
                  icon: Icons.add_rounded,
                  backgroundColor: AppColors.copper,
                  onPressed: () => _showAddBranchSheet(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchCard(BuildContext context, BranchModel branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  branch.branchName,
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: branch.isActive ? Colors.green.shade50 : AppColors.warmGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  branch.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: branch.isActive ? Colors.green.shade800 : AppColors.mutedTextGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.copper),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${branch.address}, ${branch.city}',
                  style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 15, color: AppColors.mutedTextGray),
                  const SizedBox(width: 6),
                  Text(
                    branch.managerName != null ? 'Manager: ${branch.managerName}' : 'No Manager Assigned',
                    style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                      fontWeight: branch.managerName != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    branch.isHomeServiceEnabled ? Icons.home_work_rounded : Icons.storefront_rounded,
                    size: 15,
                    color: branch.isHomeServiceEnabled ? Colors.green.shade700 : AppColors.mutedTextGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    branch.isHomeServiceEnabled ? 'Home Service ON' : 'Salon Only',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: branch.isHomeServiceEnabled ? Colors.green.shade800 : AppColors.mutedTextGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
