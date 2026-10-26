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
      'subtitle': 'Send stylists to customers & earn up to 50% more revenue',
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
          'Your partner account is in Explorer Mode. Creating salons and publishing services to customers requires an approved verification by The Salon Times Admin.',
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
        final salon = state.salon;
        final isVerified = partner.verificationStatus == PartnerVerificationStatus.approved;
        final recentBookings = state.bookings.take(3).toList();

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
                                widget.onNavigateTab!(3); // Navigate to Profile tab
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

                  // 1. Zomato-Style Hero Image Banner Carousel
                  SizedBox(
                    height: 165,
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
                                Image.asset(
                                  b['image']!,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.85),
                                        Colors.black.withValues(alpha: 0.60),
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
                                          fontSize: 15,
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
                                            fontSize: 11,
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
                  const SizedBox(height: 8),

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

                  // 2. High-Impact "CREATE / SETUP SALON" Action Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.copper,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.add_business_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Setup / Create Salon',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'सैलून सेटअप करें (Address, Map & Timings)',
                                style: TextStyle(
                                  color: AppColors.champagneGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.copper,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size(0, 32),
                                ),
                                onPressed: () {
                                  if (!isVerified) {
                                    _showRestrictedActionDialog(context);
                                  } else {
                                    Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
                                  }
                                },
                                child: const Text(
                                  '+ Create Salon Now',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Salon Overview Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
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
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                AssetConstants.partnerLoginIllu,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    salon.name,
                                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${salon.address}, ${salon.city}',
                                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isVerified ? Colors.green.shade50 : AppColors.champagneGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isVerified ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isVerified ? Colors.green.shade800 : const Color(0xFF9E7D1A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEBE6DF)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Salon Open (दुकान चालू)',
                                      style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    salon.isHomeServiceEnabled ? Icons.check_circle_outline : Icons.cancel_outlined,
                                    size: 14,
                                    color: salon.isHomeServiceEnabled ? Colors.green : AppColors.mutedTextGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Home Service: ${salon.isHomeServiceEnabled ? "ON" : "OFF"}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: salon.isHomeServiceEnabled ? Colors.green.shade800 : AppColors.mutedTextGray,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Quick Actions (With Clear Vernacular Labels)
                  Text(
                    'Quick Actions (शॉर्टकट)',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickCard(
                        icon: Icons.add_business_rounded,
                        label: 'Create Salon',
                        hindi: '+ सैलून जोड़ें',
                        color: AppColors.copper,
                        onTap: () {
                          if (!isVerified) {
                            _showRestrictedActionDialog(context);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
                          }
                        },
                      ),
                      _buildQuickCard(
                        icon: Icons.spa_rounded,
                        label: 'Services',
                        hindi: 'सेवाएं व रेट',
                        color: AppColors.champagneGold,
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(2);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.partnerServices);
                          }
                        },
                      ),
                      _buildQuickCard(
                        icon: Icons.home_repair_service_rounded,
                        label: 'Home Service',
                        hindi: 'घर पर सर्विस',
                        color: Colors.green.shade700,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.partnerHomeService),
                      ),
                      _buildQuickCard(
                        icon: Icons.alt_route_rounded,
                        label: 'Branches',
                        hindi: 'ब्रांच देखें',
                        color: AppColors.burntOrange,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.partnerBranches),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. 4 Summary Metric Cards
                  Text(
                    'Business Summary (आज का हिसाब)',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: "Today's Bookings",
                          hindi: 'आज की बुकिंग',
                          value: '${state.todayBookingsCount}',
                          icon: Icons.calendar_today_rounded,
                          color: AppColors.copper,
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

                  // 6. Recent Appointments Section
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEBE6DF)),
                      ),
                      child: const Center(child: Text('No bookings yet.')),
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

  Widget _buildQuickCard({
    required IconData icon,
    required String label,
    required String hindi,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE6DF)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              hindi,
              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
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
                    'Customer: ${b.customerName} • Ref: ${b.bookingRef}',
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
