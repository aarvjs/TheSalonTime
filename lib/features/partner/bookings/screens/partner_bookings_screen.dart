import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class PartnerBookingsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const PartnerBookingsScreen({super.key, this.onOpenDrawer});

  @override
  State<PartnerBookingsScreen> createState() => _PartnerBookingsScreenState();
}

class _PartnerBookingsScreenState extends State<PartnerBookingsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'New', 'Confirmed', 'Completed', 'Cancelled'];

  void _confirmAction(PartnerBookingModel booking, PartnerBookingStatus newStatus) {
    String actionLabel;
    switch (newStatus) {
      case PartnerBookingStatus.confirmed:
        actionLabel = 'Confirm Appointment';
        break;
      case PartnerBookingStatus.completed:
        actionLabel = 'Mark Appointment Completed';
        break;
      case PartnerBookingStatus.cancelled:
        actionLabel = 'Cancel Appointment';
        break;
      default:
        actionLabel = 'Update Status';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          actionLabel,
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to change status of booking ${booking.bookingRef} for ${booking.customerName}?',
          style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == PartnerBookingStatus.cancelled ? Colors.red.shade600 : AppColors.copper,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PartnerState.instance.updateBookingStatus(booking.id, newStatus);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.copper,
                  content: Text('Booking ${booking.bookingRef} status updated!'),
                ),
              );
            },
            child: const Text('Confirm'),
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
        final allBookings = PartnerState.instance.bookings;
        final filteredBookings = allBookings.where((b) {
          if (_selectedFilter == 'All') return true;
          if (_selectedFilter == 'New') return b.status == PartnerBookingStatus.newBooking;
          if (_selectedFilter == 'Confirmed') return b.status == PartnerBookingStatus.confirmed;
          if (_selectedFilter == 'Completed') return b.status == PartnerBookingStatus.completed;
          if (_selectedFilter == 'Cancelled') return b.status == PartnerBookingStatus.cancelled;
          return true;
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
              'Appointments (${allBookings.length})',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
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
                            if (selected) setState(() => _selectedFilter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),

                // Bookings List
                Expanded(
                  child: filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.mutedTextGray),
                              const SizedBox(height: 12),
                              Text(
                                'No appointments found in "$_selectedFilter"',
                                style: AppTextStyles.bodyBold(color: AppColors.warmBlack),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final b = filteredBookings[index];
                            return _buildBookingCard(b);
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

  Widget _buildBookingCard(PartnerBookingModel b) {
    final isHome = b.bookingType == PartnerBookingType.homeService;

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
          // Top Row: Ref & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.bookingRef,
                style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 13),
              ),
              _buildStatusBadge(b.status),
            ],
          ),
          const SizedBox(height: 8),

          // Service and Customer
          Text(
            b.serviceName,
            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            'Customer: ${b.customerName} • ${b.customerPhone}',
            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Booking Mode Badge & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHome ? const Color(0xFFEBF5FB) : const Color(0xFFF9EBEA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHome ? Icons.home_rounded : Icons.storefront_rounded,
                      size: 13,
                      color: isHome ? const Color(0xFF1B4F72) : AppColors.copper,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHome ? 'HOME SERVICE' : 'SALON VISIT',
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
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 16),
              ),
            ],
          ),

          // Customer Address (for Home Service)
          if (isHome && b.customerAddress != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warmGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.copper),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.customerAddress!,
                      style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 10),

          // Action Buttons
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.partnerBookingDetails,
                    arguments: b,
                  );
                },
                child: const Text('View Details', style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (b.status == PartnerBookingStatus.newBooking) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => _confirmAction(b, PartnerBookingStatus.cancelled),
                      child: const Text('Reject', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () => _confirmAction(b, PartnerBookingStatus.confirmed),
                      child: const Text('Confirm', style: TextStyle(fontSize: 12)),
                    ),
                  ] else if (b.status == PartnerBookingStatus.confirmed) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
                      label: const Text('Mark Complete', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () => _confirmAction(b, PartnerBookingStatus.completed),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PartnerBookingStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case PartnerBookingStatus.newBooking:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        label = 'NEW REQUEST';
        break;
      case PartnerBookingStatus.confirmed:
        bg = AppColors.copper.withValues(alpha: 0.12);
        fg = AppColors.copper;
        label = 'CONFIRMED';
        break;
      case PartnerBookingStatus.completed:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = 'COMPLETED';
        break;
      case PartnerBookingStatus.cancelled:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        label = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
