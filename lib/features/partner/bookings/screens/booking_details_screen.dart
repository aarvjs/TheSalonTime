import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class BookingDetailsScreen extends StatelessWidget {
  final PartnerBookingModel? booking;

  const BookingDetailsScreen({super.key, this.booking});

  void _showRescheduleSheet(BuildContext context, PartnerBookingModel booking) {
    DateTime selectedDate = booking.appointmentDateTime.isAfter(DateTime.now())
        ? booking.appointmentDateTime
        : DateTime.now().add(const Duration(days: 1));
    String selectedSlot = '11:00 AM';
    final noteController = TextEditingController(
      text: 'Stylist / salon is busy at current slot. Rescheduled to a convenient time.',
    );

    final timeSlots = [
      '10:00 AM',
      '11:30 AM',
      '01:00 PM',
      '02:30 PM',
      '04:00 PM',
      '05:30 PM',
      '07:00 PM',
      '08:00 PM',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Container(
              margin: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBE6DF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reschedule Slot (समय बदलें)',
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                    ),
                    Text(
                      '${booking.bookingRef} • ${booking.customerName}',
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
                    ),
                    const Divider(height: 24, color: Color(0xFFEBE6DF)),

                    // Date Picker
                    Text(
                      'Choose New Date',
                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.copper),
                      label: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(color: AppColors.warmBlack, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.copper),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: modalCtx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time Slots
                    Text(
                      'Choose New Time Slot',
                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeSlots.map((slot) {
                        final isSel = selectedSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSel,
                          selectedColor: AppColors.copper,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSel ? Colors.white : AppColors.charcoal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isSel ? AppColors.copper : const Color(0xFFEBE6DF)),
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedSlot = slot);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Message to Customer
                    Text(
                      'Note to Customer (ग्राहक के लिए संदेश)',
                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Current slot is full, rescheduled to 3:30 PM.',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedTextGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEBE6DF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(modalCtx),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.charcoal)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(modalCtx);

                              int hour = 11;
                              int minute = 0;
                              try {
                                final parts = selectedSlot.split(' ');
                                final timeParts = parts[0].split(':');
                                hour = int.parse(timeParts[0]);
                                minute = int.parse(timeParts[1]);
                                if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
                                if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
                              } catch (_) {}

                              final newDateTime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                hour,
                                minute,
                              );

                              PartnerState.instance.updateBookingStatus(
                                booking.id,
                                PartnerBookingStatus.rescheduled,
                                rescheduledDateTime: newDateTime,
                                rescheduledNote: noteController.text.trim(),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.purple.shade700,
                                  content: Text('Booking ${booking.bookingRef} rescheduled to $selectedSlot!'),
                                ),
                              );
                            },
                            child: const Text('Confirm Reschedule', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments as PartnerBookingModel?;
    final targetBooking = booking ?? routeArg ?? PartnerState.instance.bookings.first;
    final isHome = targetBooking.bookingType == PartnerBookingType.homeService;

    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
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
                              'Appointment: ${_formatDate(currentBooking.appointmentDateTime)}',
                              style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Rescheduled notice banner
                  if (currentBooking.status == PartnerBookingStatus.rescheduled) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: Colors.purple.shade700),
                              const SizedBox(width: 6),
                              Text(
                                'Rescheduled Appointment',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple.shade900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'New Slot: ${_formatDate(currentBooking.appointmentDateTime)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.purple.shade800),
                          ),
                          if (currentBooking.rescheduledNote != null && currentBooking.rescheduledNote!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Reason: ${currentBooking.rescheduledNote!}',
                              style: TextStyle(fontSize: 11.5, color: Colors.purple.shade700),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Cancellation notice banner
                  if (currentBooking.status == PartnerBookingStatus.cancelled) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cancel_outlined, size: 16, color: Colors.red.shade700),
                              const SizedBox(width: 6),
                              Text(
                                'Cancelled Appointment',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red.shade900),
                              ),
                            ],
                          ),
                          if (currentBooking.cancellationReason != null && currentBooking.cancellationReason!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Reason: ${currentBooking.cancellationReason!}',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

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
                        if (currentBooking.notes != null && currentBooking.notes!.isNotEmpty) ...[
                          const Divider(height: 16, color: Color(0xFFEBE6DF)),
                          _buildRow(Icons.note_alt_outlined, 'Customer Notes', currentBooking.notes!),
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
                                'Travel & Kit Fee',
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
                              'Total Amount',
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

                  // Dynamic Action Buttons
                  if (currentBooking.status == PartnerBookingStatus.newBooking) ...[
                    AppButton(
                      text: 'Confirm Appointment (स्वीकार करें)',
                      backgroundColor: Colors.green.shade700,
                      onPressed: () {
                        PartnerState.instance.updateBookingStatus(currentBooking.id, PartnerBookingStatus.confirmed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Appointment confirmed successfully!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Reschedule Slot (रीशेड्यूल करें)',
                      isOutlined: true,
                      backgroundColor: Colors.purple.shade700,
                      textColor: Colors.purple.shade700,
                      onPressed: () => _showRescheduleSheet(context, currentBooking),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Decline / Reject (अस्वीकार करें)',
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
                      text: 'Mark Service Completed (पूर्ण करें)',
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
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Reschedule Slot (रीशेड्यूल करें)',
                      isOutlined: true,
                      backgroundColor: Colors.purple.shade700,
                      textColor: Colors.purple.shade700,
                      onPressed: () => _showRescheduleSheet(context, currentBooking),
                    ),
                  ] else if (currentBooking.status == PartnerBookingStatus.rescheduled) ...[
                    AppButton(
                      text: 'Mark Service Completed (पूर्ण करें)',
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
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Change Reschedule Slot Again',
                      isOutlined: true,
                      backgroundColor: Colors.purple.shade700,
                      textColor: Colors.purple.shade700,
                      onPressed: () => _showRescheduleSheet(context, currentBooking),
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
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = 'CONFIRMED';
        break;
      case PartnerBookingStatus.rescheduled:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        label = 'RESCHEDULED';
        break;
      case PartnerBookingStatus.completed:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
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

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dt.day}, ${dt.year} at $hour:$minute $ampm';
  }
}
