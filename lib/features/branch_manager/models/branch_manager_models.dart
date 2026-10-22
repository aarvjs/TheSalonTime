enum BranchBookingType {
  salonVisit,
  homeService,
}

enum BranchBookingStatus {
  newBooking,
  confirmed,
  completed,
  cancelled,
}

class ManagerSessionModel {
  final String managerId;
  final String managerName;
  final String assignedPartnerId;
  final String assignedPartnerName;
  final String assignedSalonId;
  final String assignedSalonName;
  final String assignedBranchId;
  final String assignedBranchName;
  final String assignedBranchAddress;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final String operatingStatus;
  final String openingHours;
  final String assignedBranchImage;

  const ManagerSessionModel({
    required this.managerId,
    required this.managerName,
    required this.assignedPartnerId,
    required this.assignedPartnerName,
    required this.assignedSalonId,
    required this.assignedSalonName,
    required this.assignedBranchId,
    required this.assignedBranchName,
    required this.assignedBranchAddress,
    required this.phone,
    required this.email,
    this.role = 'Branch Manager',
    this.isActive = true,
    this.operatingStatus = 'Open Today',
    this.openingHours = '09:00 AM - 08:30 PM',
    this.assignedBranchImage = 'assets/images/customer/male_banner_1.png',
  });

  ManagerSessionModel copyWith({
    String? managerId,
    String? managerName,
    String? assignedPartnerId,
    String? assignedPartnerName,
    String? assignedSalonId,
    String? assignedSalonName,
    String? assignedBranchId,
    String? assignedBranchName,
    String? assignedBranchAddress,
    String? phone,
    String? email,
    String? role,
    bool? isActive,
    String? operatingStatus,
    String? openingHours,
    String? assignedBranchImage,
  }) {
    return ManagerSessionModel(
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      assignedPartnerId: assignedPartnerId ?? this.assignedPartnerId,
      assignedPartnerName: assignedPartnerName ?? this.assignedPartnerName,
      assignedSalonId: assignedSalonId ?? this.assignedSalonId,
      assignedSalonName: assignedSalonName ?? this.assignedSalonName,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
      assignedBranchName: assignedBranchName ?? this.assignedBranchName,
      assignedBranchAddress: assignedBranchAddress ?? this.assignedBranchAddress,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      operatingStatus: operatingStatus ?? this.operatingStatus,
      openingHours: openingHours ?? this.openingHours,
      assignedBranchImage: assignedBranchImage ?? this.assignedBranchImage,
    );
  }
}

class BranchManagerBookingModel {
  final String id;
  final String bookingRef;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String category;
  final DateTime dateTime;
  final String timeSlot;
  final BranchBookingType bookingType;
  final BranchBookingStatus status;
  final double price;
  final String? homeAddress;
  final String? notes;
  final String assignedBranchId;
  final String stylistName;

  const BranchManagerBookingModel({
    required this.id,
    required this.bookingRef,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.category,
    required this.dateTime,
    required this.timeSlot,
    required this.bookingType,
    required this.status,
    required this.price,
    this.homeAddress,
    this.notes,
    required this.assignedBranchId,
    required this.stylistName,
  });

  BranchManagerBookingModel copyWith({
    String? id,
    String? bookingRef,
    String? customerName,
    String? customerPhone,
    String? serviceName,
    String? category,
    DateTime? dateTime,
    String? timeSlot,
    BranchBookingType? bookingType,
    BranchBookingStatus? status,
    double? price,
    String? homeAddress,
    String? notes,
    String? assignedBranchId,
    String? stylistName,
  }) {
    return BranchManagerBookingModel(
      id: id ?? this.id,
      bookingRef: bookingRef ?? this.bookingRef,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      timeSlot: timeSlot ?? this.timeSlot,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      price: price ?? this.price,
      homeAddress: homeAddress ?? this.homeAddress,
      notes: notes ?? this.notes,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
      stylistName: stylistName ?? this.stylistName,
    );
  }
}

class BranchManagerServiceModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int durationMinutes;
  final bool salonVisitAvailable;
  final bool homeServiceAvailable;
  final bool isActive;
  final String assignedBranchId;
  final String image;

  const BranchManagerServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.salonVisitAvailable,
    required this.homeServiceAvailable,
    this.isActive = true,
    required this.assignedBranchId,
    required this.image,
  });
}

class BranchManagerStaffModel {
  final String id;
  final String name;
  final String role;
  final int experienceYears;
  final double rating;
  final String assignedBranchId;
  final String availability;
  final String phone;
  final String image;

  const BranchManagerStaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.experienceYears,
    required this.rating,
    required this.assignedBranchId,
    required this.availability,
    required this.phone,
    required this.image,
  });
}

class BranchManagerNotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final String assignedBranchId;

  const BranchManagerNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    required this.assignedBranchId,
  });

  BranchManagerNotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? type,
    bool? isRead,
    String? assignedBranchId,
  }) {
    return BranchManagerNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
    );
  }
}

class BranchManagerActivityItem {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final String type;

  const BranchManagerActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
  });
}
