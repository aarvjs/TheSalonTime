enum PartnerVerificationStatus {
  submitted,
  underReview,
  approved,
  rejected,
  needsInfo,
}

enum PartnerBookingType {
  salonVisit,
  homeService,
}

enum PartnerBookingStatus {
  newBooking,
  confirmed,
  completed,
  cancelled,
}

class PartnerModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String businessName;
  final PartnerVerificationStatus verificationStatus;
  final String? profilePhoto;

  const PartnerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.businessName,
    this.verificationStatus = PartnerVerificationStatus.submitted,
    this.profilePhoto,
  });

  PartnerModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
    PartnerVerificationStatus? verificationStatus,
    String? profilePhoto,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

class PartnerDocumentModel {
  final String id;
  final String documentType;
  final String fileName;
  final String? documentNumber;
  final DateTime uploadDate;
  final PartnerVerificationStatus status;

  const PartnerDocumentModel({
    required this.id,
    required this.documentType,
    required this.fileName,
    this.documentNumber,
    required this.uploadDate,
    this.status = PartnerVerificationStatus.submitted,
  });

  PartnerDocumentModel copyWith({
    String? id,
    String? documentType,
    String? fileName,
    String? documentNumber,
    DateTime? uploadDate,
    PartnerVerificationStatus? status,
  }) {
    return PartnerDocumentModel(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      documentNumber: documentNumber ?? this.documentNumber,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
    );
  }
}

class BranchModel {
  final String branchId;
  final String branchName;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String phone;
  final String email;
  final String? managerId;
  final String? managerName;
  final double latitude;
  final double longitude;
  final String openingHours;
  final String closingHours;
  final List<String> operatingDays;
  final bool isHomeServiceEnabled;
  final bool isActive;

  const BranchModel({
    required this.branchId,
    required this.branchName,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.phone,
    required this.email,
    this.managerId,
    this.managerName,
    required this.latitude,
    required this.longitude,
    this.openingHours = '09:00 AM',
    this.closingHours = '08:00 PM',
    this.operatingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.isHomeServiceEnabled = true,
    this.isActive = true,
  });

  BranchModel copyWith({
    String? branchId,
    String? branchName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? phone,
    String? email,
    String? managerId,
    String? managerName,
    double? latitude,
    double? longitude,
    String? openingHours,
    String? closingHours,
    List<String>? operatingDays,
    bool? isHomeServiceEnabled,
    bool? isActive,
  }) {
    return BranchModel(
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      operatingDays: operatingDays ?? this.operatingDays,
      isHomeServiceEnabled: isHomeServiceEnabled ?? this.isHomeServiceEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
}

class SalonModel {
  final String salonId;
  final String partnerId;
  final String name;
  final String description;
  final String category;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String openingHours;
  final String closingHours;
  final List<String> operatingDays;
  final List<String> photos;
  final List<String> facilities;
  final PartnerVerificationStatus verificationStatus;
  final bool salonStatus;
  final bool isHomeServiceEnabled;
  final List<BranchModel> branches;

  const SalonModel({
    required this.salonId,
    required this.partnerId,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.openingHours,
    required this.closingHours,
    required this.operatingDays,
    this.photos = const [],
    this.facilities = const ['Air Conditioned', 'Free Wi-Fi', 'Complimentary Beverages', 'Valet Parking'],
    this.verificationStatus = PartnerVerificationStatus.approved,
    this.salonStatus = true,
    this.isHomeServiceEnabled = true,
    this.branches = const [],
  });

  SalonModel copyWith({
    String? salonId,
    String? partnerId,
    String? name,
    String? description,
    String? category,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? openingHours,
    String? closingHours,
    List<String>? operatingDays,
    List<String>? photos,
    List<String>? facilities,
    PartnerVerificationStatus? verificationStatus,
    bool? salonStatus,
    bool? isHomeServiceEnabled,
    List<BranchModel>? branches,
  }) {
    return SalonModel(
      salonId: salonId ?? this.salonId,
      partnerId: partnerId ?? this.partnerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      operatingDays: operatingDays ?? this.operatingDays,
      photos: photos ?? this.photos,
      facilities: facilities ?? this.facilities,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      salonStatus: salonStatus ?? this.salonStatus,
      isHomeServiceEnabled: isHomeServiceEnabled ?? this.isHomeServiceEnabled,
      branches: branches ?? this.branches,
    );
  }
}

class BranchManagerModel {
  final String managerId;
  final String fullName;
  final String phone;
  final String email;
  final String assignedSalonId;
  final String assignedSalonName;
  final String assignedBranchId;
  final String assignedBranchName;
  final bool isActive;
  final DateTime createdAt;

  const BranchManagerModel({
    required this.managerId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.assignedSalonId,
    required this.assignedSalonName,
    required this.assignedBranchId,
    required this.assignedBranchName,
    this.isActive = true,
    required this.createdAt,
  });

  BranchManagerModel copyWith({
    String? managerId,
    String? fullName,
    String? phone,
    String? email,
    String? assignedSalonId,
    String? assignedSalonName,
    String? assignedBranchId,
    String? assignedBranchName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BranchManagerModel(
      managerId: managerId ?? this.managerId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      assignedSalonId: assignedSalonId ?? this.assignedSalonId,
      assignedSalonName: assignedSalonName ?? this.assignedSalonName,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
      assignedBranchName: assignedBranchName ?? this.assignedBranchName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SalonServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final int durationMinutes;
  final double price;
  final double? offerPrice;
  final String? imageUrl;
  final bool availableAtSalon;
  final bool availableAtHome;
  final bool isActive;

  const SalonServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.price,
    this.offerPrice,
    this.imageUrl,
    this.availableAtSalon = true,
    this.availableAtHome = false,
    this.isActive = true,
  });

  SalonServiceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? durationMinutes,
    double? price,
    double? offerPrice,
    String? imageUrl,
    bool? availableAtSalon,
    bool? availableAtHome,
    bool? isActive,
  }) {
    return SalonServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      availableAtSalon: availableAtSalon ?? this.availableAtSalon,
      availableAtHome: availableAtHome ?? this.availableAtHome,
      isActive: isActive ?? this.isActive,
    );
  }
}

class HomeServiceSettingsModel {
  final bool isEnabled;
  final double serviceRadiusKm;
  final double homeServiceFee;
  final List<String> serviceableAreas;
  final List<String> availableDays;
  final List<String> timeSlots;
  final int minimumNoticeHours;

  const HomeServiceSettingsModel({
    this.isEnabled = true,
    this.serviceRadiusKm = 10.0,
    this.homeServiceFee = 149.0,
    this.serviceableAreas = const ['Civil Lines', 'Swaroop Nagar', 'Kakadeo', 'Tilak Nagar', 'Sharda Nagar'],
    this.availableDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.timeSlots = const ['09:00 AM - 12:00 PM', '12:00 PM - 03:00 PM', '03:00 PM - 06:00 PM', '06:00 PM - 08:30 PM'],
    this.minimumNoticeHours = 2,
  });

  HomeServiceSettingsModel copyWith({
    bool? isEnabled,
    double? serviceRadiusKm,
    double? homeServiceFee,
    List<String>? serviceableAreas,
    List<String>? availableDays,
    List<String>? timeSlots,
    int? minimumNoticeHours,
  }) {
    return HomeServiceSettingsModel(
      isEnabled: isEnabled ?? this.isEnabled,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      homeServiceFee: homeServiceFee ?? this.homeServiceFee,
      serviceableAreas: serviceableAreas ?? this.serviceableAreas,
      availableDays: availableDays ?? this.availableDays,
      timeSlots: timeSlots ?? this.timeSlots,
      minimumNoticeHours: minimumNoticeHours ?? this.minimumNoticeHours,
    );
  }
}

class PartnerBookingModel {
  final String id;
  final String bookingRef;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String serviceCategory;
  final DateTime appointmentDateTime;
  final PartnerBookingType bookingType;
  final String? customerAddress;
  final double price;
  final PartnerBookingStatus status;
  final String branchName;
  final String? notes;

  const PartnerBookingModel({
    required this.id,
    required this.bookingRef,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.serviceCategory,
    required this.appointmentDateTime,
    required this.bookingType,
    this.customerAddress,
    required this.price,
    this.status = PartnerBookingStatus.newBooking,
    required this.branchName,
    this.notes,
  });

  PartnerBookingModel copyWith({
    String? id,
    String? bookingRef,
    String? customerName,
    String? customerPhone,
    String? serviceName,
    String? serviceCategory,
    DateTime? appointmentDateTime,
    PartnerBookingType? bookingType,
    String? customerAddress,
    double? price,
    PartnerBookingStatus? status,
    String? branchName,
    String? notes,
  }) {
    return PartnerBookingModel(
      id: id ?? this.id,
      bookingRef: bookingRef ?? this.bookingRef,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      bookingType: bookingType ?? this.bookingType,
      customerAddress: customerAddress ?? this.customerAddress,
      price: price ?? this.price,
      status: status ?? this.status,
      branchName: branchName ?? this.branchName,
      notes: notes ?? this.notes,
    );
  }
}

class EarningsTransactionModel {
  final String id;
  final String bookingRef;
  final String serviceName;
  final double amount;
  final DateTime date;
  final String status;
  final String customerName;
  final String paymentType;

  const EarningsTransactionModel({
    required this.id,
    required this.bookingRef,
    required this.serviceName,
    required this.amount,
    required this.date,
    this.status = 'Completed',
    required this.customerName,
    this.paymentType = 'Online (UPI)',
  });
}

class PartnerNotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'booking', 'cancellation', 'verification', 'service', 'manager'
  final bool isRead;

  const PartnerNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  PartnerNotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? type,
    bool? isRead,
  }) {
    return PartnerNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
