import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class ServicesScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const ServicesScreen({super.key, this.onOpenDrawer});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Hair Care',
    'Skin Care',
    'Beard & Shave',
    'Hands & Feet',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final allServices = PartnerState.instance.services;
        final filteredServices = _selectedCategory == 'All'
            ? allServices
            : allServices.where((s) => s.category == _selectedCategory).toList();

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
              'Services & Catalog (${allServices.length})',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.copper, size: 26),
                tooltip: 'Add New Service',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.partnerAddService);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.copper,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.charcoal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.copper : const Color(0xFFEBE6DF),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),

                // Services List
                Expanded(
                  child: filteredServices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.spa_outlined, size: 48, color: AppColors.mutedTextGray),
                              const SizedBox(height: 12),
                              Text(
                                'No services in this category',
                                style: AppTextStyles.bodyBold(color: AppColors.warmBlack),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return _buildServiceCard(context, service);
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.copper,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.partnerAddService);
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, SalonServiceModel service) {
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
          // Header Row: Category & Status Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warmGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  service.category,
                  style: AppTextStyles.caption(color: AppColors.copper).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    service.isActive ? 'Active' : 'Hidden',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: service.isActive ? Colors.green.shade700 : AppColors.mutedTextGray,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: service.isActive,
                      activeThumbColor: AppColors.copper,
                      onChanged: (val) {
                        PartnerState.instance.toggleServiceStatus(service.id);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Service Title
          Text(
            service.name,
            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12, height: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Duration & Pricing
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: AppColors.mutedTextGray),
              const SizedBox(width: 4),
              Text(
                '${service.durationMinutes} mins',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
              ),
              const Spacer(),
              if (service.offerPrice != null) ...[
                Text(
                  '₹${service.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.mutedTextGray,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '₹${service.offerPrice!.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 16),
                ),
              ] else
                Text(
                  '₹${service.price.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 16),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 10),

          // Availability Badges & Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  if (service.availableAtSalon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.copper.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storefront_rounded, size: 12, color: AppColors.copper),
                          SizedBox(width: 4),
                          Text('Salon Visit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.copper)),
                        ],
                      ),
                    ),
                  if (service.availableAtHome)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_work_rounded, size: 12, color: Colors.green.shade800),
                          const SizedBox(width: 4),
                          Text('Home Service', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                        ],
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.partnerEditSalon, // Or add/edit modal
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 15, color: AppColors.copper),
                      const SizedBox(width: 4),
                      Text('Edit', style: TextStyle(color: AppColors.copper, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
