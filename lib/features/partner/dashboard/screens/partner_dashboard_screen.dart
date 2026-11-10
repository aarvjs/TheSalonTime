import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class PartnerDashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final ValueChanged<int>? onNavigateTab;

  const PartnerDashboardScreen({
    super.key,
    this.onOpenDrawer,
    this.onNavigateTab,
  });

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  int _activeBannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<Map<String, String>> _heroBanners = [
    {
      'tag': 'PARTNER PORTAL',
      'title': 'Grow Your Salon Business\nसैलून बिजनेस बढ़ाएं',
      'subtitle': 'Receive customer appointments online & manage branches',
      'image': AssetConstants.maleBanner1,
    },
    {
      'tag': 'DOORSTEP SERVICE',
      'title': 'Doorstep Home Service\nघर पर सर्विस शुरू करें',
      'subtitle': 'Offer professional services at customer homes without owning a salon',
      'image': AssetConstants.partnerLoginIllu,
    },
    {
      'tag': 'EASY DELEGATION',
      'title': 'Assign Branch Managers\nमैनेजर नियुक्त करें',
      'subtitle': 'Delegate daily operations to managers per branch location',
      'image': AssetConstants.rolePartner,
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning (शुभ प्रभात)';
    if (hour < 17) return 'Good Afternoon (शुभ दोपहर)';
    return 'Good Evening (शुभ संध्या)';
  }

  void _showRestrictedActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.copper, size: 24),
            const SizedBox(width: 8),
            Text(
              'Verification Pending',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Your partner account is in Explorer Mode. Publishing salons & live customer bookings require approved verification by The Salon Times Admin.',
          style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Exploring', style: TextStyle(color: AppColors.mutedTextGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.partnerVerificationStatus);
            },
            child: const Text('View Status'),
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
        final isVerified = partner.verificationStatus == PartnerVerificationStatus.approved;
        final recentBookings = state.bookings.take(4).toList();
        final isSalonActive = state.isSalonModelActive;
        final isHomeActive = state.isHomeServiceModelActive;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drawer Burger & The Salon Times Brand
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_rounded, color: AppColors.warmBlack, size: 26),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: widget.onOpenDrawer ?? () => Scaffold.of(context).openDrawer(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'THE SALON TIMES',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.h1(color: AppColors.copper).copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '${_getGreeting()}, ${partner.fullName.isNotEmpty ? partner.fullName.split(' ').first : 'Partner'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification & Profile
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: AppColors.warmBlack),
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.partnerNotifications);
                                },
                              ),
                              if (state.unreadNotificationsCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.copper,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${state.unreadNotificationsCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(3);
                              } else {
                                Navigator.pushNamed(context, AppRoutes.partnerProfile);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.copper.withValues(alpha: 0.15),
                              child: const Icon(Icons.person, color: AppColors.copper, size: 19),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Business Model Selector Pill Tabs
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Row(
                      children: [
                        _buildModelTab(
                          title: 'Physical Salon',
                          hindi: 'सैलून',
                          icon: Icons.storefront_rounded,
                          isSelected: state.activeBusinessModel == PartnerBusinessModel.salon,
                          onTap: () => state.setActiveBusinessModel(PartnerBusinessModel.salon),
                        ),
                        _buildModelTab(
                          title: 'Home Service',
                          hindi: 'घर पर सर्विस',
                          icon: Icons.home_repair_service_rounded,
                          isSelected: state.activeBusinessModel == PartnerBusinessModel.homeService,
                          onTap: () => state.setActiveBusinessModel(PartnerBusinessModel.homeService),
                        ),
                        _buildModelTab(
                          title: 'Both Models',
                          hindi: 'दोनों',
                          icon: Icons.all_inclusive_rounded,
                          isSelected: state.activeBusinessModel == PartnerBusinessModel.both,
                          onTap: () => state.setActiveBusinessModel(PartnerBusinessModel.both),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Verification Required Alert Banner (if pending)
                  if (!isVerified) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.champagneGold, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: Color(0xFFB78103), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Explorer Mode — Verification Pending',
                                  style: AppTextStyles.bodyBold(color: const Color(0xFF7A5600)).copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You are currently exploring in restricted mode. Publishing salon & live bookings unlock once Admin approves your documents.',
                            style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.verified_outlined, size: 14),
                                  label: const Text('Check Verification Status', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.copper,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, AppRoutes.partnerVerificationStatus);
                                  },
                                ),
                              ),
                              if (partner.verificationStatus == PartnerVerificationStatus.notSubmitted) ...[
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.copper,
                                    side: const BorderSide(color: AppColors.copper),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, AppRoutes.partnerVerification);
                                  },
                                  child: const Text('Submit Docs', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Salon Location Filter Dropdown (shown when Salon is active)
                  if (isSalonActive && state.salons.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        // Unique dropdown items to guarantee no duplicate assertion error
                        final Set<String> validDropdownValues = {'all'};
                        final List<DropdownMenuItem<String>> salonDropdownItems = [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(
                              'All Salon Locations (${state.salons.length})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ];

                        for (final s in state.salons) {
                          final sId = s.salonId.trim();
                          if (sId.isNotEmpty && !validDropdownValues.contains(sId)) {
                            validDropdownValues.add(sId);
                            salonDropdownItems.add(
                              DropdownMenuItem(
                                value: sId,
                                child: Text(
                                  '${s.name.isNotEmpty ? s.name : "Salon"} (${s.areaOrCity})',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }
                        }

                        String effectiveSelectedValue = 'all';
                        if (validDropdownValues.contains(state.selectedBranchId)) {
                          effectiveSelectedValue = state.selectedBranchId;
                        } else {
                          for (final s in state.salons) {
                            if (s.branches.any((b) => b.branchId == state.selectedBranchId)) {
                              if (validDropdownValues.contains(s.salonId)) {
                                effectiveSelectedValue = s.salonId;
                                break;
                              }
                            }
                          }
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEBE6DF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront_rounded, color: AppColors.copper, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FILTER BY SALON LOCATION (सैलून चुनें)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mutedTextGray,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: effectiveSelectedValue,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.copper),
                                      onChanged: (val) {
                                        if (val != null) state.selectBranch(val);
                                      },
                                      items: salonDropdownItems,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: const Size(0, 30),
                                ),
                                onPressed: () {
                                  if (!isVerified) {
                                    _showRestrictedActionDialog(context);
                                  } else {
                                    Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
                                  }
                                },
                                child: const Text('+ Add', style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Home Service Quick Status Card (shown when Home Service is active)
                  if (isHomeActive) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            state.homeProfile.isAvailable ? const Color(0xFF1B4F72) : const Color(0xFF2C3E50),
                            const Color(0xFF154360),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.home_repair_service_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Home Service Professional',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'घर पर सर्विस (Doorstep Stylist)',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.8),
                                              fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Online / Offline Switch
                              Switch(
                                value: state.homeProfile.isAvailable,
                                activeThumbColor: Colors.greenAccent,
                                activeTrackColor: Colors.white24,
                                inactiveThumbColor: Colors.white60,
                                inactiveTrackColor: Colors.black26,
                                onChanged: (val) {
                                  state.toggleHomeServiceAvailability(val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildHomeBadge(
                                  icon: Icons.radar_rounded,
                                  label: '${state.homeProfile.serviceRadiusKm.toStringAsFixed(0)} km Radius',
                                ),
                              ),
                              Expanded(
                                child: _buildHomeBadge(
                                  icon: Icons.location_on_outlined,
                                  label: state.homeProfile.baseCity,
                                ),
                              ),
                              Expanded(
                                child: _buildHomeBadge(
                                  icon: Icons.badge_outlined,
                                  label: '${state.homeProfile.experienceYears} Yrs Exp',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Hero Image Banner Carousel
                  SizedBox(
                    height: 155,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: _heroBanners.length,
                      onPageChanged: (i) => setState(() => _activeBannerIndex = i),
                      itemBuilder: (context, index) {
                        final b = _heroBanners[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(b['image']!, fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.85),
                                        Colors.black.withValues(alpha: 0.55),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.copper,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          b['tag']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        b['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 210,
                                        child: Text(
                                          b['subtitle']!,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: 10.5,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Carousel Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _heroBanners.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _activeBannerIndex == i ? 16 : 6,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _activeBannerIndex == i ? AppColors.copper : const Color(0xFFD6D0C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // SECTION: Business Management
                  Text(
                    'Business Management (बिजनेस मैनेजमेंट)',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBusinessHubCard(
                          icon: Icons.storefront_rounded,
                          title: 'My Salons',
                          subtitle: '${state.salons.length} Locations',
                          hindi: 'सैलून लोकेशन्स',
                          color: AppColors.copper,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.partnerBranches),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildBusinessHubCard(
                          icon: Icons.home_repair_service_rounded,
                          title: 'Home Services',
                          subtitle: state.homeProfile.isAvailable ? 'Taking Bookings' : 'Paused',
                          hindi: 'घर पर सेवाएं',
                          color: Colors.teal.shade700,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.partnerHomeService),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBusinessHubCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Earnings & Data',
                          subtitle: '₹${state.todayEarnings.toStringAsFixed(0)} today',
                          hindi: 'कमाई व हिसाब',
                          color: Colors.green.shade800,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.partnerEarnings),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildBusinessHubCard(
                          icon: Icons.manage_accounts_rounded,
                          title: 'Profile & Settings',
                          subtitle: isVerified ? 'Verified Account' : 'Verification Status',
                          hindi: 'प्रोफाइल व सेटिंग्स',
                          color: AppColors.warmBlack,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.partnerProfile),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary Metric Cards (Unified Salon Metrics)
                  Text(
                    state.selectedBranchId == 'all'
                        ? 'Business Summary (कुल हिसाब)'
                        : 'Location Summary: ${state.currentSalon?.name ?? state.currentBranch?.branchName ?? ""}',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Salons',
                          hindi: 'कुल सैलून',
                          value: '${state.salons.length}',
                          icon: Icons.storefront_rounded,
                          color: AppColors.copper,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Active Salons',
                          hindi: 'चालू सैलून',
                          value: '${state.salons.where((s) => s.isActive).length}',
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: state.selectedBranchId == 'all' ? 'Total Bookings' : 'Branch Bookings',
                          hindi: 'कुल बुकिंग',
                          value: '${state.bookings.length}',
                          icon: Icons.calendar_month_rounded,
                          color: Colors.indigo.shade600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Pending Requests',
                          hindi: 'पेंडिंग बुकिंग',
                          value: '${state.pendingBookingsCount}',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.burntOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Active Services',
                          hindi: 'चालू सेवाएं',
                          value: '${state.activeServicesCount}',
                          icon: Icons.spa_outlined,
                          color: AppColors.champagneGold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          title: "Today's Earnings",
                          hindi: 'आज की कमाई',
                          value: '₹${state.todayEarnings.toStringAsFixed(0)}',
                          icon: Icons.payments_outlined,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recent Appointments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Recent Bookings (हाल की बुकिंग)',
                          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.partnerBookings);
                          }
                        },
                        child: const Text('View All', style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  if (recentBookings.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEBE6DF)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No bookings for this branch yet.',
                            style: AppTextStyles.body(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ...recentBookings.map((b) => _buildBookingCard(context, b)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModelTab({
    required String title,
    required String hindi,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.copper : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.mutedTextGray,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.warmBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                hindi,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white70 : AppColors.mutedTextGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBadge({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessHubCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String hindi,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              hindi,
              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String hindi,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                  title,
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            hindi,
            style: AppTextStyles.caption(color: AppColors.copper).copyWith(fontSize: 9, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, PartnerBookingModel b) {
    final isHome = b.bookingType == PartnerBookingType.homeService;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DF)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.partnerBookingDetails,
            arguments: b,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Service Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHome ? const Color(0xFFEBF5FB) : const Color(0xFFF9EBEA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isHome ? Icons.home_rounded : Icons.storefront_rounded,
                        size: 13,
                        color: isHome ? const Color(0xFF1B4F72) : AppColors.copper,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHome ? 'HOME SERVICE (घर पर)' : 'SALON VISIT (दुकान पर)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isHome ? const Color(0xFF1B4F72) : AppColors.copper,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${b.price.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              b.serviceName,
              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Branch: ${b.branchName} • Customer: ${b.customerName}',
                    style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
