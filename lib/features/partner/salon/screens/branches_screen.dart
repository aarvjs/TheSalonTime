import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';
import '../../services/manager_auth_service.dart';

typedef MySalonsScreen = BranchesScreen;

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  void _showAssignManagerModal(BuildContext context, SalonModel salon) {
    final managers = PartnerState.instance.managers;
    String? selectedManagerId = salon.assignedManagerUid;
    String? selectedManagerName = salon.managerName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                          'Assign Salon Manager',
                          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assign operational manager to: ${salon.name}',
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                    ),
                    const SizedBox(height: 16),

                    if (managers.isNotEmpty) ...[
                      const Text(
                        'Select Existing Manager',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack),
                      ),
                      const SizedBox(height: 8),
                      ...managers.map((m) {
                        final isSelected = selectedManagerId == m.managerId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.copper.withValues(alpha: 0.06) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.copper : const Color(0xFFEBE6DF),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? AppColors.copper : AppColors.warmGray,
                              foregroundColor: isSelected ? Colors.white : AppColors.warmBlack,
                              child: const Icon(Icons.person, size: 20),
                            ),
                            title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${m.phone} • ${m.email}', style: const TextStyle(fontSize: 11)),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.copper)
                                : null,
                            onTap: () {
                              setModalState(() {
                                selectedManagerId = m.managerId;
                                selectedManagerName = m.fullName;
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Confirm Manager Assignment',
                        backgroundColor: AppColors.copper,
                        onPressed: selectedManagerId == null
                            ? null
                            : () async {
                                final partner = PartnerState.instance.partner;
                                try {
                                  await ManagerAuthService.instance.assignExistingManager(
                                    salonId: salon.salonId,
                                    salonName: salon.name,
                                    managerId: selectedManagerId!,
                                    managerName: selectedManagerName ?? 'Assigned Manager',
                                    partnerId: partner.id,
                                  );
                                } catch (_) {}
                                PartnerState.instance.assignManagerToSalon(
                                  salonId: salon.salonId,
                                  managerId: selectedManagerId!,
                                  managerName: selectedManagerName ?? 'Assigned Manager',
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.copper,
                                      content: Text('Manager "$selectedManagerName" assigned to ${salon.name}!'),
                                    ),
                                  );
                                }
                              },
                      ),
                      if (salon.assignedManagerUid != null && salon.assignedManagerUid!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.burntOrange,
                            side: const BorderSide(color: AppColors.burntOrange),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.person_remove_rounded, size: 18),
                          label: const Text('Unassign Current Manager', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            try {
                              await ManagerAuthService.instance.unassignManager(
                                salonId: salon.salonId,
                                managerId: salon.assignedManagerUid!,
                              );
                            } catch (_) {}
                            PartnerState.instance.assignManagerToSalon(
                              salonId: salon.salonId,
                              managerId: '',
                              managerName: '',
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.charcoal,
                                  content: Text('Manager unassigned from salon.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEBE6DF)),
                      const SizedBox(height: 8),
                    ],

                    // Button to create brand-new manager account
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.copper,
                        side: const BorderSide(color: AppColors.copper),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('+ Create New Manager Account', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.partnerCreateManager,
                          arguments: {
                            'salonId': salon.salonId,
                            'salonName': salon.name,
                          },
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
        final salons = PartnerState.instance.salons;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'My Salons (${salons.length})',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.copper),
                tooltip: 'Add Salon Location',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
                },
              ),
            ],
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
                        child: const Icon(Icons.storefront_rounded, color: AppColors.copper, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Salons / Salon Locations',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                            ),
                            Text(
                              'Manage each independent salon location, opening hours, Google Maps pin, and delegated manager.',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Salon Location Cards List
                ...salons.map((s) => _buildSalonCard(context, s)),

                const SizedBox(height: 16),
                AppButton(
                  text: 'Add Another Salon Location',
                  icon: Icons.add_rounded,
                  backgroundColor: AppColors.copper,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
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

  Widget _buildSalonCard(BuildContext context, SalonModel salon) {
    final hasManager = (salon.assignedManagerUid != null && salon.assignedManagerUid!.isNotEmpty) ||
        (salon.managerName != null && salon.managerName!.isNotEmpty);
    final displayManagerName = (salon.managerName != null && salon.managerName!.isNotEmpty)
        ? salon.managerName!
        : 'Assigned Manager';
    final photo = salon.photos.isNotEmpty ? salon.photos.first : AssetConstants.maleBanner1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Photo & Status Switch
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: AppImage(imagePath: photo, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    salon.category,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        salon.isActive ? 'Active' : 'Paused',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: salon.isActive ? Colors.green.shade800 : AppColors.mutedTextGray,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: salon.isActive,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.green.shade100,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          PartnerState.instance.toggleSalonStatus(salon.salonId);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon.name,
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.copper),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        salon.address,
                        style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Manager & Radius Badges Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: hasManager ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasManager ? Icons.verified_user_rounded : Icons.person_outline_rounded,
                              size: 16,
                              color: hasManager ? Colors.green.shade800 : AppColors.burntOrange,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                hasManager ? 'Manager: $displayManagerName' : 'No Manager Assigned',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: hasManager ? Colors.green.shade800 : AppColors.burntOrange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.radar_rounded, size: 14, color: AppColors.copper),
                          const SizedBox(width: 4),
                          Text(
                            '${salon.serviceRadiusKm.toStringAsFixed(0)} km',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warmBlack),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFEBE6DF), height: 1),
                const SizedBox(height: 10),

                // Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.copper,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                      label: Text(hasManager ? 'Change Manager' : 'Assign Manager', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showAssignManagerModal(context, salon),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.warmBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.calendar_today_rounded, size: 14),
                      label: const Text('Bookings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        PartnerState.instance.selectBranch(salon.salonId);
                        Navigator.pushNamed(context, AppRoutes.partnerBookings);
                      },
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
