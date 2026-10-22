import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../models/branch_manager_models.dart';

class BranchManagerState extends ChangeNotifier {
  static final BranchManagerState instance = BranchManagerState._internal();
  factory BranchManagerState() => instance;

  BranchManagerState._internal() {
    _initDefaults();
  }

  late ManagerSessionModel _session;
  late List<BranchManagerBookingModel> _bookings;
  late List<BranchManagerServiceModel> _services;
  late List<BranchManagerStaffModel> _staff;
  late List<BranchManagerNotificationModel> _notifications;
  late List<BranchManagerActivityItem> _activities;

  void _initDefaults() {
    _session = const ManagerSessionModel(
      managerId: 'mgr_01',
      managerName: 'Vikram Malhotra',
      assignedPartnerId: 'partner_01',
      assignedPartnerName: 'Rajesh Sharma',
      assignedSalonId: 'salon_01',
      assignedSalonName: 'The Royal Velvet Luxury Salon',
      assignedBranchId: 'branch_01',
      assignedBranchName: 'Civil Lines Flagship Branch',
      assignedBranchAddress: 'Plot 14/82, The Mall Avenue, Opp. Green Park, Civil Lines, Kanpur (208001)',
      phone: '+91 98390 11223',
      email: 'vikram.manager@velvetsalon.com',
      role: 'Branch Manager',
      isActive: true,
      operatingStatus: 'Open Today',
      openingHours: '09:00 AM - 08:30 PM',
    );

    // Initial mock bookings strictly assigned to branch_01
    _bookings = [
      BranchManagerBookingModel(
        id: 'bkg_101',
        bookingRef: 'TS-BK-7891',
        customerName: 'Ananya Verma',
        customerPhone: '+91 98765 11022',
        serviceName: 'Moroccan Royal Hair Spa & Blowdry',
        category: 'Hair Care',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        timeSlot: '11:30 AM',
        bookingType: BranchBookingType.salonVisit,
        status: BranchBookingStatus.confirmed,
        price: 2499.0,
        notes: 'Requested organic Argan oil serum. Prefers warm water wash.',
        assignedBranchId: 'branch_01',
        stylistName: 'Priya Sengupta (Senior Hair Stylist)',
      ),
      BranchManagerBookingModel(
        id: 'bkg_102',
        bookingRef: 'TS-BK-7892',
        customerName: 'Rohan Mehra',
        customerPhone: '+91 99182 33445',
        serviceName: 'Gentlemen Signature Beard Grooming & Haircut',
        category: 'Men Grooming',
        dateTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
        timeSlot: '01:00 PM',
        bookingType: BranchBookingType.salonVisit,
        status: BranchBookingStatus.newBooking,
        price: 999.0,
        notes: 'First time visit. Requested tea with appointment.',
        assignedBranchId: 'branch_01',
        stylistName: 'Aman Qureshi (Master Barber)',
      ),
      BranchManagerBookingModel(
        id: 'bkg_103',
        bookingRef: 'TS-BK-7893',
        customerName: 'Sneha Kapoor',
        customerPhone: '+91 97210 55667',
        serviceName: 'Bridal Radiant Gold Facial & Manicure',
        category: 'Skin & Facial',
        dateTime: DateTime.now().add(const Duration(hours: 4)),
        timeSlot: '02:30 PM',
        bookingType: BranchBookingType.homeService,
        status: BranchBookingStatus.newBooking,
        price: 3499.0,
        homeAddress: 'Flat 402, Royal Residency, Tilak Nagar, Kanpur (Distance: 3.8 km)',
        notes: 'Doorstep service. Please bring sterilized single-use kit.',
        assignedBranchId: 'branch_01',
        stylistName: 'Neha Awasthi (Skin Specialist)',
      ),
      BranchManagerBookingModel(
        id: 'bkg_104',
        bookingRef: 'TS-BK-7894',
        customerName: 'Kavita Singhania',
        customerPhone: '+91 94150 99881',
        serviceName: 'Aromatherapy Deep Relax Full Body Massage',
        category: 'Spa & Wellness',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        timeSlot: '09:30 AM',
        bookingType: BranchBookingType.salonVisit,
        status: BranchBookingStatus.completed,
        price: 3200.0,
        notes: 'VIP suite reserved. Completed on schedule.',
        assignedBranchId: 'branch_01',
        stylistName: 'Sunita Roy (Wellness Therapist)',
      ),
      BranchManagerBookingModel(
        id: 'bkg_105',
        bookingRef: 'TS-BK-7895',
        customerName: 'Aditya Srivastava',
        customerPhone: '+91 98899 44321',
        serviceName: 'Charcoal Detox D-Tan & Express Clean Up',
        category: 'Skin Care',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        timeSlot: '12:00 PM',
        bookingType: BranchBookingType.salonVisit,
        status: BranchBookingStatus.confirmed,
        price: 1250.0,
        notes: 'Express treatment requested.',
        assignedBranchId: 'branch_01',
        stylistName: 'Aman Qureshi (Master Barber)',
      ),
      BranchManagerBookingModel(
        id: 'bkg_106',
        bookingRef: 'TS-BK-7896',
        customerName: 'Meera Chawla',
        customerPhone: '+91 96500 77123',
        serviceName: 'Gel Nail Art & Pedicure Pampering',
        category: 'Nail Studio',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        timeSlot: '04:00 PM',
        bookingType: BranchBookingType.homeService,
        status: BranchBookingStatus.cancelled,
        price: 1800.0,
        homeAddress: 'House 12/B, Swaroop Nagar, Kanpur',
        notes: 'Customer requested reschedule due to emergency.',
        assignedBranchId: 'branch_01',
        stylistName: 'Priya Sengupta (Senior Hair Stylist)',
      ),
    ];

    // Branch services (View-Only, assigned to branch_01)
    _services = [
      const BranchManagerServiceModel(
        id: 'srv_1',
        name: 'Moroccan Royal Hair Spa & Blowdry',
        category: 'Hair Care',
        price: 2499.0,
        durationMinutes: 60,
        salonVisitAvailable: true,
        homeServiceAvailable: true,
        isActive: true,
        assignedBranchId: 'branch_01',
        image: AssetConstants.maleBanner1,
      ),
      const BranchManagerServiceModel(
        id: 'srv_2',
        name: 'Bridal Radiant Gold Facial',
        category: 'Facial & Skin',
        price: 3499.0,
        durationMinutes: 90,
        salonVisitAvailable: true,
        homeServiceAvailable: true,
        isActive: true,
        assignedBranchId: 'branch_01',
        image: AssetConstants.partnerLoginIllu,
      ),
      const BranchManagerServiceModel(
        id: 'srv_3',
        name: 'Gentlemen Signature Beard & Haircut',
        category: 'Men Grooming',
        price: 999.0,
        durationMinutes: 45,
        salonVisitAvailable: true,
        homeServiceAvailable: false,
        isActive: true,
        assignedBranchId: 'branch_01',
        image: AssetConstants.roleCustomer,
      ),
      const BranchManagerServiceModel(
        id: 'srv_4',
        name: 'Aromatherapy Deep Relax Body Massage',
        category: 'Spa & Wellness',
        price: 3200.0,
        durationMinutes: 75,
        salonVisitAvailable: true,
        homeServiceAvailable: false,
        isActive: true,
        assignedBranchId: 'branch_01',
        image: AssetConstants.rolePartner,
      ),
      const BranchManagerServiceModel(
        id: 'srv_5',
        name: 'Gel Nail Art & Pedicure Pampering',
        category: 'Nail Care',
        price: 1800.0,
        durationMinutes: 50,
        salonVisitAvailable: true,
        homeServiceAvailable: true,
        isActive: true,
        assignedBranchId: 'branch_01',
        image: AssetConstants.roleManager,
      ),
    ];

    // Branch staff (View-Only, assigned to branch_01)
    _staff = [
      const BranchManagerStaffModel(
        id: 'stf_1',
        name: 'Priya Sengupta',
        role: 'Senior Hair Stylist & Colorist',
        experienceYears: 7,
        rating: 4.9,
        assignedBranchId: 'branch_01',
        availability: 'On Duty',
        phone: '+91 98711 22334',
        image: AssetConstants.rolePartner,
      ),
      const BranchManagerStaffModel(
        id: 'stf_2',
        name: 'Aman Qureshi',
        role: 'Master Barber & Beard Artist',
        experienceYears: 6,
        rating: 4.8,
        assignedBranchId: 'branch_01',
        availability: 'On Duty',
        phone: '+91 99182 88776',
        image: AssetConstants.roleCustomer,
      ),
      const BranchManagerStaffModel(
        id: 'stf_3',
        name: 'Neha Awasthi',
        role: 'Senior Skin Specialist & Esthetician',
        experienceYears: 5,
        rating: 4.9,
        assignedBranchId: 'branch_01',
        availability: 'Available',
        phone: '+91 97210 33441',
        image: AssetConstants.prefFemale,
      ),
      const BranchManagerStaffModel(
        id: 'stf_4',
        name: 'Sunita Roy',
        role: 'Luxury Spa & Wellness Therapist',
        experienceYears: 8,
        rating: 5.0,
        assignedBranchId: 'branch_01',
        availability: 'On Break',
        phone: '+91 94150 11228',
        image: AssetConstants.prefMale,
      ),
    ];

    // Branch notifications (assigned to branch_01)
    _notifications = [
      BranchManagerNotificationModel(
        id: 'ntf_1',
        title: 'New Online Booking Received',
        description: 'Sneha Kapoor booked Bridal Gold Facial (Home Service) for 02:30 PM.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        type: 'booking',
        isRead: false,
        assignedBranchId: 'branch_01',
      ),
      BranchManagerNotificationModel(
        id: 'ntf_2',
        title: 'Appointment Confirmed',
        description: 'Ananya Verma confirmed appointment for Moroccan Hair Spa at 11:30 AM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'confirmation',
        isRead: false,
        assignedBranchId: 'branch_01',
      ),
      BranchManagerNotificationModel(
        id: 'ntf_3',
        title: 'Partner Notice: Festival Rush Protocol',
        description: 'Partner Rajesh Sharma updated branch weekend operational guidelines.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        type: 'announcement',
        isRead: true,
        assignedBranchId: 'branch_01',
      ),
      BranchManagerNotificationModel(
        id: 'ntf_4',
        title: 'Appointment Completed',
        description: 'Kavita Singhania completed Aromatherapy Spa treatment.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'completion',
        isRead: true,
        assignedBranchId: 'branch_01',
      ),
    ];

    _activities = [
      BranchManagerActivityItem(
        id: 'act_1',
        title: 'New Booking Received',
        description: 'Sneha Kapoor • Bridal Gold Facial (Home Visit)',
        time: DateTime.now().subtract(const Duration(minutes: 18)),
        type: 'new',
      ),
      BranchManagerActivityItem(
        id: 'act_2',
        title: 'Booking Confirmed',
        description: 'Ananya Verma • Moroccan Hair Spa (Salon Visit)',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'confirmed',
      ),
      BranchManagerActivityItem(
        id: 'act_3',
        title: 'Appointment Completed',
        description: 'Kavita Singhania • Aromatherapy Spa (VIP Suite)',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'completed',
      ),
      BranchManagerActivityItem(
        id: 'act_4',
        title: 'Appointment Rescheduled/Cancelled',
        description: 'Meera Chawla • Gel Nail Art (Home Service)',
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: 'cancelled',
      ),
    ];
  }

  // Getters
  ManagerSessionModel get session => _session;
  List<BranchManagerBookingModel> get bookings => List.unmodifiable(_bookings);
  List<BranchManagerServiceModel> get services => List.unmodifiable(_services);
  List<BranchManagerStaffModel> get staff => List.unmodifiable(_staff);
  List<BranchManagerNotificationModel> get notifications => List.unmodifiable(_notifications);
  List<BranchManagerActivityItem> get activities => List.unmodifiable(_activities);

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  int get todayBookingsCount => _bookings.length;

  int get pendingBookingsCount =>
      _bookings.where((b) => b.status == BranchBookingStatus.newBooking).length;

  int get confirmedBookingsCount =>
      _bookings.where((b) => b.status == BranchBookingStatus.confirmed).length;

  int get completedBookingsCount =>
      _bookings.where((b) => b.status == BranchBookingStatus.completed).length;

  int get cancelledBookingsCount =>
      _bookings.where((b) => b.status == BranchBookingStatus.cancelled).length;

  List<BranchManagerBookingModel> get todayAppointments => _bookings.take(4).toList();

  // Booking Status Actions
  bool confirmBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      // Only permit newBooking -> confirmed
      if (current.status == BranchBookingStatus.newBooking) {
        _bookings[index] = current.copyWith(status: BranchBookingStatus.confirmed);
        _activities.insert(
          0,
          BranchManagerActivityItem(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Booking Confirmed',
            description: '${current.customerName} • ${current.serviceName}',
            time: DateTime.now(),
            type: 'confirmed',
          ),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool completeBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      // Only permit confirmed -> completed
      if (current.status == BranchBookingStatus.confirmed) {
        _bookings[index] = current.copyWith(status: BranchBookingStatus.completed);
        _activities.insert(
          0,
          BranchManagerActivityItem(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Appointment Completed',
            description: '${current.customerName} • ${current.serviceName}',
            time: DateTime.now(),
            type: 'completed',
          ),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool cancelBooking(String bookingId, String reason) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      // Do not allow cancelling already completed booking
      if (current.status != BranchBookingStatus.completed &&
          current.status != BranchBookingStatus.cancelled) {
        _bookings[index] = current.copyWith(
          status: BranchBookingStatus.cancelled,
          notes: '${current.notes ?? ""} [Cancelled by Branch Manager: $reason]',
        );
        _activities.insert(
          0,
          BranchManagerActivityItem(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Booking Cancelled',
            description: '${current.customerName} • Reason: $reason',
            time: DateTime.now(),
            type: 'cancelled',
          ),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void updateAssignedBranchImage(String image) {
    _session = _session.copyWith(assignedBranchImage: image);
    notifyListeners();
  }

  void updateAssignedBranch({
    String? salonName,
    String? branchName,
    String? address,
    String? image,
  }) {
    _session = _session.copyWith(
      assignedSalonName: salonName ?? _session.assignedSalonName,
      assignedBranchName: branchName ?? _session.assignedBranchName,
      assignedBranchAddress: address ?? _session.assignedBranchAddress,
      assignedBranchImage: image ?? _session.assignedBranchImage,
    );
    notifyListeners();
  }

  void resetDefaults() {
    _initDefaults();
    notifyListeners();
  }
}
