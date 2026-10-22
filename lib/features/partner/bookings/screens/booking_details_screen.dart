import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class BookingDetailsScreen extends StatelessWidget {
  final PartnerBookingModel? booking;

  const BookingDetailsScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    // Resolve booking from argument or state
    final routeArg = ModalRoute.of(context)?.settings.arguments as PartnerBookingModel?;
    final targetBooking = booking ?? routeArg ?? PartnerState.instance.bookings.first;
    final isHome = targetBooking.bookingType == PartnerBookingType.homeService;

    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        // Find latest version of this booking from state
        final currentBooking = PartnerState.instance.bookings.firstWhere(
          (b) => b.id == targetBooking.id,
          orElse: () => targetBooking,
        );

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Appointment Details',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Reference Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentBooking.bookingRef,
                              style: AppTextStyles.h2(color: AppColors.copper).copyWith(fontSize: 17),
                            ),
                            _buildBadge(currentBooking.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentBooking.serviceName,
                          style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.copper),
                            const SizedBox(width: 6),
                            Text(
                              'Appointment: Today, 03:30 PM',
                              style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Service Mode Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isHome ? const Color(0xFFEBF5FB) : const Color(0xFFF9EBEA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHome ? const Color(0xFFAED6F1) : AppColors.copper.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isHome ? Icons.home_work_rounded : Icons.storefront_rounded,
                          color: isHome ? const Color(0xFF1B4F72) : AppColors.copper,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHome ? 'DOORSTEP HOME SERVICE' : 'IN-SALON VISIT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isHome ? const Color(0xFF1B4F72) : AppColors.copper,
                                ),
                              ),
                              Text(
                                isHome
                                    ? 'Stylist will travel to customer address'
                                    : 'Customer visiting ${currentBooking.branchName}',
                                style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Customer Details Card
                  _buildSectionTitle('Customer Information'),
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
                        _buildRow(Icons.person_outline_rounded, 'Customer Name', currentBooking.customerName),
                        const Divider(height: 16, color: Color(0xFFEBE6DF)),
                        _buildRow(Icons.phone_outlined, 'Contact Phone', currentBooking.customerPhone),
                        if (isHome && currentBooking.customerAddress != null) ...[
                          const Divider(height: 16, color: Color(0xFFEBE6DF)),
                          _buildRow(Icons.location_on_outlined, 'Home Address', currentBooking.customerAddress!),
                        ],
                        if (currentBooking.notes != null) ...[
                          const Divider(height: 16, color: Color(0xFFEBE6DF)),
                          _buildRow(Icons.note_alt_outlined, 'Special Request', currentBooking.notes!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Payment & Financial Summary
                  _buildSectionTitle('Payment Summary'),
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
                            Text(
                              'Service Amount',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                            ),
                            Text(
                              '₹${currentBooking.price.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        if (isHome) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Convenience & Travel Fee',
                                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                              ),
                              Text(
                                'Included',
                                style: AppTextStyles.bodyBold(color: Colors.green.shade700).copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 20, color: Color(0xFFEBE6DF)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Payable',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 15),
                            ),
                            Text(
                              '₹${currentBooking.price.toStringAsFixed(0)}',
                              style: AppTextStyles.h1(color: AppColors.copper).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (currentBooking.status == PartnerBookingStatus.newBooking) ...[
                    AppButton(
                      text: 'Confirm Appointment',
                      backgroundColor: AppColors.copper,
                      onPressed: () {
                        PartnerState.instance.updateBookingStatus(currentBooking.id, PartnerBookingStatus.confirmed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.copper,
                            content: Text('Appointment confirmed successfully!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Decline / Reject',
                      isOutlined: true,
                      backgroundColor: Colors.red.shade600,
                      textColor: Colors.red.shade600,
                      onPressed: () {
                        PartnerState.instance.updateBookingStatus(currentBooking.id, PartnerBookingStatus.cancelled);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Appointment cancelled.'),
                          ),
                        );
                      },
                    ),
                  ] else if (currentBooking.status == PartnerBookingStatus.confirmed) ...[
                    AppButton(
                      text: 'Mark Service Completed',
                      backgroundColor: Colors.green.shade700,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        PartnerState.instance.updateBookingStatus(currentBooking.id, PartnerBookingStatus.completed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Appointment marked as Completed! Revenue added to earnings.'),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
    );
  }

  Widget _buildRow(IconData icon, String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.copper),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            val,
            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(PartnerBookingStatus status) {
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
