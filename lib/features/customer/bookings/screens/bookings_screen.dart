import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../services/customer_booking_storage.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Cancelled

  @override
  void initState() {
    super.initState();
    CustomerBookingStorage.instance.loadBookings().then((_) {
      if (mounted) setState(() {});
    });
  }

  bool _phoneMatches(String? p1, String? p2) {
    if (p1 == null || p2 == null) return false;
    final c1 = p1.replaceAll(RegExp(r'\D'), '');
    final c2 = p2.replaceAll(RegExp(r'\D'), '');
    if (c1.isEmpty || c2.isEmpty) return false;
    if (c1 == c2) return true;
    if (c1.length >= 10 && c2.length >= 10) {
      return c1.substring(c1.length - 10) == c2.substring(c2.length - 10);
    }
    return false;
  }

  void _cancelBooking(BuildContext context, Map<String, dynamic> booking, AppColorsData colors) {
    final bookingId = (booking['id'] ?? booking['bookingRef'] ?? '').toString();
    final salonName = booking['salonName'] ?? 'Salon';
    final ref = booking['bookingRef'] ?? '#BK';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cancel Appointment (रद्द करें)',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to cancel booking $ref at $salonName?',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Booking', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set({
                  'status': 'cancelled',
                  'cancelledBy': 'customer',
                  'cancellationReason': 'Cancelled by customer',
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
              } catch (_) {}

              await CustomerBookingStorage.instance.updateBookingStatus(bookingId, 'cancelled');
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Appointment cancelled successfully.'),
                  ),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _acceptRescheduledSlot(BuildContext context, Map<String, dynamic> booking, AppColorsData colors) async {
    final bookingId = (booking['id'] ?? booking['bookingRef'] ?? '').toString();
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set({
        'status': 'confirmed',
        'customerAcceptedReschedule': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}

    await CustomerBookingStorage.instance.updateBookingStatus(bookingId, 'confirmed');
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Rescheduled slot accepted! Appointment is confirmed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = RoleTheme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Bookings',
                      style: AppTextStyles.h1(color: colors.textPrimary).copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Tab Selector (All, Upcoming, Completed, Cancelled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, 'All', colors),
                      _buildTabItem(1, 'Upcoming', colors),
                      _buildTabItem(2, 'Completed', colors),
                      _buildTabItem(3, 'Cancelled', colors),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Live Dynamic Bookings Stream & Local Merged Store
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                  builder: (context, snapshot) {
                    final firestoreDocs = snapshot.data?.docs ?? [];
                    final localBookings = CustomerBookingStorage.instance.currentBookings;

                    final Map<String, Map<String, dynamic>> merged = {};

                    // 1. Add locally saved bookings for this device
                    for (final b in localBookings) {
                      final id = b['id'] ?? b['bookingRef'] ?? '';
                      if (id.isNotEmpty) merged[id] = Map<String, dynamic>.from(b);
                    }

                    // 2. Add/merge Firestore docs
                    for (final doc in firestoreDocs) {
                      final data = doc.data();
                      final id = doc.id;
                      final uid = user?.uid ?? '';
                      final phone = user?.phoneNumber ?? '';
                      final docUid = data['customerId'] ?? data['userId'] ?? '';
                      final docPhone = data['customerPhone'] ?? '';

                      final isMine = (uid.isNotEmpty && docUid == uid) ||
                          _phoneMatches(phone, docPhone) ||
                          merged.containsKey(id) ||
                          merged.containsKey(data['bookingRef']);

                      if (isMine) {
                        merged[id] = data;
                      }
                    }

                    // Sort newest first
                    final allCustomerBookings = merged.values.toList();
                    allCustomerBookings.sort((a, b) {
                      final d1 = _parseDate(a['appointmentDateTime'] ?? a['createdAt']);
                      final d2 = _parseDate(b['appointmentDateTime'] ?? b['createdAt']);
                      return d2.compareTo(d1);
                    });

                    // Filter by selected tab
                    final filteredBookings = allCustomerBookings.where((data) {
                      if (_selectedTab == 0) return true; // All
                      final status = (data['status'] ?? '').toString().toLowerCase();
                      if (_selectedTab == 1) {
                        // Upcoming (New, Confirmed, Pending, Rescheduled)
                        return status == 'new' || status == 'confirmed' || status == 'pending' || status == 'rescheduled' || status.isEmpty;
                      } else if (_selectedTab == 2) {
                        return status == 'completed';
                      } else {
                        return status == 'cancelled';
                      }
                    }).toList();

                    if (filteredBookings.isEmpty) {
                      return _buildEmptyState(colors);
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        final salonName = booking['salonName'] ?? booking['branchName'] ?? 'Salon';
                        final serviceName = booking['serviceName'] ?? 'Salon Service';
                        final isHomeService = (booking['bookingType'] ?? '').toString().toLowerCase().contains('home');
                        final statusStr = (booking['status'] ?? 'NEW').toString().toUpperCase();
                        final price = (booking['price'] as num?)?.toDouble() ?? 0.0;

                        String dateTimeStr = 'Scheduled';
                        if (booking['appointmentDateTime'] != null) {
                          dateTimeStr = _formatDateTime(_parseDate(booking['appointmentDateTime']));
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildBookingCard(
                            context,
                            booking: booking,
                            salonName: salonName,
                            serviceName: serviceName,
                            dateTime: dateTimeStr,
                            isHomeService: isHomeService,
                            status: statusStr,
                            price: price,
                            imagePath: AssetConstants.maleBanner1,
                            colors: colors,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dt.day}, ${dt.year} • $hour:$minute $ampm';
  }

  Widget _buildEmptyState(AppColorsData colors) {
    String message = 'No bookings found';
    if (_selectedTab == 1) message = 'No upcoming appointments';
    if (_selectedTab == 2) message = 'No completed appointments yet';
    if (_selectedTab == 3) message = 'No cancelled appointments';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 36,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.h3(color: colors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your salon appointments, slot timings and status will appear here dynamically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, AppColorsData colors) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context, {
    required Map<String, dynamic> booking,
    required String salonName,
    required String serviceName,
    required String dateTime,
    required bool isHomeService,
    required String status,
    required double price,
    required String imagePath,
    required AppColorsData colors,
  }) {
    Color statusBg = Colors.amber.shade50;
    Color statusFg = Colors.amber.shade900;
    if (status == 'CONFIRMED') {
      statusBg = Colors.green.shade50;
      statusFg = Colors.green.shade800;
    } else if (status.contains('RESCHEDULE')) {
      statusBg = Colors.purple.shade50;
      statusFg = Colors.purple.shade800;
    } else if (status == 'COMPLETED') {
      statusBg = Colors.blue.shade50;
      statusFg = Colors.blue.shade800;
    } else if (status.contains('CANCEL')) {
      statusBg = Colors.red.shade50;
      statusFg = Colors.red.shade800;
    }

    final isRescheduled = status.contains('RESCHEDULE');
    final canCancel = status == 'NEW' || status == 'CONFIRMED' || isRescheduled || status == 'PENDING';
    final rescheduledNote = booking['rescheduledNote'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isRescheduled ? Colors.purple.shade200 : colors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(
                  imagePath: imagePath,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            salonName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h3(color: colors.textPrimary).copyWith(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusFg,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle(color: colors.textSecondary).copyWith(
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: colors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateTime,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Rescheduled Alert Box for Customer
          if (isRescheduled) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 15, color: Colors.purple.shade800),
                      const SizedBox(width: 6),
                      Text(
                        'Salon Rescheduled Slot (समय बदला गया)',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'New Appointment Time: $dateTime',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.purple.shade800),
                  ),
                  if (rescheduledNote != null && rescheduledNote.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Note: $rescheduledNote',
                      style: TextStyle(fontSize: 10.5, color: Colors.purple.shade700),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          onPressed: () => _cancelBooking(context, booking, colors),
                          child: const Text('Cancel Booking', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          onPressed: () => _acceptRescheduledSlot(context, booking, colors),
                          child: const Text('Accept Slot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHomeService ? colors.secondary.withValues(alpha: 0.15) : colors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isHomeService ? 'HOME SERVICE' : 'SALON VISIT',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isHomeService ? colors.secondary : colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canCancel && !isRescheduled) ...[
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _cancelBooking(context, booking, colors),
                      child: const Text('Cancel', style: TextStyle(fontSize: 11.5)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AppButton(
                    text: 'View Details',
                    height: 32,
                    width: 96,
                    isOutlined: true,
                    backgroundColor: colors.primary,
                    textColor: colors.primary,
                    onPressed: () => _showBookingDetailsSheet(context, booking, colors),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDetailsSheet(BuildContext context, Map<String, dynamic> b, AppColorsData colors) {
    final bookingRef = b['bookingRef'] ?? '#BK';
    final salonName = b['salonName'] ?? 'Salon';
    final serviceName = b['serviceName'] ?? 'Service';
    final price = (b['price'] as num?)?.toDouble() ?? 0.0;
    final status = (b['status'] ?? 'NEW').toString().toUpperCase();
    final paymentMethod = b['paymentMethod'] ?? 'Cash at Salon';
    final address = b['customerAddress'] ?? 'Salon Location';
    final notes = b['notes'] ?? '';
    final rescheduledNote = b['rescheduledNote'] as String?;
    final canCancel = status == 'NEW' || status == 'CONFIRMED' || status.contains('RESCHEDULE') || status == 'PENDING';

    String dateStr = 'Scheduled';
    if (b['appointmentDateTime'] != null) {
      dateStr = _formatDateTime(_parseDate(b['appointmentDateTime']));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bookingRef, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primary)),
                      Text('Appointment Details', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('Salon', salonName, colors),
              const SizedBox(height: 8),
              _buildDetailRow('Services', serviceName, colors),
              const SizedBox(height: 8),
              _buildDetailRow('Scheduled Time', dateStr, colors),
              const SizedBox(height: 8),
              _buildDetailRow('Address / Location', address, colors),
              const SizedBox(height: 8),
              _buildDetailRow('Payment Mode', paymentMethod, colors),
              const SizedBox(height: 8),
              _buildDetailRow('Total Amount', '₹${price.toStringAsFixed(0)}', colors, isPrice: true),
              if (rescheduledNote != null && rescheduledNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Reschedule Note', rescheduledNote, colors),
              ],
              if (notes.toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Notes', notes.toString(), colors),
              ],
              const SizedBox(height: 22),
              if (canCancel) ...[
                AppButton(
                  text: 'Cancel Appointment (बुकिंग रद्द करें)',
                  backgroundColor: Colors.red.shade700,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cancelBooking(context, b, colors);
                  },
                ),
                const SizedBox(height: 10),
              ],
              AppButton(
                text: 'Close',
                isOutlined: true,
                backgroundColor: colors.primary,
                textColor: colors.primary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, AppColorsData colors, {bool isPrice = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isPrice ? 15 : 12.5,
              fontWeight: isPrice ? FontWeight.w800 : FontWeight.w600,
              color: isPrice ? colors.primary : colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
