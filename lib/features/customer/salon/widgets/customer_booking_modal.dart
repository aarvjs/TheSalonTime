import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../partner/models/partner_models.dart' show SalonServiceModel;
import '../../bookings/services/customer_booking_storage.dart';
import '../../home/models/salon_model.dart';
import '../../navigation/customer_navigation_shell.dart';

class CustomerBookingModal extends StatefulWidget {
  final SalonModel salon;
  final List<SalonServiceModel> selectedServices;
  final double totalAmount;

  const CustomerBookingModal({
    super.key,
    required this.salon,
    required this.selectedServices,
    required this.totalAmount,
  });

  static Future<void> show({
    required BuildContext context,
    required SalonModel salon,
    required List<SalonServiceModel> selectedServices,
    required double totalAmount,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerBookingModal(
        salon: salon,
        selectedServices: selectedServices,
        totalAmount: totalAmount,
      ),
    );
  }

  @override
  State<CustomerBookingModal> createState() => _CustomerBookingModalState();
}

class _CustomerBookingModalState extends State<CustomerBookingModal> {
  int _selectedDateIndex = 0;
  String _selectedTimeSlot = '11:00 AM';
  bool _isHomeService = false;
  String _selectedPaymentMethod = 'Cash at Salon';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSuccess = false;
  String _createdBookingRef = '';
  DateTime _createdAppointmentDateTime = DateTime.now();

  final List<String> _morningSlots = ['09:30 AM', '10:30 AM', '11:30 AM'];
  final List<String> _afternoonSlots = ['01:00 PM', '02:30 PM', '04:00 PM'];
  final List<String> _eveningSlots = ['05:30 PM', '07:00 PM', '08:30 PM'];

  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _availableDates = List.generate(7, (i) => now.add(Duration(days: i)));

    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? 'Customer';
    _phoneController.text = user?.phoneNumber ?? '';
    _addressController.text = widget.salon.address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatSlotDate(DateTime date, int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  Future<void> _submitBooking(BuildContext context) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    if (_isHomeService && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your complete address for home service')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final selectedDate = _availableDates[_selectedDateIndex];
      
      // Parse slot hour and minute
      int hour = 11;
      int minute = 0;
      try {
        final parts = _selectedTimeSlot.split(' ');
        final timeParts = parts[0].split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
        if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
        if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
      } catch (_) {}

      final appointmentDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
        minute,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final bookingId = 'bk_$timestamp';
      final bookingRef = '#BK-${(timestamp % 90000) + 10000}';
      final servicesJoined = widget.selectedServices.map((s) => s.name).join(', ');
      final category = widget.selectedServices.isNotEmpty
          ? widget.selectedServices.first.category
          : widget.salon.category;

      String effectivePartnerId = widget.salon.partnerId;
      if (effectivePartnerId.isEmpty) {
        try {
          final salonSnap = await FirebaseFirestore.instance.collection('salons').doc(widget.salon.id).get();
          if (salonSnap.exists && salonSnap.data() != null) {
            effectivePartnerId = (salonSnap.data()!['partnerId'] as String?) ??
                (salonSnap.data()!['ownerId'] as String?) ??
                '';
          }
        } catch (_) {}
      }
      if (effectivePartnerId.isEmpty) {
        effectivePartnerId = 'partner_default';
      }

      final bookingData = <String, dynamic>{
        'id': bookingId,
        'bookingRef': bookingRef,
        'salonId': widget.salon.id,
        'branchId': widget.salon.id,
        'partnerId': effectivePartnerId,
        'salonName': widget.salon.name,
        'branchName': widget.salon.name,
        'customerName': name,
        'customerPhone': phone,
        'customerId': user?.uid ?? '',
        'userId': user?.uid ?? '',
        'serviceName': servicesJoined,
        'serviceCategory': category,
        'price': widget.totalAmount,
        'appointmentDateTime': appointmentDateTime.toIso8601String(),
        'date': appointmentDateTime.toIso8601String(),
        'bookingType': _isHomeService ? 'homeService' : 'salonVisit',
        'type': _isHomeService ? 'homeService' : 'salonVisit',
        'customerAddress': _isHomeService ? _addressController.text.trim() : widget.salon.address,
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': _selectedPaymentMethod == 'Cash at Salon' ? 'unpaid' : 'paid',
        'status': 'new', // New request for partner confirmation
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 1. Always save locally first so user never loses their booking
      await CustomerBookingStorage.instance.saveBookingLocally(bookingData);

      // 2. Write into real Firestore collection 'bookings'
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set(bookingData);
        developer.log('Booking successfully created in Firestore: $bookingId ($bookingRef)');
      } catch (firestoreErr) {
        developer.log('Firestore write notice (local backup active): $firestoreErr');
      }

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
        _createdBookingRef = bookingRef;
        _createdAppointmentDateTime = appointmentDateTime;
      });
    } catch (e, stack) {
      developer.log('Error creating booking: $e', error: e, stackTrace: stack);
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Failed to book appointment: $e'),
          ),
        );
      }
    }
  }

  Widget _buildSuccessView(BuildContext context, AppColorsData colors) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dt = _createdAppointmentDateTime;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $ampm';

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 52),
          ),
          const SizedBox(height: 16),
          Text(
            'Appointment Requested!',
            style: AppTextStyles.h1(color: colors.textPrimary).copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'बुकिंग रिक्वेस्ट सैलून ओनर को भेज दी गई है',
            style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Booking Reference', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    Text(_createdBookingRef, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.primary)),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Salon', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    Expanded(
                      child: Text(
                        widget.salon.name,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Scheduled Slot', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Mode', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    Text(_selectedPaymentMethod, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    Text('₹${widget.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'The salon manager will confirm or schedule your slot shortly. You can track this in "My Bookings".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'View My Bookings (बुकिंग देखें)',
            backgroundColor: colors.primary,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const CustomerNavigationShell(initialIndex: 2),
                ),
                (r) => false,
              );
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Back to Home (होम पेज)',
            isOutlined: true,
            backgroundColor: colors.primary,
            textColor: colors.primary,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const CustomerNavigationShell(initialIndex: 0),
                ),
                (r) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_isSuccess) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        margin: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: _buildSuccessView(context, colors),
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Appointment',
                          style: AppTextStyles.h2(color: colors.textPrimary).copyWith(fontSize: 19),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.salon.name,
                          style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Service Type Selector (Salon Visit vs Home Service)
              if (widget.salon.isHomeServiceEnabled) ...[
                Text(
                  'Choose Service Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isHomeService = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: !_isHomeService ? colors.primary.withValues(alpha: 0.1) : colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !_isHomeService ? colors.primary : colors.border,
                              width: !_isHomeService ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront_rounded, size: 16, color: !_isHomeService ? colors.primary : colors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Salon Visit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: !_isHomeService ? FontWeight.bold : FontWeight.w500,
                                  color: !_isHomeService ? colors.primary : colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isHomeService = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _isHomeService ? colors.secondary.withValues(alpha: 0.15) : colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isHomeService ? colors.secondary : colors.border,
                              width: _isHomeService ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, size: 16, color: _isHomeService ? colors.secondary : colors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Doorstep At-Home',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _isHomeService ? FontWeight.bold : FontWeight.w500,
                                  color: _isHomeService ? colors.secondary : colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Address field if Home Service
              if (_isHomeService) ...[
                Text(
                  'Your Home / Service Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: TextField(
                    controller: _addressController,
                    style: TextStyle(fontSize: 13, color: colors.textPrimary),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter complete house no, street, landmark',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Step 1: Select Appointment Date
              Text(
                'Select Date (तारीख चुनें)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 58,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _availableDates.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedDateIndex == index;
                    final date = _availableDates[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatSlotDate(date, index),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Step 2: Select Time Slot
              Text(
                'Select Time Slot (समय चुनें)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildSlotGroup('Morning', _morningSlots, colors),
              const SizedBox(height: 6),
              _buildSlotGroup('Afternoon', _afternoonSlots, colors),
              const SizedBox(height: 6),
              _buildSlotGroup('Evening', _eveningSlots, colors),
              const SizedBox(height: 18),

              // Step 3: Customer Details
              Text(
                'Contact Details (ग्राहक विवरण)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 13, color: colors.textPrimary),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 13, color: colors.textPrimary),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: _notesController,
                  style: TextStyle(fontSize: 12.5, color: colors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Special instructions or notes (optional)',
                    prefixIcon: Icon(Icons.note_alt_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Step 4: Payment Method Selection
              Text(
                'Payment Method (भुगतान विकल्प)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                label: 'Cash at Salon / After Service (पे ऐट सैलून - काउंटर कैश)',
                subtitle: 'Pay directly when service is finished',
                icon: Icons.payments_outlined,
                value: 'Cash at Salon',
                colors: colors,
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                label: 'UPI (Google Pay, PhonePe, Paytm)',
                subtitle: 'Fast QR & UPI intent payment',
                icon: Icons.qr_code_rounded,
                value: 'UPI Online',
                colors: colors,
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                label: 'Credit / Debit Card / Netbanking',
                subtitle: 'Visa, Mastercard, RuPay',
                icon: Icons.credit_card_rounded,
                value: 'Online Card',
                colors: colors,
              ),
              const SizedBox(height: 20),

              // Step 5: Total & Confirm Action
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.selectedServices.length} Services Selected',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${widget.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      text: _isSubmitting ? 'Booking...' : 'Confirm Booking',
                      backgroundColor: colors.primary,
                      width: 170,
                      height: 44,
                      onPressed: _isSubmitting ? null : () => _submitBooking(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotGroup(String groupName, List<String> slots, AppColorsData colors) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            groupName,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary),
          ),
        ),
        Expanded(
          child: Row(
            children: slots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTimeSlot = slot),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required String value,
    required AppColorsData colors,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.08) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? colors.primary : colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? colors.primary : colors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
