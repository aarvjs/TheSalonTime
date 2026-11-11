import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';
import 'add_service_screen.dart';

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
    'Spa & Wellness',
    'Bridal & Groom',
  ];

  void _showDeleteConfirmation(BuildContext context, String salonId, SalonServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Service?',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to remove "${service.name}" from this salon location? Existing bookings will preserve their historical price and service details.',
          style: TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PartnerState.instance.deleteServiceFromSalon(salonId, service.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.burntOrange,
                  content: Text('Service "${service.name}" deleted.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final partnerState = PartnerState.instance;
        final salons = partnerState.salons;
        final selectedSalonId = partnerState.selectedServiceSalonId;
        final selectedSalon = salons.where((s) => s.salonId == selectedSalonId).firstOrNull ??
            (salons.isNotEmpty ? salons.first : null);

        final salonServices = partnerState.currentSalonServices;
        final filteredServices = _selectedCategory == 'All'
            ? salonServices
            : salonServices.where((s) => s.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

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
              'Salon Services (${salonServices.length})',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.copper, size: 26),
                tooltip: 'Add New Service',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServiceScreen(targetSalon: selectedSalon),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SALON LOCATION SELECTOR (Independent Salon Management)
                if (salons.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 16, color: AppColors.copper),
                            const SizedBox(width: 6),
                            const Text(
                              'MANAGING SALON LOCATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.copper,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedSalon?.salonId ?? (salons.isNotEmpty ? salons.first.salonId : ''),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.warmBlack),
                            items: salons.map((salon) {
                              return DropdownMenuItem<String>(
                                value: salon.salonId,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      salon.name,
                                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${salon.address}, ${salon.city}',
                                      style: TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newSalonId) {
                              if (newSalonId != null) {
                                partnerState.setSelectedServiceSalon(newSalonId);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 2. Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                const SizedBox(height: 8),

                // 3. Salon-Specific Services List
                Expanded(
                  child: filteredServices.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.spa_outlined, size: 52, color: AppColors.mutedTextGray),
                                const SizedBox(height: 14),
                                Text(
                                  salonServices.isEmpty
                                      ? 'No services configured for ${selectedSalon?.name ?? 'this salon'}'
                                      : 'No services found in "$_selectedCategory"',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add services such as Haircut, Beard Trim, Facial, or Hair Colour specifically for this location.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedTextGray),
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.copper,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Add First Service', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddServiceScreen(targetSalon: selectedSalon),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return _buildServiceCard(context, service, selectedSalon?.salonId ?? '');
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddServiceScreen(targetSalon: selectedSalon),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, SalonServiceModel service, String salonId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Header Row: Category Badge & Status Switch
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
                    fontSize: 10.5,
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
                        PartnerState.instance.toggleServiceStatusInSalon(salonId, service.id);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content Row: Service Image + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image (if uploaded)
              if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                Container(
                  width: 58,
                  height: 58,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: AppImage(
                      imagePath: service.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (service.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        service.description,
                        style: TextStyle(fontSize: 12, color: AppColors.charcoal, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Footer Row: Duration, Pricing, Edit & Delete Actions
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: AppColors.mutedTextGray),
              const SizedBox(width: 4),
              Text(
                '${service.durationMinutes} mins',
                style: TextStyle(fontSize: 12, color: AppColors.mutedTextGray, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              if (service.availableAtHome)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Home Service',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
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
              const SizedBox(width: 10),

              // Edit Action
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.copper),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit Service',
                onPressed: () {
                  final targetSalon = PartnerState.instance.salons.where((s) => s.salonId == salonId).firstOrNull;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServiceScreen(
                        targetSalon: targetSalon,
                        serviceToEdit: service,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),

              // Delete Action
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.errorRed),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete Service',
                onPressed: () => _showDeleteConfirmation(context, salonId, service),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
