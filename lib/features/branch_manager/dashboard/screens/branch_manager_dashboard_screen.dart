import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/branch_manager_state.dart';
import '../../models/branch_manager_models.dart';

class BranchManagerDashboardScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  final ValueChanged<int>? onNavigateTab;

  const BranchManagerDashboardScreen({
    super.key,
    this.onOpenDrawer,
    this.onNavigateTab,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BranchManagerState.instance,
      builder: (context, _) {
        final state = BranchManagerState.instance;
        final session = state.session;
        final appointments = state.todayAppointments;
        final activities = state.activities.take(4).toList();

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu_rounded, color: AppColors.warmBlack, size: 26),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onOpenDrawer ?? () => Scaffold.of(context).openDrawer(),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'THE SALON TIMES',
                                style: AppTextStyles.h1(color: AppColors.managerEmerald).copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              Text(
                                '${_getGreeting()}, ${session.managerName.split(' ').first}',
                                style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: AppColors.warmBlack),
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.managerNotifications);
                                },
                              ),
                              if (state.unreadNotificationsCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.managerEmerald,
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
                              if (onNavigateTab != null) {
                                onNavigateTab!(3); // Navigate to Profile tab
                              } else {
                                Navigator.pushNamed(context, AppRoutes.managerProfile);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.managerEmeraldBg,
                              child: const Icon(Icons.person, color: AppColors.managerEmerald, size: 19),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. High-Impact Hero Salon Image Showcase Banner
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Salon Photo Banner with Badges
                        SizedBox(
                          height: 155,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  session.assignedBranchImage,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.25),
                                        Colors.black.withValues(alpha: 0.80),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.managerEmerald,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '✦ ASSIGNED BRANCH OPS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.greenAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'OPEN TODAY',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 14,
                                  right: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.assignedSalonName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.store_mall_directory_rounded, size: 13, color: AppColors.managerGold),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              session.assignedBranchName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Lower Info Section
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.managerEmerald),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      session.assignedBranchAddress,
                                      style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 13, color: AppColors.mutedTextGray),
                                      const SizedBox(width: 4),
                                      Text(
                                        session.openingHours,
                                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.managerGoldLight,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.managerGold.withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.shield_outlined, size: 11, color: AppColors.managerGold),
                                        SizedBox(width: 3),
                                        Text(
                                          'Read-Only Business Profile',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8A6C1C),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Summary Operational Cards
                  _buildSectionHeader('Today\'s Operations Summary'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Today',
                          value: '${state.todayBookingsCount}',
                          icon: Icons.calendar_month_outlined,
                          color: AppColors.managerEmerald,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Pending',
                          value: '${state.pendingBookingsCount}',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.managerGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Confirmed',
                          value: '${state.confirmedBookingsCount}',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Completed',
                          value: '${state.completedBookingsCount}',
                          icon: Icons.task_alt_rounded,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Today's Appointments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Today\'s Appointments'),
                      InkWell(
                        onTap: () {
                          if (onNavigateTab != null) {
                            onNavigateTab!(1); // Go to Bookings tab
                          } else {
                            Navigator.pushNamed(context, AppRoutes.managerBookings);
                          }
                        },
                        child: Text(
                          'View All (${state.bookings.length})',
                          style: AppTextStyles.caption(color: AppColors.managerEmerald).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (appointments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBE6DF)),
                      ),
                      child: Center(
                        child: Text(
                          'No appointments scheduled for this branch today.',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                        ),
                      ),
                    )
                  else
                    ...appointments.map((booking) => _buildAppointmentItem(context, booking)),
                  const SizedBox(height: 20),

                  // 5. Booking Overview Stats Bar
                  _buildSectionHeader('Branch Booking Overview'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildOverviewMetric(
                            label: 'Upcoming',
                            value: '${state.confirmedBookingsCount}',
                            color: Colors.green.shade800,
                          ),
                        ),
                        Container(height: 30, width: 1, color: const Color(0xFFEBE6DF)),
                        Expanded(
                          child: _buildOverviewMetric(
                            label: 'Pending Approval',
                            value: '${state.pendingBookingsCount}',
                            color: AppColors.managerGold,
                          ),
                        ),
                        Container(height: 30, width: 1, color: const Color(0xFFEBE6DF)),
                        Expanded(
                          child: _buildOverviewMetric(
                            label: 'Cancelled',
                            value: '${state.cancelledBookingsCount}',
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. Recent Branch Activity Log
                  _buildSectionHeader('Recent Branch Activity'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Column(
                      children: activities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final act = entry.value;
                        final isLast = index == activities.length - 1;

                        IconData actIcon = Icons.notifications_none_rounded;
                        Color actColor = AppColors.managerEmerald;
                        if (act.type == 'new') {
                          actIcon = Icons.fiber_new_rounded;
                          actColor = AppColors.managerGold;
                        } else if (act.type == 'confirmed') {
                          actIcon = Icons.check_circle_outline_rounded;
                          actColor = Colors.green;
                        } else if (act.type == 'completed') {
                          actIcon = Icons.task_alt_rounded;
                          actColor = AppColors.charcoal;
                        } else if (act.type == 'cancelled') {
                          actIcon = Icons.cancel_outlined;
                          actColor = Colors.red;
                        }

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: actColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(actIcon, size: 14, color: actColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act.title,
                                        style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        act.description,
                                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (!isLast) const Divider(height: 14, color: Color(0xFFEBE6DF)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(fontSize: 20),
                ),
                Text(
                  title,
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, BranchManagerBookingModel booking) {
    final isHome = booking.bookingType == BranchBookingType.homeService;

    Color statusBg = Colors.blue.shade50;
    Color statusFg = Colors.blue.shade800;
    String statusText = 'CONFIRMED';

    if (booking.status == BranchBookingStatus.newBooking) {
      statusBg = const Color(0xFFFFF9E6);
      statusFg = const Color(0xFFB78103);
      statusText = 'NEW';
    } else if (booking.status == BranchBookingStatus.completed) {
      statusBg = Colors.green.shade50;
      statusFg = Colors.green.shade800;
      statusText = 'COMPLETED';
    } else if (booking.status == BranchBookingStatus.cancelled) {
      statusBg = Colors.red.shade50;
      statusFg = Colors.red.shade800;
      statusText = 'CANCELLED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Ref & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingRef,
                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Row(
                children: [
                  // Service mode chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHome ? Colors.purple.shade50 : AppColors.managerEmeraldBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isHome ? Colors.purple.shade200 : AppColors.managerBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHome ? Icons.home_repair_service_rounded : Icons.storefront_rounded,
                          size: 11,
                          color: isHome ? Colors.purple.shade800 : AppColors.managerEmerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isHome ? 'HOME SERVICE' : 'SALON VISIT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isHome ? Colors.purple.shade800 : AppColors.managerEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Customer and Service
          Text(
            booking.customerName,
            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            booking.serviceName,
            style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Date time & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.managerEmerald),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.timeSlot} • ₹${booking.price.toInt()}',
                    style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.managerBookingDetails,
                    arguments: booking.id,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.managerEmeraldBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.managerBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.managerEmerald,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.managerEmerald),
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

  Widget _buildOverviewMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h1(color: color).copyWith(fontSize: 18),
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
}
