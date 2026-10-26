import 'package:flutter/material.dart';
import '../../branch_manager/data/branch_manager_state.dart';
import '../models/partner_models.dart';
import 'partner_mock_data.dart';

class PartnerState extends ChangeNotifier {
  static final PartnerState instance = PartnerState._internal();
  factory PartnerState() => instance;

  PartnerState._internal() {
    _initDefaults();
  }

  late PartnerModel _partner;
  late List<PartnerDocumentModel> _documents;
  late SalonModel _salon;
  late List<BranchManagerModel> _managers;
  late List<SalonServiceModel> _services;
  late HomeServiceSettingsModel _homeService;
  late List<PartnerBookingModel> _bookings;
  late List<EarningsTransactionModel> _transactions;
  late List<PartnerNotificationModel> _notifications;
  String _selectedBranchId = 'all';

  void _initDefaults() {
    _partner = PartnerMockData.initialPartner;
    _documents = List.from(PartnerMockData.initialDocuments);
    _salon = PartnerMockData.initialSalon;
    _managers = List.from(PartnerMockData.initialManagers);
    _services = List.from(PartnerMockData.initialServices);
    _homeService = PartnerMockData.initialHomeService;
    _bookings = List.from(PartnerMockData.initialBookings);
    _transactions = List.from(PartnerMockData.initialTransactions);
    _notifications = List.from(PartnerMockData.initialNotifications);
    _selectedBranchId = 'all';
  }

  // Getters
  PartnerModel get partner => _partner;
  List<PartnerDocumentModel> get documents => List.unmodifiable(_documents);
  SalonModel get salon => _salon;
  List<BranchModel> get branches => List.unmodifiable(_salon.branches);
  List<BranchManagerModel> get managers => List.unmodifiable(_managers);
  List<SalonServiceModel> get services => List.unmodifiable(_services);
  HomeServiceSettingsModel get homeService => _homeService;
  List<PartnerBookingModel> get bookings => List.unmodifiable(_bookings);
  List<EarningsTransactionModel> get transactions => List.unmodifiable(_transactions);
  List<PartnerNotificationModel> get notifications => List.unmodifiable(_notifications);
  String get selectedBranchId => _selectedBranchId;

  BranchModel? get currentBranch {
    if (_selectedBranchId == 'all' || _salon.branches.isEmpty) {
      return _salon.branches.isNotEmpty ? _salon.branches.first : null;
    }
    return _salon.branches.firstWhere(
      (b) => b.branchId == _selectedBranchId,
      orElse: () => _salon.branches.first,
    );
  }

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  int get todayBookingsCount => _bookings.length;

  int get pendingBookingsCount => _bookings
      .where((b) => b.status == PartnerBookingStatus.newBooking)
      .length;

  int get activeServicesCount =>
      _services.where((s) => s.isActive).length;

  double get todayEarnings {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get weeklyEarnings {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _transactions
        .where((t) => t.date.isAfter(weekAgo))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get monthlyEarnings {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return _transactions
        .where((t) => t.date.isAfter(monthAgo))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Actions
  void registerPartner({
    required String fullName,
    required String email,
    required String phone,
    required String businessName,
  }) {
    _partner = PartnerModel(
      id: 'partner_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone,
      businessName: businessName,
      verificationStatus: PartnerVerificationStatus.notSubmitted,
    );
    _documents = [];
    notifyListeners();
  }

  void setPartner(PartnerModel partner) {
    _partner = partner;
    _documents = List.from(partner.documents);
    notifyListeners();
  }

  void setDocuments(List<PartnerDocumentModel> docs) {
    _documents = List.from(docs);
    notifyListeners();
  }

  void addDocument(PartnerDocumentModel doc) {
    _documents.add(doc);
    notifyListeners();
  }

  void removeDocument(String docId) {
    _documents.removeWhere((d) => d.id == docId);
    notifyListeners();
  }

  void submitVerification() {
    _partner = _partner.copyWith(
      verificationStatus: PartnerVerificationStatus.underReview,
    );
    _notifications.insert(
      0,
      PartnerNotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Documents Submitted for Verification',
        description:
            'Your business verification documents are under review by The Salon Times Admin.',
        timestamp: DateTime.now(),
        type: 'verification',
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void setVerificationStatusDemo(PartnerVerificationStatus status) {
    _partner = _partner.copyWith(verificationStatus: status);
    _salon = _salon.copyWith(verificationStatus: status);
    notifyListeners();
  }

  void createSalon(SalonModel newSalon) {
    _salon = newSalon;
    if (newSalon.photos.isNotEmpty) {
      BranchManagerState.instance.updateAssignedBranch(
        salonName: newSalon.name,
        branchName: newSalon.branches.isNotEmpty ? newSalon.branches.first.branchName : 'Main Flagship',
        address: '${newSalon.address}, ${newSalon.city}',
        image: newSalon.photos.first,
      );
    } else {
      BranchManagerState.instance.updateAssignedBranch(
        salonName: newSalon.name,
        branchName: newSalon.branches.isNotEmpty ? newSalon.branches.first.branchName : 'Main Flagship',
        address: '${newSalon.address}, ${newSalon.city}',
      );
    }
    notifyListeners();
  }

  void updateSalon(SalonModel updated) {
    _salon = updated;
    if (updated.photos.isNotEmpty) {
      BranchManagerState.instance.updateAssignedBranch(
        salonName: updated.name,
        address: '${updated.address}, ${updated.city}',
        image: updated.photos.first,
      );
    } else {
      BranchManagerState.instance.updateAssignedBranch(
        salonName: updated.name,
        address: '${updated.address}, ${updated.city}',
      );
    }
    notifyListeners();
  }

  void selectBranch(String branchId) {
    _selectedBranchId = branchId;
    notifyListeners();
  }

  void addBranch(BranchModel branch) {
    final list = List<BranchModel>.from(_salon.branches)..add(branch);
    _salon = _salon.copyWith(branches: list);
    notifyListeners();
  }

  void updateBranch(BranchModel updated) {
    final list = _salon.branches
        .map((b) => b.branchId == updated.branchId ? updated : b)
        .toList();
    _salon = _salon.copyWith(branches: list);
    notifyListeners();
  }

  void addManager(BranchManagerModel manager) {
    _managers.add(manager);
    // Link manager to branch
    final updatedBranches = _salon.branches.map((b) {
      if (b.branchId == manager.assignedBranchId) {
        return b.copyWith(
          managerId: manager.managerId,
          managerName: manager.fullName,
        );
      }
      return b;
    }).toList();
    _salon = _salon.copyWith(branches: updatedBranches);

    _notifications.insert(
      0,
      PartnerNotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Branch Manager Added',
        description:
            '${manager.fullName} assigned to ${manager.assignedBranchName}.',
        timestamp: DateTime.now(),
        type: 'manager',
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void toggleManagerStatus(String managerId) {
    final index = _managers.indexWhere((m) => m.managerId == managerId);
    if (index != -1) {
      final current = _managers[index];
      _managers[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  void addService(SalonServiceModel service) {
    _services.insert(0, service);
    notifyListeners();
  }

  void updateService(SalonServiceModel service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
      notifyListeners();
    }
  }

  void toggleServiceStatus(String serviceId) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final current = _services[index];
      _services[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  void updateHomeServiceSettings(HomeServiceSettingsModel settings) {
    _homeService = settings;
    _salon = _salon.copyWith(isHomeServiceEnabled: settings.isEnabled);
    notifyListeners();
  }

  void toggleHomeService(bool enabled) {
    _homeService = _homeService.copyWith(isEnabled: enabled);
    _salon = _salon.copyWith(isHomeServiceEnabled: enabled);
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, PartnerBookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      _bookings[index] = booking.copyWith(status: newStatus);

      // If marked completed, record mock transaction
      if (newStatus == PartnerBookingStatus.completed) {
        _transactions.insert(
          0,
          EarningsTransactionModel(
            id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
            bookingRef: booking.bookingRef,
            serviceName: booking.serviceName,
            amount: booking.price,
            date: DateTime.now(),
            customerName: booking.customerName,
            paymentType: booking.bookingType == PartnerBookingType.homeService
                ? 'Online (Advance)'
                : 'Counter (UPI)',
          ),
        );
      }

      notifyListeners();
    }
  }

  void markNotificationAsRead(String notifId) {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void updatePartner(PartnerModel updated) {
    _partner = updated;
    notifyListeners();
  }

  void updatePartnerPhoto(String photoPath) {
    _partner = _partner.copyWith(profilePhoto: photoPath);
    notifyListeners();
  }

  void resetDefaults() {
    _initDefaults();
    notifyListeners();
  }
}
