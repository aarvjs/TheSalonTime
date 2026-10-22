import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class PartnerProfileScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const PartnerProfileScreen({super.key, this.onOpenDrawer});

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  bool _emailNotifs = true;
  bool _pushNotifs = true;
  bool _bookingAlerts = true;
  bool _homeServiceAlerts = true;

  // Selected avatar preset or uploaded image key
  String? _selectedAvatarAsset;

  final List<Map<String, String>> _avatarPresets = [
    {
      'name': 'Executive Director',
      'asset': AssetConstants.rolePartner,
    },
    {
      'name': 'Master Stylist',
      'asset': AssetConstants.partnerLoginIllu,
    },
    {
      'name': 'Salon Concierge',
      'asset': AssetConstants.roleManager,
    },
    {
      'name': 'Hair Studio',
      'asset': AssetConstants.maleBanner1,
    },
  ];

  void _showPhotoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D0C7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Profile / Salon Image',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a professional avatar or photo for your salon partner profile',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(height: 18),

              // Upload Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Take Photo',
                      subtitle: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        _applyPhoto(AssetConstants.rolePartner, 'Photo captured via Camera');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Upload File',
                      subtitle: 'From Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        _applyPhoto(AssetConstants.partnerLoginIllu, 'Photo selected from Gallery');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Or Select Curated Partner Avatar:',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 10),

              // Curated Presets
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarPresets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _avatarPresets[index];
                    final isSelected = _selectedAvatarAsset == item['asset'];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _applyPhoto(item['asset']!, 'Selected ${item['name']} avatar');
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.copper : const Color(0xFFEBE6DF),
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                item['asset']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['name']!,
                            style: AppTextStyles.caption(
                              color: isSelected ? AppColors.copper : AppColors.charcoal,
                            ).copyWith(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Remove Photo option
              if (_selectedAvatarAsset != null || PartnerState.instance.partner.profilePhoto != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Reset to Initial Letter Avatar', style: TextStyle(color: Colors.red, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedAvatarAsset = null);
                    PartnerState.instance.updatePartnerPhoto('');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.charcoal,
                        content: Text('Avatar reset to default initial.'),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyPhoto(String assetPath, String message) {
    setState(() => _selectedAvatarAsset = assetPath);
    PartnerState.instance.updatePartnerPhoto(assetPath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.copper,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.warmGray,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEBE6DF)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.copper, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13)),
            Text(subtitle, style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(PartnerModel partner) {
    final nameCtrl = TextEditingController(text: partner.fullName);
    final phoneCtrl = TextEditingController(text: partner.phone);
    final businessCtrl = TextEditingController(text: partner.businessName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Edit Partner Profile Details',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Full Name', style: AppTextStyles.caption(color: AppColors.mutedTextGray)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.warmGray,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Text('Contact Phone', style: AppTextStyles.caption(color: AppColors.mutedTextGray)),
              const SizedBox(height: 4),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.warmGray,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Text('Business Trade Name', style: AppTextStyles.caption(color: AppColors.mutedTextGray)),
              const SizedBox(height: 4),
              TextField(
                controller: businessCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.warmGray,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final updated = partner.copyWith(
                fullName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : partner.fullName,
                phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : partner.phone,
                businessName: businessCtrl.text.trim().isNotEmpty ? businessCtrl.text.trim() : partner.businessName,
              );
              PartnerState.instance.updatePartner(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.copper,
                  content: Text('Profile details updated successfully!'),
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partner Help & Concierge Support',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              'Our salon onboarding specialists are available 7 days a week (9 AM - 9 PM).',
              style: AppTextStyles.caption(color: AppColors.mutedTextGray),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_in_talk_rounded, color: AppColors.copper),
              title: const Text('Partner Helpline'),
              subtitle: const Text('1800-SALON-TIMES (Toll Free)'),
              onTap: () => Navigator.pop(ctx),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.green),
              title: const Text('WhatsApp Partner Desk'),
              subtitle: const Text('+91 98765 43210 (Priority Chat)'),
              onTap: () => Navigator.pop(ctx),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined, color: AppColors.copper),
              title: const Text('Support Email'),
              subtitle: const Text('partner-desk@thesalontimes.com'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
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
          'Are you sure you want to exit your business session?',
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final state = PartnerState.instance;
        final partner = state.partner;
        final salon = state.salon;
        final isVerified = partner.verificationStatus == PartnerVerificationStatus.approved;
        final photoToDisplay = _selectedAvatarAsset ?? partner.profilePhoto;

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
              'Partner Profile & Settings',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.copper),
                tooltip: 'Edit Profile',
                onPressed: () => _showEditProfileDialog(partner),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1. Ultra-Luxurious Profile Hero Header Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Banner Background
                      Container(
                        height: 90,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C2C2C), Color(0xFF1B1B1B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              top: -10,
                              child: Icon(
                                Icons.storefront_rounded,
                                size: 100,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.copper,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'THE SALON TIMES • OFFICIAL PARTNER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Overlapping Avatar with Camera Upload Badge
                      Transform.translate(
                        offset: const Offset(0, -38),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: _showPhotoPickerSheet,
                                  child: Container(
                                    padding: const EdgeInsets.all(3.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: AppColors.warmGray,
                                      child: photoToDisplay != null && photoToDisplay.isNotEmpty
                                          ? ClipOval(
                                              child: Image.asset(
                                                photoToDisplay,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Text(
                                              partner.fullName.isNotEmpty ? partner.fullName[0].toUpperCase() : 'P',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.copper,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                // Camera icon button
                                GestureDetector(
                                  onTap: _showPhotoPickerSheet,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.copper,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Partner Full Name & Business
                            Text(
                              partner.fullName,
                              style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              partner.businessName,
                              style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),

                            // Verification & Partner ID Badges
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isVerified ? Colors.green.shade50 : const Color(0xFFFFF7E6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isVerified ? Colors.green.shade400 : AppColors.champagneGold,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                        size: 13,
                                        color: isVerified ? Colors.green.shade700 : const Color(0xFFB78103),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isVerified ? 'VERIFIED SALON PARTNER' : 'VERIFICATION IN PROGRESS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isVerified ? Colors.green.shade800 : const Color(0xFF7A5600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ID: TS-PTN-8291',
                                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Upload / Change Photo trigger button
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                              label: Text(
                                photoToDisplay != null ? 'Change Profile Image' : 'Upload Salon / Profile Image',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.copper,
                                side: const BorderSide(color: AppColors.copper, width: 1.2),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: _showPhotoPickerSheet,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Salon Business Performance Stats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          label: 'Total Bookings',
                          value: '${state.bookings.length + 138}',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                      Container(height: 34, width: 1, color: const Color(0xFFEBE6DF)),
                      Expanded(
                        child: _buildStatColumn(
                          label: 'Active Services',
                          value: '${state.activeServicesCount}',
                          icon: Icons.spa_outlined,
                        ),
                      ),
                      Container(height: 34, width: 1, color: const Color(0xFFEBE6DF)),
                      Expanded(
                        child: _buildStatColumn(
                          label: 'Branches',
                          value: '${state.branches.length}',
                          icon: Icons.store_mall_directory_outlined,
                        ),
                      ),
                      Container(height: 34, width: 1, color: const Color(0xFFEBE6DF)),
                      Expanded(
                        child: _buildStatColumn(
                          label: 'Partner Rating',
                          value: '4.9 ★',
                          icon: Icons.star_rate_rounded,
                          valueColor: const Color(0xFFB78103),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Salon Entity Snapshot Card
                _buildSectionHeader('Registered Salon Entity'),
                const SizedBox(height: 8),
                Container(
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
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.copper.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.storefront_rounded, color: AppColors.copper, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        salon.name,
                                        style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        salon.category,
                                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.partnerSalonDetails);
                            },
                            child: const Text('Details', style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 18, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.location_on_outlined, 'Primary Address', '${salon.address}, ${salon.city}'),
                      const SizedBox(height: 8),
                      _buildInfoTile(Icons.access_time_rounded, 'Salon Timings', '${salon.openingHours} - ${salon.closingHours}'),
                      const SizedBox(height: 8),
                      _buildInfoTile(
                        Icons.home_repair_service_outlined,
                        'Doorstep Service',
                        state.homeService.isEnabled ? 'Enabled (${state.homeService.serviceRadiusKm.toInt()} km radius)' : 'Disabled',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.warmBlack,
                                side: const BorderSide(color: Color(0xFFD6D0C7)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.partnerBranches);
                              },
                              child: const Text('Manage Branches', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.copper,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.partnerEditSalon);
                              },
                              child: const Text('Edit Salon Info', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Business Contact Information
                _buildSectionHeader('Partner Contact & Business Records'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(Icons.person_outline_rounded, 'Registered Owner', partner.fullName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.mail_outline_rounded, 'Business Email', partner.email),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.phone_outlined, 'Registered Phone', partner.phone),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.badge_outlined, 'Business Legal Name', partner.businessName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildInfoTile(Icons.domain_verification_rounded, 'Verification Status', isVerified ? 'Verified & Approved' : 'Submitted (Reviewing)'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 5. Operational Alerts & Preferences
                _buildSectionHeader('Communication & Operational Alerts'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Instant Booking Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Push alerts when customers book appointments', style: TextStyle(fontSize: 11)),
                        value: _bookingAlerts,
                        activeThumbColor: AppColors.copper,
                        onChanged: (val) => setState(() => _bookingAlerts = val),
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Doorstep Service Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Real-time alerts for home service bookings', style: TextStyle(fontSize: 11)),
                        value: _homeServiceAlerts,
                        activeThumbColor: AppColors.copper,
                        onChanged: (val) => setState(() => _homeServiceAlerts = val),
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Push Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Receive sound alerts for cancellations & updates', style: TextStyle(fontSize: 11)),
                        value: _pushNotifs,
                        activeThumbColor: AppColors.copper,
                        onChanged: (val) => setState(() => _pushNotifs = val),
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Daily Earnings Digest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Receive summary of daily revenue and footfall', style: TextStyle(fontSize: 11)),
                        value: _emailNotifs,
                        activeThumbColor: AppColors.copper,
                        onChanged: (val) => setState(() => _emailNotifs = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 6. Concierge, Legal & Demo Tools
                _buildSectionHeader('Support & Legal'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.support_agent_rounded, color: AppColors.copper),
                        title: const Text('Partner Helpline & Concierge', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Toll free phone, email & WhatsApp desk', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedTextGray),
                        onTap: _showHelpModal,
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      ListTile(
                        leading: const Icon(Icons.verified_user_outlined, color: AppColors.copper),
                        title: const Text('Verification Documents', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('View uploaded Aadhaar, GST & trade license', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedTextGray),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.partnerVerificationStatus);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      ListTile(
                        leading: const Icon(Icons.description_outlined, color: AppColors.copper),
                        title: const Text('Partner Terms of Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedTextGray),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening The Salon Times Partner Agreement...')),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      ListTile(
                        leading: const Icon(Icons.restart_alt_rounded, color: AppColors.copper),
                        title: const Text('Reset Demo State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Reverts local appointments and mock catalog', style: TextStyle(fontSize: 11)),
                        onTap: () {
                          PartnerState.instance.resetDefaults();
                          setState(() => _selectedAvatarAsset = null);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.copper,
                              content: Text('Partner state reset to standard demo defaults.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 7. Sign Out Button
                AppButton(
                  text: 'Sign Out of Partner Portal',
                  isOutlined: true,
                  backgroundColor: Colors.red.shade600,
                  textColor: Colors.red.shade600,
                  icon: Icons.logout_rounded,
                  onPressed: _confirmLogout,
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

  Widget _buildStatColumn({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.copper),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h2(color: valueColor ?? AppColors.warmBlack).copyWith(fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.copper, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
