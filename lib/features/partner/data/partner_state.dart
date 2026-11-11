import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../branch_manager/data/branch_manager_state.dart';
import '../../customer/bookings/services/customer_booking_storage.dart';
import '../models/partner_models.dart';
import '../services/partner_firestore_service.dart';

class PartnerState extends ChangeNotifier {
  static final PartnerState instance = PartnerState._internal();
  factory PartnerState() => instance;

  PartnerState._internal() {
    _initDefaults();
  }

  static final SalonModel _emptySalon = SalonModel(
    salonId: '',
    partnerId: '',
    name: 'My Salon',
    description: '',
    category: 'Unisex Salon',
    address: '',
    city: '',
    state: '',
    postalCode: '',
    latitude: 26.4719,
    longitude: 80.3524,
    phone: '',
    email: '',
    openingHours: '09:00 AM',
    closingHours: '09:00 PM',
    operatingDays: const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    facilities: const [],
    photos: const [],
    verificationStatus: PartnerVerificationStatus.notSubmitted,
    salonStatus: true,
    isHomeServiceEnabled: false,
    services: const [],
  );


  late PartnerModel _partner;
  late List<PartnerDocumentModel> _documents;
  late SalonModel _salon;
  late List<SalonModel> _salons;
  late List<BranchManagerModel> _managers;
  late List<SalonServiceModel> _services;
  late HomeServiceSettingsModel _homeService;
  late HomeServiceProfileModel _homeProfile;
  late List<PartnerBookingModel> _bookings;
  late List<EarningsTransactionModel> _transactions;
  late List<PartnerNotificationModel> _notifications;
  String _selectedBranchId = 'all';

  void _initDefaults() {
    final currentAuthUser = FirebaseAuth.instance.currentUser;
    if (currentAuthUser != null) {
      _partner = PartnerModel(
        id: currentAuthUser.uid,
        fullName: (currentAuthUser.displayName != null && currentAuthUser.displayName!.isNotEmpty)
            ? currentAuthUser.displayName!
            : 'Salon Partner',
        email: currentAuthUser.email ?? '',
        phone: currentAuthUser.phoneNumber ?? '',
        businessName: 'My Salon Business',
        verificationStatus: PartnerVerificationStatus.notSubmitted,
        businessModel: PartnerBusinessModel.both,
        activeBusinessModel: PartnerBusinessModel.both,
      );
    } else {
      _partner = const PartnerModel(
        id: '',
        fullName: 'Salon Partner',
        email: '',
        phone: '',
        businessName: 'My Salon Business',
        verificationStatus: PartnerVerificationStatus.notSubmitted,
        businessModel: PartnerBusinessModel.both,
        activeBusinessModel: PartnerBusinessModel.both,
      );
    }

    _documents = [];
    _salons = [];
    _salon = _emptySalon;
    _managers = [];
    _services = [];
    _homeService = const HomeServiceSettingsModel(
      isEnabled: false,
      serviceRadiusKm: 10.0,
    );
    _homeProfile = HomeServiceProfileModel(
      partnerId: _partner.id,
      isAvailable: false,
      professionalName: _partner.fullName,
      phone: _partner.phone,
      email: _partner.email,
      skills: const ['Haircut & Styling', 'Beard Grooming'],
      experienceYears: 0,
      serviceRadiusKm: 10.0,
      baseAddress: '',
      baseCity: '',
      latitude: 26.4719,
      longitude: 80.3524,
      services: const [],
    );
    _bookings = [];
    _transactions = [];
    _notifications = [];
    _selectedBranchId = 'all';

    // Auto-sync dynamic data from Firestore if already logged in
    if (currentAuthUser != null && currentAuthUser.uid.isNotEmpty) {
      loadPartnerDataFromFirestore(currentAuthUser.uid);
    }
  }

  // Getters
  PartnerModel get partner => _partner;
  List<PartnerDocumentModel> get documents => List.unmodifiable(_documents);
  SalonModel get salon => _salons.isNotEmpty ? _salons.first : _salon;
  List<SalonModel> get salons => List.unmodifiable(_salons);

  /// Returns all branches across all registered salons cleanly and safely
  List<BranchModel> get branches {
    final list = <BranchModel>[];
    for (final s in _salons) {
      if (s.branches.isNotEmpty) {
        list.addAll(s.branches);
      } else {
        list.add(BranchModel.fromSalon(s));
      }
    }
    return List.unmodifiable(list);
  }

  List<BranchManagerModel> get managers => List.unmodifiable(_managers);
  List<SalonServiceModel> get services => List.unmodifiable(_services);
  HomeServiceSettingsModel get homeService => _homeService;
  HomeServiceProfileModel get homeProfile => _homeProfile;
  List<PartnerBookingModel> get allBookings => List.unmodifiable(_bookings);
  List<EarningsTransactionModel> get transactions => List.unmodifiable(_transactions);
  List<PartnerNotificationModel> get notifications => List.unmodifiable(_notifications);
  String get selectedBranchId => _selectedBranchId;

  String? _selectedServiceSalonId;
  String get selectedServiceSalonId {
    if (_selectedServiceSalonId != null && _selectedServiceSalonId!.isNotEmpty) {
      return _selectedServiceSalonId!;
    }
    return _salons.isNotEmpty ? _salons.first.salonId : '';
  }

  void setSelectedServiceSalon(String salonId) {
    _selectedServiceSalonId = salonId;
    notifyListeners();
  }

  /// Returns services specifically belonging to the selected salon location
  List<SalonServiceModel> get currentSalonServices {
    final sId = selectedServiceSalonId;
    if (sId.isEmpty && _salons.isEmpty) return List.unmodifiable(_services);
    final targetSalon = _salons.where((s) => s.salonId == sId).firstOrNull ??
        (_salons.isNotEmpty ? _salons.first : null);
    if (targetSalon != null) {
      return List.unmodifiable(targetSalon.services);
    }
    return List.unmodifiable(_services);
  }

  // Active Business Model
  PartnerBusinessModel get businessModel => _partner.businessModel;
  PartnerBusinessModel get activeBusinessModel => _partner.activeBusinessModel;

  bool get isSalonModelActive =>
      activeBusinessModel == PartnerBusinessModel.salon ||
      activeBusinessModel == PartnerBusinessModel.both;

  bool get isHomeServiceModelActive =>
      activeBusinessModel == PartnerBusinessModel.homeService ||
      activeBusinessModel == PartnerBusinessModel.both;

  /// Returns the currently filtered salon, or the primary salon if 'all' is selected
  SalonModel? get currentSalon {
    if (_salons.isEmpty) return null;
    if (_selectedBranchId == 'all') {
      return _salons.first;
    }
    for (final s in _salons) {
      if (s.salonId == _selectedBranchId) return s;
      if (s.branches.any((b) => b.branchId == _selectedBranchId)) return s;
    }
    return _salons.first;
  }

  /// Returns the currently filtered branch, safely guarding against empty collections
  BranchModel? get currentBranch {
    if (_salons.isEmpty) return null;
    if (_selectedBranchId == 'all') {
      return _salons.first.branches.isNotEmpty
          ? _salons.first.branches.first
          : BranchModel.fromSalon(_salons.first);
    }
    for (final s in _salons) {
      if (s.salonId == _selectedBranchId) {
        return s.branches.isNotEmpty ? s.branches.first : BranchModel.fromSalon(s);
      }
      for (final b in s.branches) {
        if (b.branchId == _selectedBranchId) {
          return b;
        }
      }
    }
    return _salons.first.branches.isNotEmpty
        ? _salons.first.branches.first
        : BranchModel.fromSalon(_salons.first);
  }

  /// Branch/Salon filtered bookings (0 if no bookings yet in Firebase)
  List<PartnerBookingModel> get bookings {
    if (_selectedBranchId == 'all') {
      return List.unmodifiable(_bookings);
    }
    final targetSalon = currentSalon;
    final targetBranch = currentBranch;
    if (targetSalon == null && targetBranch == null) {
      return List.unmodifiable(_bookings);
    }

    final sId = targetSalon?.salonId ?? '';
    final bId = targetBranch?.branchId ?? '';
    final name = (targetSalon?.name ?? targetBranch?.branchName ?? '').trim().toLowerCase();

    return List.unmodifiable(
      _bookings.where((b) {
        if (sId.isNotEmpty && (b.salonId == sId || b.id == sId)) return true;
        if (bId.isNotEmpty && b.branchId == bId) return true;
        if (name.isNotEmpty && b.branchName.trim().toLowerCase().contains(name)) return true;
        return false;
      }),
    );
  }

  /// Home service specific bookings
  List<PartnerBookingModel> get homeServiceBookings {
    return List.unmodifiable(
      _bookings.where((b) => b.bookingType == PartnerBookingType.homeService),
    );
  }

  /// Salon visit specific bookings
  List<PartnerBookingModel> get salonVisitBookings {
    return List.unmodifiable(
      bookings.where((b) => b.bookingType == PartnerBookingType.salonVisit),
    );
  }

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  int get todayBookingsCount => bookings.length;

  int get pendingBookingsCount => bookings
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

  // ==========================================
  // REAL FIRESTORE DATA SYNC (DYNAMIC)
  // ==========================================

  /// Load all partner data dynamically from Firestore (Profile, Salons, Branches, Home Service, Managers, Bookings)
  Future<void> loadPartnerDataFromFirestore(String uid) async {
    try {
      if (uid.isEmpty) return;

      // 1. Fetch Partner Profile
      final p = await PartnerFirestoreService.instance.getPartnerProfile(uid);
      if (p != null) {
        _partner = p;
        _documents = List.from(p.documents);
      }

      // 2. Fetch Salon Locations (My Salons)
      final salonsList = await PartnerFirestoreService.instance.fetchPartnerSalons(uid);
      if (salonsList.isNotEmpty) {
        _salons = salonsList;
        _salon = salonsList.first;
      } else {
        final s = await PartnerFirestoreService.instance.getSalonProfile(uid);
        if (s != null) {
          _salon = s;
          _salons = [s];
        } else {
          // If Firestore is empty, purge any mock salons and keep only user-created salon if present
          _salons.removeWhere((s) => s.salonId == 'salon_001' || s.salonId == 'salon_mock' || s.name.contains('Velvet Luxury'));
          if (_salons.isNotEmpty) {
            _salon = _salons.first;
            PartnerFirestoreService.instance.saveSalonLocation(_salons.first);
          }
        }
      }

      // 3. Dynamic Services aggregation from real salons
      if (_salons.isNotEmpty) {
        final allSalonServices = <SalonServiceModel>[];
        for (final s in _salons) {
          allSalonServices.addAll(s.services);
        }
        _services = allSalonServices;
      } else {
        _services = [];
      }

      // 4. Fetch Home Service Profile
      final h = await PartnerFirestoreService.instance.getHomeServiceProfile(uid);
      if (h != null) {
        _homeProfile = h;
        _homeService = _homeService.copyWith(
          isEnabled: h.isAvailable,
          serviceRadiusKm: h.serviceRadiusKm,
        );
      }

      // 5. Fetch Managers
      final mgrList = await PartnerFirestoreService.instance.fetchBranchManagers(uid);
      _managers = mgrList;

      // 6. Fetch Real Bookings from Firestore (0 if none)
      final salonIds = _salons.map((s) => s.salonId).toList();
      final salonNames = _salons.map((s) => s.name).toList();
      final bookingsList = await PartnerFirestoreService.instance.fetchPartnerBookings(
        uid,
        salonIds: salonIds,
        salonNames: salonNames,
      );
      _bookings = bookingsList;

      // 7. Fetch Real Financial Transactions from Firestore (0 if none)
      final txList = await PartnerFirestoreService.instance.fetchPartnerTransactions(uid);
      _transactions = txList;

      // Verify selected branch selection
      if (_selectedBranchId != 'all' && !_salons.any((s) => s.salonId == _selectedBranchId)) {
        _selectedBranchId = 'all';
      }

      notifyListeners();
      developer.log('Partner data loaded dynamically from Firestore: uid=$uid, salons=${_salons.length}, bookings=${_bookings.length}');
    } catch (e, stack) {
      developer.log('Error loading partner data from Firestore: $e', error: e, stackTrace: stack);
    }
  }

  // Actions
  void registerPartner({
    required String fullName,
    required String email,
    required String phone,
    required String businessName,
    PartnerBusinessModel businessModel = PartnerBusinessModel.both,
  }) {
    _partner = PartnerModel(
      id: 'partner_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone,
      businessName: businessName,
      verificationStatus: PartnerVerificationStatus.notSubmitted,
      businessModel: businessModel,
      activeBusinessModel: businessModel,
    );
    _documents = [];
    notifyListeners();
  }

  void setBusinessModel(PartnerBusinessModel model) {
    _partner = _partner.copyWith(
      businessModel: model,
      activeBusinessModel: model,
    );
    PartnerFirestoreService.instance.updateBusinessModel(_partner.id, model);
    notifyListeners();
  }

  void setActiveBusinessModel(PartnerBusinessModel model) {
    _partner = _partner.copyWith(activeBusinessModel: model);
    PartnerFirestoreService.instance.updateBusinessModel(_partner.id, model);
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
    addSalon(newSalon);
  }

  void addSalon(SalonModel newSalon) {
    final withPartner = newSalon.copyWith(
      partnerId: _partner.id.isNotEmpty
          ? _partner.id
          : (FirebaseAuth.instance.currentUser?.uid ?? 'partner_demo'),
    );

    // Purge mock salon if any exists
    _salons.removeWhere((s) =>
        s.salonId == 'salon_001' ||
        s.salonId == 'salon_mock' ||
        s.name.contains('Velvet Luxury'));

    final idx = _salons.indexWhere((s) => s.salonId == withPartner.salonId);
    if (idx != -1) {
      _salons[idx] = withPartner;
    } else {
      _salons.add(withPartner);
    }
    _salon = _salons.first;

    // Dynamically update services to include new salon's services
    final allServices = <SalonServiceModel>[];
    for (final s in _salons) {
      allServices.addAll(s.services);
    }
    if (allServices.isNotEmpty) {
      _services = allServices;
    }

    if (withPartner.photos.isNotEmpty) {
      BranchManagerState.instance.updateAssignedBranch(
        salonName: withPartner.name,
        branchName: withPartner.name,
        address: '${withPartner.address}, ${withPartner.city}',
        image: withPartner.photos.first,
      );
    } else {
      BranchManagerState.instance.updateAssignedBranch(
        salonName: withPartner.name,
        branchName: withPartner.name,
        address: '${withPartner.address}, ${withPartner.city}',
      );
    }

    PartnerFirestoreService.instance.saveSalonLocation(withPartner);
    notifyListeners();
  }

  void updateSalon(SalonModel updated) {
    final idx = _salons.indexWhere((s) => s.salonId == updated.salonId);
    if (idx != -1) {
      _salons[idx] = updated;
    } else {
      _salons.add(updated);
    }
    if (_salon.salonId == updated.salonId || _salons.length == 1) {
      _salon = updated;
    }

    PartnerFirestoreService.instance.saveSalonLocation(updated);
    notifyListeners();
  }

  void toggleSalonStatus(String salonId) {
    final idx = _salons.indexWhere((s) => s.salonId == salonId);
    if (idx != -1) {
      final current = _salons[idx];
      final newStatus = !current.salonStatus;
      final updated = current.copyWith(salonStatus: newStatus);
      _salons[idx] = updated;
      if (_salon.salonId == salonId) {
        _salon = updated;
      }
      PartnerFirestoreService.instance.toggleSalonLocationStatus(salonId, newStatus);
      notifyListeners();
    }
  }

  void assignManagerToSalon({
    required String salonId,
    required String managerId,
    required String managerName,
  }) {
    int idx = _salons.indexWhere((s) => s.salonId == salonId);
    if (idx == -1 && _salons.isNotEmpty) {
      idx = 0;
    }
    if (idx != -1) {
      final current = _salons[idx];
      final updated = current.copyWith(
        assignedManagerUid: managerId,
        managerName: managerName,
      );
      _salons[idx] = updated;
      _salon = updated;
      try {
        PartnerFirestoreService.instance.saveSalonLocation(updated);
      } catch (_) {}
      notifyListeners();
    } else {
      _salon = _salon.copyWith(
        assignedManagerUid: managerId,
        managerName: managerName,
      );
      try {
        PartnerFirestoreService.instance.saveSalonLocation(_salon);
      } catch (_) {}
      notifyListeners();
    }
  }

  void selectBranch(String branchId) {
    if (branchId == 'all') {
      _selectedBranchId = 'all';
      notifyListeners();
      return;
    }
    // Harmonize: map to canonical salonId if branch belongs to a salon
    for (final s in _salons) {
      if (s.salonId == branchId || s.branches.any((b) => b.branchId == branchId)) {
        _selectedBranchId = s.salonId;
        notifyListeners();
        return;
      }
    }
    _selectedBranchId = branchId;
    notifyListeners();
  }

  void addBranch(BranchModel branch) {
    addSalon(branch.toSalonModel());
  }

  void updateBranch(BranchModel updated) {
    updateSalon(updated.toSalonModel());
  }

  void toggleBranchStatus(String branchId) {
    toggleSalonStatus(branchId);
  }

  void addManager(BranchManagerModel manager) {
    final withPartner = manager.copyWith(
      assignedPartnerId: _partner.id.isNotEmpty ? _partner.id : (FirebaseAuth.instance.currentUser?.uid ?? 'partner_demo'),
      assignedSalonId: _salon.salonId.isNotEmpty ? _salon.salonId : 'salon_demo',
    );
    _managers.add(withPartner);

    // Link manager to branch
    final updatedBranches = _salon.branches.map((b) {
      if (b.branchId == withPartner.assignedBranchId) {
        final updatedB = b.copyWith(
          managerId: withPartner.managerId,
          managerName: withPartner.fullName,
        );
        return updatedB;
      }
      return b;
    }).toList();
    _salon = _salon.copyWith(branches: updatedBranches);

    // Persist manager to Firestore
    PartnerFirestoreService.instance.saveBranchManager(withPartner);

    _notifications.insert(
      0,
      PartnerNotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Branch Manager Added',
        description:
            '${withPartner.fullName} assigned to ${withPartner.assignedBranchName}.',
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
      final updated = current.copyWith(isActive: !current.isActive);
      _managers[index] = updated;
      PartnerFirestoreService.instance.saveBranchManager(updated);
      notifyListeners();
    }
  }

  void addService(SalonServiceModel service) {
    final targetSalonId = selectedServiceSalonId;
    if (targetSalonId.isNotEmpty) {
      addServiceToSalon(targetSalonId, service);
    } else {
      _services.insert(0, service);
      if (_salons.isNotEmpty) {
        final s = _salons.first;
        final updatedServices = List<SalonServiceModel>.from(s.services)..insert(0, service);
        updateSalon(s.copyWith(services: updatedServices));
      }
      notifyListeners();
    }
  }

  /// Add a service specifically to a salon location
  Future<void> addServiceToSalon(String salonId, SalonServiceModel service) async {
    final idx = _salons.indexWhere((s) => s.salonId == salonId);
    if (idx != -1) {
      final s = _salons[idx];
      final updatedList = List<SalonServiceModel>.from(s.services)..insert(0, service);
      final updatedSalon = s.copyWith(services: updatedList);
      _salons[idx] = updatedSalon;
      if (_salon.salonId == salonId) _salon = updatedSalon;
    }

    _services.removeWhere((srv) => srv.id == service.id);
    _services.insert(0, service);
    notifyListeners();

    try {
      await PartnerFirestoreService.instance.saveSalonService(
        salonId: salonId,
        service: service,
        partnerId: _partner.id.isNotEmpty ? _partner.id : (FirebaseAuth.instance.currentUser?.uid ?? ''),
      );
    } catch (_) {}
  }

  /// Update a service specifically in a salon location
  Future<void> updateServiceInSalon(String salonId, SalonServiceModel service) async {
    final idx = _salons.indexWhere((s) => s.salonId == salonId);
    if (idx != -1) {
      final s = _salons[idx];
      final updatedList = s.services.map((srv) => srv.id == service.id ? service : srv).toList();
      final updatedSalon = s.copyWith(services: updatedList);
      _salons[idx] = updatedSalon;
      if (_salon.salonId == salonId) _salon = updatedSalon;
    }

    final globalIdx = _services.indexWhere((srv) => srv.id == service.id);
    if (globalIdx != -1) {
      _services[globalIdx] = service;
    }
    notifyListeners();

    try {
      await PartnerFirestoreService.instance.saveSalonService(
        salonId: salonId,
        service: service,
        partnerId: _partner.id.isNotEmpty ? _partner.id : (FirebaseAuth.instance.currentUser?.uid ?? ''),
      );
    } catch (_) {}
  }

  /// Delete a service specifically from a salon location
  Future<void> deleteServiceFromSalon(String salonId, String serviceId) async {
    final idx = _salons.indexWhere((s) => s.salonId == salonId);
    if (idx != -1) {
      final s = _salons[idx];
      final updatedList = s.services.where((srv) => srv.id != serviceId).toList();
      final updatedSalon = s.copyWith(services: updatedList);
      _salons[idx] = updatedSalon;
      if (_salon.salonId == salonId) _salon = updatedSalon;
    }

    _services.removeWhere((srv) => srv.id == serviceId);
    notifyListeners();

    try {
      await PartnerFirestoreService.instance.deleteSalonService(
        salonId: salonId,
        serviceId: serviceId,
      );
    } catch (_) {}
  }

  /// Toggle service active status for a specific salon location
  Future<void> toggleServiceStatusInSalon(String salonId, String serviceId) async {
    final idx = _salons.indexWhere((s) => s.salonId == salonId);
    if (idx != -1) {
      final s = _salons[idx];
      SalonServiceModel? targetService;
      final updatedList = s.services.map((srv) {
        if (srv.id == serviceId) {
          final updated = srv.copyWith(isActive: !srv.isActive);
          targetService = updated;
          return updated;
        }
        return srv;
      }).toList();

      final updatedSalon = s.copyWith(services: updatedList);
      _salons[idx] = updatedSalon;
      if (_salon.salonId == salonId) _salon = updatedSalon;

      final gIdx = _services.indexWhere((srv) => srv.id == serviceId);
      if (gIdx != -1 && targetService != null) {
        _services[gIdx] = targetService!;
      }
      notifyListeners();

      if (targetService != null) {
        try {
          await PartnerFirestoreService.instance.saveSalonService(
            salonId: salonId,
            service: targetService!,
            partnerId: _partner.id.isNotEmpty ? _partner.id : (FirebaseAuth.instance.currentUser?.uid ?? ''),
          );
        } catch (_) {}
      }
    }
  }

  void updateService(SalonServiceModel service) {
    final targetSalonId = selectedServiceSalonId;
    if (targetSalonId.isNotEmpty) {
      updateServiceInSalon(targetSalonId, service);
    } else {
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = service;
        if (_salons.isNotEmpty) {
          final s = _salons.first;
          final updatedServices = s.services.map((srv) => srv.id == service.id ? service : srv).toList();
          updateSalon(s.copyWith(services: updatedServices));
        }
        notifyListeners();
      }
    }
  }

  void toggleServiceStatus(String serviceId) {
    final targetSalonId = selectedServiceSalonId;
    if (targetSalonId.isNotEmpty) {
      toggleServiceStatusInSalon(targetSalonId, serviceId);
    } else {
      final index = _services.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final current = _services[index];
        final updated = current.copyWith(isActive: !current.isActive);
        _services[index] = updated;
        if (_salons.isNotEmpty) {
          final s = _salons.first;
          final updatedServices = s.services.map((srv) => srv.id == serviceId ? updated : srv).toList();
          updateSalon(s.copyWith(services: updatedServices));
        }
        notifyListeners();
      }
    }
  }

  // Home Service Profile & Settings
  void updateHomeServiceProfile(HomeServiceProfileModel profile) {
    _homeProfile = profile;
    _homeService = _homeService.copyWith(
      isEnabled: profile.isAvailable,
      serviceRadiusKm: profile.serviceRadiusKm,
    );
    _salon = _salon.copyWith(isHomeServiceEnabled: profile.isAvailable);

    PartnerFirestoreService.instance.saveHomeServiceProfile(profile);
    notifyListeners();
  }

  void toggleHomeServiceAvailability(bool isAvailable) {
    _homeProfile = _homeProfile.copyWith(isAvailable: isAvailable);
    _homeService = _homeService.copyWith(isEnabled: isAvailable);
    _salon = _salon.copyWith(isHomeServiceEnabled: isAvailable);

    PartnerFirestoreService.instance.toggleHomeServiceAvailability(_partner.id, isAvailable);
    notifyListeners();
  }

  void updateHomeServiceSettings(HomeServiceSettingsModel settings) {
    _homeService = settings;
    _homeProfile = _homeProfile.copyWith(
      isAvailable: settings.isEnabled,
      serviceRadiusKm: settings.serviceRadiusKm,
    );
    _salon = _salon.copyWith(isHomeServiceEnabled: settings.isEnabled);
    notifyListeners();
  }

  void updateBookingStatus(
    String bookingId,
    PartnerBookingStatus newStatus, {
    DateTime? rescheduledDateTime,
    String? rescheduledNote,
    String? cancellationReason,
  }) {
    final statusName = newStatus == PartnerBookingStatus.cancelled ? 'cancelled' : newStatus.name;
    CustomerBookingStorage.instance.updateBookingStatus(
      bookingId,
      statusName,
      rescheduledDateTime: rescheduledDateTime,
      rescheduledNote: rescheduledNote,
    );

    final index = _bookings.indexWhere((b) => b.id == bookingId || b.bookingRef == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      _bookings[index] = booking.copyWith(
        status: newStatus,
        appointmentDateTime: rescheduledDateTime ?? booking.appointmentDateTime,
        rescheduledNote: rescheduledNote ?? booking.rescheduledNote,
        cancellationReason: cancellationReason ?? booking.cancellationReason,
      );

      if (newStatus == PartnerBookingStatus.completed) {
        final tx = EarningsTransactionModel(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          bookingRef: booking.bookingRef,
          serviceName: booking.serviceName,
          amount: booking.price,
          date: DateTime.now(),
          customerName: booking.customerName,
          paymentType: booking.bookingType == PartnerBookingType.homeService
              ? 'Online (Advance)'
              : 'Counter (UPI)',
          partnerId: _partner.id,
          salonId: booking.salonId,
        );
        _transactions.insert(0, tx);
        PartnerFirestoreService.instance.saveTransaction(tx);
      }
    } else {
      final raw = CustomerBookingStorage.instance.currentBookings.firstWhere(
        (b) => (b['id'] ?? b['bookingRef']) == bookingId,
        orElse: () => {'id': bookingId, 'bookingRef': bookingId, 'status': statusName},
      );
      final newModel = PartnerBookingModel.fromMap(raw, bookingId).copyWith(
        status: newStatus,
        appointmentDateTime: rescheduledDateTime,
        rescheduledNote: rescheduledNote,
        cancellationReason: cancellationReason,
      );
      _bookings.insert(0, newModel);
    }

    PartnerFirestoreService.instance.updateBookingStatus(
      bookingId,
      newStatus,
      rescheduledDateTime: rescheduledDateTime,
      rescheduledNote: rescheduledNote,
      cancellationReason: cancellationReason,
    );

    notifyListeners();
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
