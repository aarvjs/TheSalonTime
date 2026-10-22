import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/branch_manager_state.dart';
import '../../models/branch_manager_models.dart';

class ManagerBookingsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const ManagerBookingsScreen({super.key, this.onOpenDrawer});

  @override
  State<ManagerBookingsScreen> createState() => _ManagerBookingsScreenState();
}

class _ManagerBookingsScreenState extends State<ManagerBookingsScreen> {
  final _searchController = TextEditingController();
  BranchBookingStatus? _selectedStatus; // null means 'All'
  bool _sortEarliestFirst = true;

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All', 'status': null},
    {'label': 'New', 'status': BranchBookingStatus.newBooking},
    {'label': 'Confirmed', 'status': BranchBookingStatus.confirmed},
    {'label': 'Completed', 'status': BranchBookingStatus.completed},
    {'label': 'Cancelled', 'status': BranchBookingStatus.cancelled},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BranchManagerState.instance,
      builder: (context, _) {
        final state = BranchManagerState.instance;
        final rawBookings = state.bookings;
        final query = _searchController.text.trim().toLowerCase();

        // 1. Filter by Status
        var list = rawBookings.where((b) {
          if (_selectedStatus != null && b.status != _selectedStatus) {
            return false;
          }
          if (query.isNotEmpty) {
            final matchesName = b.customerName.toLowerCase().contains(query);
            final matchesRef = b.bookingRef.toLowerCase().contains(query);
            final matchesService = b.serviceName.toLowerCase().contains(query);
            if (!matchesName && !matchesRef && !matchesService) return false;
          }
          return true;
        }).toList();

        // 2. Sort by Date/Time
        list.sort((a, b) {
          return _sortEarliestFirst
              ? a.dateTime.compareTo(b.dateTime)
              : b.dateTime.compareTo(a.dateTime);
        });

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
              'Branch Bookings',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _sortEarliestFirst ? Icons.sort_rounded : Icons.swap_vert_rounded,
                  color: AppColors.managerEmerald,
                ),
                tooltip: _sortEarliestFirst ? 'Earliest first' : 'Latest first',
                onPressed: () {
                  setState(() => _sortEarliestFirst = !_sortEarliestFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.managerEmerald,
                      duration: const Duration(seconds: 1),
                      content: Text(
                        _sortEarliestFirst ? 'Sorted: Earliest appointments first' : 'Sorted: Latest appointments first',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by booking ref, customer name, service...',
                      hintStyle: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.managerEmerald, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDFE7E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.managerEmerald, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // Status Filter Chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterChips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final item = _filterChips[i];
                      final isSelected = _selectedStatus == item['status'];
                      return ChoiceChip(
                        label: Text(item['label']),
                        selected: isSelected,
                        selectedColor: AppColors.managerEmerald,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.charcoal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.managerEmerald : const Color(0xFFDFE7E2),
                        ),
                        onSelected: (_) {
                          setState(() => _selectedStatus = item['status']);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Bookings List
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_rounded, size: 48, color: AppColors.mutedTextGray.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'No matching bookings found for this branch',
                                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try clearing your search query or switching filters',
                                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final booking = list[index];
                            return _buildBookingCard(context, booking);
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

  Widget _buildBookingCard(BuildContext context, BranchManagerBookingModel booking) {
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
          // Top Row: Ref & Type & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingRef,
                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHome ? Colors.purple.shade50 : AppColors.warmGray,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isHome ? Colors.purple.shade200 : const Color(0xFFD6D0C7)),
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
                            color: isHome ? Colors.purple.shade800 : AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

          // Customer Name & Service Name
          Text(
            booking.customerName,
            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            booking.serviceName,
            style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),

          // Home Service Address (if applicable)
          if (isHome && booking.homeAddress != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
              children: [
                  Icon(Icons.pin_drop_rounded, size: 14, color: Colors.purple.shade800),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.homeAddress!,
                      style: AppTextStyles.caption(color: Colors.purple.shade900).copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          const Divider(height: 12, color: Color(0xFFEBE6DF)),

          // Bottom Row: Date/Time, Stylist & View Details CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: AppColors.managerEmerald),
                        const SizedBox(width: 4),
                        Text(
                          '${booking.timeSlot} • ₹${booking.price.toInt()}',
                          style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Staff: ${booking.stylistName.split('(').first.trim()}',
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.managerEmerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 34),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.managerBookingDetails,
                    arguments: booking.id,
                  );
                },
                child: const Text('View Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
