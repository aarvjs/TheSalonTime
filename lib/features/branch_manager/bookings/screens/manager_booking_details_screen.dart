import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/branch_manager_state.dart';
import '../../models/branch_manager_models.dart';

class ManagerBookingDetailsScreen extends StatefulWidget {
  final String? bookingId;

  const ManagerBookingDetailsScreen({super.key, this.bookingId});

  @override
  State<ManagerBookingDetailsScreen> createState() => _ManagerBookingDetailsScreenState();
}

class _ManagerBookingDetailsScreenState extends State<ManagerBookingDetailsScreen> {
  void _confirmBooking(BranchManagerBookingModel booking) {
    final success = BranchManagerState.instance.confirmBooking(booking.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.managerEmerald,
          content: Text('Appointment confirmed successfully! Customer notified.'),
        ),
      );
    }
  }

  void _markCompleted(BranchManagerBookingModel booking) {
    final success = BranchManagerState.instance.completeBooking(booking.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Appointment marked as Completed.'),
        ),
      );
    }
  }

  void _showCancelDialog(BranchManagerBookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cancel Booking ${booking.bookingRef}?',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancellation preserves booking history for branch records. Please specify a reason for cancellation:',
              style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Customer requested rescheduling / Stylist unavailable',
                hintStyle: AppTextStyles.caption(color: AppColors.mutedTextGray),
                filled: true,
                fillColor: AppColors.warmGray,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final reason = reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : 'Customer / Operations adjustment';
              Navigator.pop(ctx);
              BranchManagerState.instance.cancelBooking(booking.id, reason);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Booking has been cancelled and logged in branch activity.'),
                ),
              );
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final id = widget.bookingId ?? (routeArgs is String ? routeArgs : null);

    return ListenableBuilder(
      listenable: BranchManagerState.instance,
      builder: (context, _) {
        final state = BranchManagerState.instance;
        final booking = state.bookings.firstWhere(
          (b) => b.id == id,
          orElse: () => state.bookings.first,
        );
        final session = state.session;
        final isHome = booking.bookingType == BranchBookingType.homeService;

        Color statusBg = Colors.blue.shade50;
        Color statusFg = Colors.blue.shade800;
        String statusText = 'CONFIRMED';

        if (booking.status == BranchBookingStatus.newBooking) {
          statusBg = const Color(0xFFFFF9E6);
          statusFg = const Color(0xFFB78103);
          statusText = 'NEW BOOKING (PENDING CONFIRMATION)';
        } else if (booking.status == BranchBookingStatus.completed) {
          statusBg = Colors.green.shade50;
          statusFg = Colors.green.shade800;
          statusText = 'COMPLETED';
        } else if (booking.status == BranchBookingStatus.cancelled) {
          statusBg = Colors.red.shade50;
          statusFg = Colors.red.shade800;
          statusText = 'CANCELLED';
        }

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Booking Details',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // Status & Ref Banner
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BOOKING REFERENCE',
                                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                booking.bookingRef,
                                style: AppTextStyles.h1(color: AppColors.managerEmerald).copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isHome ? Colors.purple.shade50 : AppColors.managerEmeraldBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isHome ? Colors.purple.shade200 : AppColors.managerBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isHome ? Icons.home_repair_service_rounded : Icons.storefront_rounded,
                                  size: 13,
                                  color: isHome ? Colors.purple.shade800 : AppColors.managerEmerald,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isHome ? 'HOME SERVICE' : 'SALON VISIT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isHome ? Colors.purple.shade800 : AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0xFFEBE6DF)),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusFg,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Customer Information Card
                _buildSectionHeader('Customer Information'),
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
                      _buildDetailRow(Icons.person_outline_rounded, 'Customer Name', booking.customerName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildDetailRow(Icons.phone_outlined, 'Contact Phone', booking.customerPhone),
                      if (isHome && booking.homeAddress != null) ...[
                        const Divider(height: 16, color: Color(0xFFEBE6DF)),
                        _buildDetailRow(Icons.pin_drop_outlined, 'Service Address', booking.homeAddress!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Service & Appointment Details
                _buildSectionHeader('Appointment & Service Details'),
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
                      _buildDetailRow(Icons.spa_outlined, 'Service Name', booking.serviceName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildDetailRow(Icons.category_outlined, 'Category', booking.category),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildDetailRow(Icons.calendar_month_outlined, 'Scheduled Time', booking.timeSlot),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildDetailRow(Icons.badge_outlined, 'Assigned Staff', booking.stylistName),
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      _buildDetailRow(Icons.storefront_outlined, 'Assigned Branch', session.assignedBranchName),
                      if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFEBE6DF)),
                        _buildDetailRow(Icons.note_alt_outlined, 'Special Notes', booking.notes!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Price Summary
                _buildSectionHeader('Payment & Pricing Summary'),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service Price', style: AppTextStyles.caption(color: AppColors.mutedTextGray)),
                          Text('₹${booking.price.toInt()}', style: AppTextStyles.bodyBold(color: AppColors.warmBlack)),
                        ],
                      ),
                      if (isHome) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Doorstep Convenience Fee', style: AppTextStyles.caption(color: AppColors.mutedTextGray)),
                            Text('₹149', style: AppTextStyles.bodyBold(color: AppColors.warmBlack)),
                          ],
                        ),
                      ],
                      const Divider(height: 16, color: Color(0xFFEBE6DF)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Billed Amount',
                            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                          ),
                          Text(
                            '₹${(booking.price + (isHome ? 149 : 0)).toInt()}',
                            style: AppTextStyles.h2(color: AppColors.managerEmerald).copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warmGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 14, color: AppColors.mutedTextGray),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Pricing is controlled by Partner. Branch Managers cannot alter billing rates.',
                                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Permitted Operations Action Buttons
                _buildActionButtons(booking),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.managerEmerald, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BranchManagerBookingModel booking) {
    if (booking.status == BranchBookingStatus.newBooking) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.managerEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmBooking(booking),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Reject / Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showCancelDialog(booking),
            ),
          ),
        ],
      );
    } else if (booking.status == BranchBookingStatus.confirmed) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.task_alt_rounded, size: 18),
              label: const Text('Mark Appointment Completed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _markCompleted(booking),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showCancelDialog(booking),
            ),
          ),
        ],
      );
    } else {
      // Completed or Cancelled: Read-only state
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE6DF)),
        ),
        child: Center(
          child: Text(
            booking.status == BranchBookingStatus.completed
                ? 'This appointment has been fulfilled and marked completed.'
                : 'This appointment was cancelled. History is preserved.',
            style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
