import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../customer/bookings/services/customer_booking_storage.dart';
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
  final List<String> _filters = [
    'All',
    'New Requests',
    'Confirmed',
    'Rescheduled',
    'Completed',
    'Cancelled',
  ];

  // Instantaneous live state overrides
  final Map<String, PartnerBookingStatus> _liveStatusOverrides = {};
  final Map<String, DateTime> _liveDateTimeOverrides = {};
  final Map<String, String> _liveRescheduleNotes = {};
  final Map<String, String> _liveCancellationReasons = {};

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  Future<void> _refreshBookings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? PartnerState.instance.partner.id;
    if (uid.isNotEmpty) {
      await PartnerState.instance.loadPartnerDataFromFirestore(uid);
    }
    await CustomerBookingStorage.instance.loadBookings();
    if (mounted) setState(() {});
  }

  void _confirmAction(PartnerBookingModel booking, PartnerBookingStatus newStatus) {
    String actionLabel;
    String confirmText;
    Color buttonColor = AppColors.copper;

    switch (newStatus) {
      case PartnerBookingStatus.confirmed:
        actionLabel = 'Confirm Appointment (बुकिंग स्वीकार करें)';
        confirmText = 'Accept & Confirm';
        buttonColor = Colors.green.shade700;
        break;
      case PartnerBookingStatus.completed:
        actionLabel = 'Mark Completed (सेवा पूर्ण हुई)';
        confirmText = 'Complete & Add Earnings';
        buttonColor = Colors.green.shade700;
        break;
      case PartnerBookingStatus.cancelled:
        actionLabel = 'Cancel / Reject Booking (अस्वीकार करें)';
        confirmText = 'Decline Appointment';
        buttonColor = Colors.red.shade600;
        break;
      default:
        actionLabel = 'Update Status';
        confirmText = 'Update';
    }

    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          actionLabel,
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ${booking.bookingRef} for ${booking.customerName}',
              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Service: ${booking.serviceName} • ₹${booking.price.toStringAsFixed(0)}',
              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
            ),
            if (newStatus == PartnerBookingStatus.cancelled) ...[
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Reason for declining (optional)',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedTextGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _liveStatusOverrides[booking.id] = newStatus;
                _liveStatusOverrides[booking.bookingRef] = newStatus;
                if (reasonController.text.trim().isNotEmpty) {
                  _liveCancellationReasons[booking.id] = reasonController.text.trim();
                }
              });

              PartnerState.instance.updateBookingStatus(
                booking.id,
                newStatus,
                cancellationReason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : null,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: buttonColor,
                  content: Text('Booking ${booking.bookingRef} updated successfully!'),
                ),
              );
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showRescheduleModal(BuildContext context, PartnerBookingModel booking) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reschedule Slot (समय बदलें)',
                              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                            ),
                            Text(
                              '${booking.bookingRef} • ${booking.customerName}',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SLOT BUSY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFEBE6DF)),

                    // Date Picker Section
                    Text(
                      'Choose New Date',
                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        Text(
                          '(Tap to change date)',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time Slot Chips
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
                            side: BorderSide(
                              color: isSel ? AppColors.copper : const Color(0xFFEBE6DF),
                            ),
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedSlot = slot);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Reschedule Note / Reason
                    Text(
                      'Message to Customer (ग्राहक के लिए नोट)',
                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Current slot is full, rescheduled to 4 PM.',
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

                              // Compute new DateTime
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

                              setState(() {
                                _liveStatusOverrides[booking.id] = PartnerBookingStatus.rescheduled;
                                _liveStatusOverrides[booking.bookingRef] = PartnerBookingStatus.rescheduled;
                                _liveDateTimeOverrides[booking.id] = newDateTime;
                                _liveRescheduleNotes[booking.id] = noteController.text.trim();
                              });

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
                            child: const Text(
                              'Confirm Reschedule (रीशेड्यूल करें)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
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
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final partnerUid = FirebaseAuth.instance.currentUser?.uid ?? PartnerState.instance.partner.id;
        final partnerSalons = PartnerState.instance.salons;
        final partnerSalonIds = partnerSalons.map((s) => s.salonId).toSet();
        final partnerSalonNames = partnerSalons.map((s) => s.name.trim().toLowerCase()).toSet();
        final selectedBranchId = PartnerState.instance.selectedBranchId;

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
              'Appointments Management',
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

                // Real-time Firestore Stream Merged with Local Storage & State
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                    builder: (context, snapshot) {
                      final Map<String, PartnerBookingModel> merged = {};

                      // 1. Add Firestore snapshot documents
                      final firestoreDocs = snapshot.data?.docs ?? [];
                      for (final doc in firestoreDocs) {
                        final data = doc.data();
                        final b = PartnerBookingModel.fromMap(data, doc.id);
                        merged[b.id] = b;
                      }

                      // 2. Add local storage bookings (so local test bookings are instantly visible)
                      for (final raw in CustomerBookingStorage.instance.currentBookings) {
                        final b = PartnerBookingModel.fromMap(raw, raw['id'] ?? raw['bookingRef']);
                        if (!merged.containsKey(b.id) || b.status != PartnerBookingStatus.newBooking) {
                          merged[b.id] = b;
                        }
                      }

                      // 3. Add PartnerState in-memory bookings
                      for (final b in PartnerState.instance.bookings) {
                        if (!merged.containsKey(b.id) || b.status != PartnerBookingStatus.newBooking) {
                          merged[b.id] = b;
                        }
                      }

                      // 4. Apply instantaneous live status overrides
                      for (final entry in _liveStatusOverrides.entries) {
                        final id = entry.key;
                        if (merged.containsKey(id)) {
                          merged[id] = merged[id]!.copyWith(
                            status: entry.value,
                            appointmentDateTime: _liveDateTimeOverrides[id],
                            rescheduledNote: _liveRescheduleNotes[id],
                            cancellationReason: _liveCancellationReasons[id],
                          );
                        }
                      }

                      // 4. Filter bookings belonging to this partner & salon
                      final List<PartnerBookingModel> partnerFiltered = merged.values.where((b) {
                        final bSalonId = b.salonId ?? '';
                        final bPartnerId = b.partnerId ?? '';
                        final bSalonName = b.branchName.trim().toLowerCase();

                        // Check if booking matches this partner
                        bool isPartnerBooking = false;
                        if (partnerUid.isNotEmpty && bPartnerId == partnerUid) {
                          isPartnerBooking = true;
                        } else if (partnerSalonIds.contains(bSalonId)) {
                          isPartnerBooking = true;
                        } else if (partnerSalonNames.any((sn) => bSalonName.contains(sn))) {
                          isPartnerBooking = true;
                        } else if (bPartnerId == 'partner_default' || bPartnerId.isEmpty) {
                          // Default / unassigned salon booking routed to active partner
                          isPartnerBooking = true;
                        } else if (partnerSalons.length <= 1) {
                          // In single-salon mode, show bookings
                          isPartnerBooking = true;
                        }

                        if (!isPartnerBooking) return false;

                        // Check selected branch filter
                        if (selectedBranchId != 'all') {
                          if (bSalonId != selectedBranchId && b.branchId != selectedBranchId) {
                            return false;
                          }
                        }

                        return true;
                      }).toList();

                      // Sort newest appointment first
                      partnerFiltered.sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime));

                      // 5. Apply Status Filter Tab
                      final displayedBookings = partnerFiltered.where((b) {
                        if (_selectedFilter == 'All') return true;
                        if (_selectedFilter == 'New Requests') return b.status == PartnerBookingStatus.newBooking;
                        if (_selectedFilter == 'Confirmed') return b.status == PartnerBookingStatus.confirmed;
                        if (_selectedFilter == 'Rescheduled') return b.status == PartnerBookingStatus.rescheduled;
                        if (_selectedFilter == 'Completed') return b.status == PartnerBookingStatus.completed;
                        if (_selectedFilter == 'Cancelled') return b.status == PartnerBookingStatus.cancelled;
                        return true;
                      }).toList();

                      return RefreshIndicator(
                        onRefresh: _refreshBookings,
                        color: AppColors.copper,
                        child: displayedBookings.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.mutedTextGray),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No appointments found in "$_selectedFilter"',
                                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'New customer bookings will appear here in real time.',
                                          style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                itemCount: displayedBookings.length,
                                itemBuilder: (context, index) {
                                  final b = displayedBookings[index];
                                  return _buildBookingCard(b);
                                },
                              ),
                      );
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
          const SizedBox(height: 6),

          // Scheduled Date & Time
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.copper),
              const SizedBox(width: 5),
              Text(
                _formatDate(b.appointmentDateTime),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rescheduled Notice if any
          if (b.status == PartnerBookingStatus.rescheduled) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rescheduled Slot: ${_formatDate(b.appointmentDateTime)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                        ),
                        if (b.rescheduledNote != null && b.rescheduledNote!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Note: ${b.rescheduledNote!}',
                            style: TextStyle(fontSize: 11, color: Colors.purple.shade800),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

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

          // Dynamic Action Buttons
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
                  // New Request Actions
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
                    const SizedBox(width: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple.shade700,
                        side: BorderSide(color: Colors.purple.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => _showRescheduleModal(context, b),
                      child: const Text('Reschedule', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () => _confirmAction(b, PartnerBookingStatus.confirmed),
                      child: const Text('Confirm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ]
                  // Confirmed Actions
                  else if (b.status == PartnerBookingStatus.confirmed) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple.shade700,
                        side: BorderSide(color: Colors.purple.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => _showRescheduleModal(context, b),
                      child: const Text('Reschedule', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
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
                  ]
                  // Rescheduled Actions
                  else if (b.status == PartnerBookingStatus.rescheduled) ...[
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

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dt.day}, ${dt.year} • $hour:$minute $ampm';
  }
}
