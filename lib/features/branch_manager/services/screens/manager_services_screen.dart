import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/branch_manager_state.dart';
import '../../models/branch_manager_models.dart';

class ManagerServicesScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const ManagerServicesScreen({super.key, this.onOpenDrawer});

  @override
  State<ManagerServicesScreen> createState() => _ManagerServicesScreenState();
}

class _ManagerServicesScreenState extends State<ManagerServicesScreen> {
  String _selectedCategory = 'All';

  void _showServiceDetails(BranchManagerServiceModel service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D0C7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: service.isActive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.isActive ? 'ACTIVE SERVICE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: service.isActive ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Category: ${service.category} • Duration: ${service.durationMinutes} mins',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '₹${service.price.toInt()}',
                    style: AppTextStyles.h1(color: AppColors.managerEmerald).copyWith(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(Standard catalog price)',
                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFEBE6DF)),
              Text(
                'Service Channels:',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChannelPill('Salon Visit', service.salonVisitAvailable),
                  const SizedBox(width: 8),
                  _buildChannelPill('Home Service', service.homeServiceAvailable),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.champagneGold),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: Color(0xFF9E7D1A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Read-Only: Catalog, pricing and service permissions are managed directly by your Salon Partner.',
                        style: AppTextStyles.caption(color: Colors.amber.shade900).copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelPill(String label, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : AppColors.warmGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isAvailable ? Colors.green.shade200 : const Color(0xFFD6D0C7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 13,
            color: isAvailable ? Colors.green.shade700 : AppColors.mutedTextGray,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.green.shade800 : AppColors.mutedTextGray,
            ),
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
        final allServices = state.services;

        final categories = ['All', ...allServices.map((s) => s.category).toSet()];

        final list = allServices.where((s) {
          if (_selectedCategory == 'All') return true;
          return s.category == _selectedCategory;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            leading: widget.onOpenDrawer != null
                ? IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.warmBlack),
                    onPressed: widget.onOpenDrawer,
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: Text(
              'Branch Services',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Read-Only Partner Notice Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.champagneGold),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF9E7D1A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'View-Only Catalog: Services and prices are controlled by the Salon Partner.',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Filter Chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = categories[i];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.managerEmerald,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.charcoal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.managerEmerald : const Color(0xFFDFE7E2),
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Services List
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
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
                            // Service Image Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),

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
                                          item.name,
                                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.isActive ? 'ACTIVE' : 'INACTIVE',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: item.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.category} • ${item.durationMinutes} mins',
                                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${item.price.toInt()}',
                                        style: AppTextStyles.h2(color: AppColors.managerEmerald).copyWith(fontSize: 15),
                                      ),
                                      InkWell(
                                        onTap: () => _showServiceDetails(item),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.warmGray,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: const [
                                              Text(
                                                'View Info',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(Icons.chevron_right_rounded, size: 13, color: AppColors.charcoal),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
