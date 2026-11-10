import 'package:cloud_firestore/cloud_firestore.dart';

enum PartnerVerificationStatus {
  notSubmitted,
  submitted,
  underReview,
  approved,
  rejected,
  needsInfo,
}

enum PartnerBusinessModel {
  salon,        // Physical Salon Business only
  homeService,  // Home Service Professional only
  both,         // Both Salon & Home Service
}

enum PartnerBookingType {
  salonVisit,
  homeService,
}

enum PartnerBookingStatus {
  newBooking,
  confirmed,
  rescheduled,
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
  final PartnerBusinessModel businessModel;
  final PartnerBusinessModel activeBusinessModel;
  final String? profilePhoto;
  final String? legalName;
  final String? businessType;
  final String? regNumber;
  final String? businessAddress;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final List<PartnerDocumentModel> documents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartnerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.businessName,
    this.verificationStatus = PartnerVerificationStatus.notSubmitted,
    this.businessModel = PartnerBusinessModel.both,
    this.activeBusinessModel = PartnerBusinessModel.both,
    this.profilePhoto,
    this.legalName,
    this.businessType,
    this.regNumber,
    this.businessAddress,
    this.rejectionReason,
    this.submittedAt,
    this.documents = const [],
    this.createdAt,
    this.updatedAt,
  });

  PartnerModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
    PartnerVerificationStatus? verificationStatus,
    PartnerBusinessModel? businessModel,
    PartnerBusinessModel? activeBusinessModel,
    String? profilePhoto,
    String? legalName,
    String? businessType,
    String? regNumber,
    String? businessAddress,
    String? rejectionReason,
    DateTime? submittedAt,
    List<PartnerDocumentModel>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      businessModel: businessModel ?? this.businessModel,
      activeBusinessModel: activeBusinessModel ?? this.activeBusinessModel,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      legalName: legalName ?? this.legalName,
      businessType: businessType ?? this.businessType,
      regNumber: regNumber ?? this.regNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap({bool isNew = false}) {
    final map = <String, dynamic>{
      'uid': id,
      'fullName': fullName.trim(),
      'phoneNumber': phone.trim(),
      'email': email.trim(),
      'businessName': businessName.trim(),
      'role': 'partner',
      'verificationStatus': verificationStatus == PartnerVerificationStatus.notSubmitted
          ? 'not_submitted'
          : verificationStatus.name,
      'businessModel': businessModel.name,
      'activeBusinessModel': activeBusinessModel.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (profilePhoto != null && profilePhoto!.trim().isNotEmpty) {
      map['profilePhoto'] = profilePhoto!.trim();
    }
    if (legalName != null && legalName!.trim().isNotEmpty) {
      map['legalName'] = legalName!.trim();
    }
    if (businessType != null && businessType!.trim().isNotEmpty) {
      map['businessType'] = businessType!.trim();
    }
    if (regNumber != null && regNumber!.trim().isNotEmpty) {
      map['regNumber'] = regNumber!.trim();
    }
    if (businessAddress != null && businessAddress!.trim().isNotEmpty) {
      map['businessAddress'] = businessAddress!.trim();
    }
    if (rejectionReason != null && rejectionReason!.trim().isNotEmpty) {
      map['rejectionReason'] = rejectionReason!.trim();
    }
    if (submittedAt != null) {
      map['submittedAt'] = Timestamp.fromDate(submittedAt!);
    }
    if (documents.isNotEmpty) {
      map['documents'] = documents.map((d) => d.toMap()).toList();
    }
    if (isNew) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }
    return map;
  }

  factory PartnerModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    List<PartnerDocumentModel> parseDocs(dynamic val) {
      if (val is List) {
        final list = <PartnerDocumentModel>[];
        for (final item in val) {
          if (item is Map<String, dynamic>) {
            list.add(PartnerDocumentModel.fromMap(item));
          } else if (item is Map) {
            list.add(PartnerDocumentModel.fromMap(Map<String, dynamic>.from(item)));
          }
        }
        return list;
      }
      return const [];
    }

    final docs = parseDocs(map['documents']);

    PartnerVerificationStatus parseStatus(dynamic val) {
      if (val == null) return PartnerVerificationStatus.notSubmitted;
      final str = val.toString().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
      if (str == 'approved' || str == 'verified') return PartnerVerificationStatus.approved;
      if (str == 'underreview' || str == 'under_review') return PartnerVerificationStatus.underReview;
      if (str == 'rejected') return PartnerVerificationStatus.rejected;
      if (str == 'needsinfo' || str == 'needs_info') return PartnerVerificationStatus.needsInfo;
      if (str == 'submitted' || str == 'pending') {
        return docs.isNotEmpty ? PartnerVerificationStatus.submitted : PartnerVerificationStatus.notSubmitted;
      }
      if (str == 'notsubmitted' || str == 'not_submitted') return PartnerVerificationStatus.notSubmitted;
      return PartnerVerificationStatus.notSubmitted;
    }

    PartnerBusinessModel parseModel(dynamic val) {
      if (val == null) return PartnerBusinessModel.both;
      final str = val.toString().toLowerCase();
      if (str == 'salon') return PartnerBusinessModel.salon;
      if (str == 'homeservice' || str == 'home_service') return PartnerBusinessModel.homeService;
      return PartnerBusinessModel.both;
    }

    return PartnerModel(
      id: docId.isNotEmpty ? docId : (map['uid'] as String? ?? ''),
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phoneNumber'] as String? ?? (map['phone'] as String? ?? ''),
      businessName: map['businessName'] as String? ?? '',
      verificationStatus: parseStatus(map['verificationStatus']),
      businessModel: parseModel(map['businessModel']),
      activeBusinessModel: parseModel(map['activeBusinessModel']),
      profilePhoto: map['profilePhoto'] as String?,
      legalName: map['legalName'] as String?,
      businessType: map['businessType'] as String?,
      regNumber: map['regNumber'] as String?,
      businessAddress: map['businessAddress'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      submittedAt: parseDate(map['submittedAt']),
      documents: docs,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

class PartnerDocumentModel {
  final String id;
  final String documentType;
  final String fileName;
  final String? documentNumber;
  final String? fileUrl;
  final String? localPath;
  final int? fileSize;
  final DateTime uploadDate;
  final PartnerVerificationStatus status;

  const PartnerDocumentModel({
    required this.id,
    required this.documentType,
    required this.fileName,
    this.documentNumber,
    this.fileUrl,
    this.localPath,
    this.fileSize,
    required this.uploadDate,
    this.status = PartnerVerificationStatus.submitted,
  });

  PartnerDocumentModel copyWith({
    String? id,
    String? documentType,
    String? fileName,
    String? documentNumber,
    String? fileUrl,
    String? localPath,
    int? fileSize,
    DateTime? uploadDate,
    PartnerVerificationStatus? status,
  }) {
    return PartnerDocumentModel(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      documentNumber: documentNumber ?? this.documentNumber,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentType': documentType,
      'fileName': fileName,
      'documentNumber': documentNumber,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'status': status.name,
    };
  }

  factory PartnerDocumentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    PartnerVerificationStatus parseStatus(dynamic val) {
      if (val == null) return PartnerVerificationStatus.submitted;
      final str = val.toString().toLowerCase();
      if (str == 'approved' || str == 'verified') return PartnerVerificationStatus.approved;
      if (str == 'underreview' || str == 'under_review') return PartnerVerificationStatus.underReview;
      if (str == 'rejected') return PartnerVerificationStatus.rejected;
      if (str == 'needsinfo' || str == 'needs_info') return PartnerVerificationStatus.needsInfo;
      return PartnerVerificationStatus.submitted;
    }

    return PartnerDocumentModel(
      id: map['id'] as String? ?? 'doc_${DateTime.now().millisecondsSinceEpoch}',
      documentType: map['documentType'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      documentNumber: map['documentNumber'] as String?,
      fileUrl: map['fileUrl'] as String?,
      localPath: map['localPath'] as String?,
      fileSize: map['fileSize'] as int?,
      uploadDate: parseDate(map['uploadDate']),
      status: parseStatus(map['status']),
    );
  }
}

class BranchModel {
  final String branchId;
  final String partnerId;
  final String salonId;
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
  final double serviceRadiusKm;
  final List<SalonServiceModel> services;

  String get areaOrCity => city.isNotEmpty ? city : address;

  const BranchModel({
    required this.branchId,
    this.partnerId = '',
    this.salonId = '',
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
    this.serviceRadiusKm = 10.0,
    this.services = const [],
  });

  BranchModel copyWith({
    String? branchId,
    String? partnerId,
    String? salonId,
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
    double? serviceRadiusKm,
    List<SalonServiceModel>? services,
  }) {
    return BranchModel(
      branchId: branchId ?? this.branchId,
      partnerId: partnerId ?? this.partnerId,
      salonId: salonId ?? this.salonId,
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
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      services: services ?? this.services,
    );
  }

  Map<String, dynamic> toMap({bool isNestedInArray = false}) {
    return {
      'branchId': branchId,
      'partnerId': partnerId,
      'salonId': salonId.isNotEmpty ? salonId : branchId,
      'branchName': branchName,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'phone': phone,
      'email': email,
      'managerId': managerId,
      'managerName': managerName,
      'latitude': latitude,
      'longitude': longitude,
      'openingHours': openingHours,
      'closingHours': closingHours,
      'operatingDays': operatingDays,
      'isHomeServiceEnabled': isHomeServiceEnabled,
      'isActive': isActive,
      'serviceRadiusKm': serviceRadiusKm,
      'services': services.map((s) => s.toMap()).toList(),
      if (!isNestedInArray) 'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory BranchModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final srvList = <SalonServiceModel>[];
    if (map['services'] is List) {
      for (final s in map['services'] as List) {
        if (s is Map<String, dynamic>) {
          srvList.add(SalonServiceModel.fromMap(s));
        } else if (s is Map) {
          srvList.add(SalonServiceModel.fromMap(Map<String, dynamic>.from(s)));
        }
      }
    }

    final daysList = <String>[];
    final rawDays = map['operatingDays'] ?? map['workingDays'];
    if (rawDays is List) {
      for (final d in rawDays) {
        daysList.add(d.toString());
      }
    }

    return BranchModel(
      branchId: docId ?? (map['branchId'] as String? ?? map['salonId'] as String? ?? 'branch_${DateTime.now().millisecondsSinceEpoch}'),
      partnerId: map['partnerId'] as String? ?? '',
      salonId: map['salonId'] as String? ?? map['branchId'] as String? ?? '',
      branchName: map['branchName'] as String? ?? map['name'] as String? ?? map['salonName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      phone: map['phone'] as String? ?? (map['contactNumber'] as String? ?? ''),
      email: map['email'] as String? ?? '',
      managerId: map['managerId'] as String? ?? map['assignedManagerUid'] as String?,
      managerName: map['managerName'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 26.4719,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 80.3524,
      openingHours: map['openingHours'] as String? ?? '09:00 AM',
      closingHours: map['closingHours'] as String? ?? '08:00 PM',
      operatingDays: daysList.isNotEmpty ? daysList : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      isHomeServiceEnabled: map['isHomeServiceEnabled'] as bool? ?? (map['homeServiceEnabled'] as bool? ?? true),
      isActive: map['isActive'] as bool? ?? (map['salonStatus'] as bool? ?? true),
      serviceRadiusKm: (map['serviceRadiusKm'] as num?)?.toDouble() ?? 10.0,
      services: srvList,
    );
  }

  factory BranchModel.fromSalon(SalonModel s) {
    return BranchModel(
      branchId: s.salonId,
      partnerId: s.partnerId,
      salonId: s.salonId,
      branchName: s.name,
      address: s.address,
      city: s.city,
      state: s.state,
      postalCode: s.postalCode,
      phone: s.phone,
      email: s.email,
      managerId: s.assignedManagerUid,
      managerName: s.managerName,
      latitude: s.latitude,
      longitude: s.longitude,
      openingHours: s.openingHours,
      closingHours: s.closingHours,
      operatingDays: s.operatingDays,
      isHomeServiceEnabled: s.isHomeServiceEnabled,
      isActive: s.isActive,
      serviceRadiusKm: s.serviceRadiusKm,
      services: s.services,
    );
  }

  SalonModel toSalonModel() {
    return SalonModel(
      salonId: branchId,
      partnerId: partnerId,
      name: branchName,
      description: 'Salon Location - $branchName',
      category: 'Unisex Salon',
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
      openingHours: openingHours,
      closingHours: closingHours,
      operatingDays: operatingDays,
      serviceRadiusKm: serviceRadiusKm,
      isHomeServiceEnabled: isHomeServiceEnabled,
      salonStatus: isActive,
      assignedManagerUid: managerId,
      managerName: managerName,
      services: services,
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
  final String placeId;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String openingHours;
  final String closingHours;
  final List<String> operatingDays;
  final List<String> photos;
  final List<String> facilities;
  final double serviceRadiusKm;
  final PartnerVerificationStatus verificationStatus;
  final bool salonStatus;
  final bool isHomeServiceEnabled;
  final String? assignedManagerUid;
  final String? managerName;
  final List<SalonServiceModel> services;
  final List<BranchModel> _rawBranches;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Backward compatibility aliases
  String get salonName => name;
  String? get managerId => assignedManagerUid;
  bool get isActive => salonStatus;
  bool get homeServiceEnabled => isHomeServiceEnabled;
  String get areaOrCity => city.isNotEmpty ? city : address;

  /// Returns branches list. If none are stored separately, creates a virtual branch representation.
  List<BranchModel> get branches {
    if (_rawBranches.isNotEmpty) return _rawBranches;
    return [
      BranchModel(
        branchId: salonId,
        partnerId: partnerId,
        salonId: salonId,
        branchName: name,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        phone: phone,
        email: email,
        managerId: assignedManagerUid,
        managerName: managerName,
        latitude: latitude,
        longitude: longitude,
        openingHours: openingHours,
        closingHours: closingHours,
        operatingDays: operatingDays,
        isHomeServiceEnabled: isHomeServiceEnabled,
        isActive: salonStatus,
        serviceRadiusKm: serviceRadiusKm,
        services: services,
      ),
    ];
  }

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
    this.placeId = '',
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.openingHours,
    required this.closingHours,
    required this.operatingDays,
    this.photos = const [],
    this.facilities = const ['Air Conditioned', 'Free Wi-Fi', 'Complimentary Beverages', 'Valet Parking'],
    this.serviceRadiusKm = 10.0,
    this.verificationStatus = PartnerVerificationStatus.approved,
    this.salonStatus = true,
    this.isHomeServiceEnabled = true,
    this.assignedManagerUid,
    this.managerName,
    this.services = const [],
    List<BranchModel> branches = const [],
    this.createdAt,
    this.updatedAt,
  }) : _rawBranches = branches;

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
    String? placeId,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? openingHours,
    String? closingHours,
    List<String>? operatingDays,
    List<String>? photos,
    List<String>? facilities,
    double? serviceRadiusKm,
    PartnerVerificationStatus? verificationStatus,
    bool? salonStatus,
    bool? isHomeServiceEnabled,
    String? assignedManagerUid,
    String? managerName,
    List<SalonServiceModel>? services,
    List<BranchModel>? branches,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      operatingDays: operatingDays ?? this.operatingDays,
      photos: photos ?? this.photos,
      facilities: facilities ?? this.facilities,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      salonStatus: salonStatus ?? this.salonStatus,
      isHomeServiceEnabled: isHomeServiceEnabled ?? this.isHomeServiceEnabled,
      assignedManagerUid: assignedManagerUid ?? this.assignedManagerUid,
      managerName: managerName ?? this.managerName,
      services: services ?? this.services,
      branches: branches ?? _rawBranches,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'partnerId': partnerId,
      'name': name,
      'salonName': name,
      'description': description,
      'category': category,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'placeId': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'contactNumber': phone,
      'email': email,
      'openingHours': openingHours,
      'closingHours': closingHours,
      'operatingDays': operatingDays,
      'workingDays': operatingDays,
      'photos': photos,
      'logoUrl': photos.isNotEmpty ? photos.first : null,
      'facilities': facilities,
      'serviceRadiusKm': serviceRadiusKm,
      'verificationStatus': verificationStatus.name,
      'salonStatus': salonStatus,
      'isActive': salonStatus,
      'isHomeServiceEnabled': isHomeServiceEnabled,
      'homeServiceEnabled': isHomeServiceEnabled,
      'assignedManagerUid': assignedManagerUid,
      'managerId': assignedManagerUid,
      'managerName': managerName,
      'services': services.map((s) => s.toMap()).toList(),
      'branches': branches.map((b) => b.toMap(isNestedInArray: true)).toList(),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory SalonModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    final branchList = <BranchModel>[];
    if (map['branches'] is List) {
      for (final b in map['branches'] as List) {
        if (b is Map<String, dynamic>) {
          branchList.add(BranchModel.fromMap(b));
        } else if (b is Map) {
          branchList.add(BranchModel.fromMap(Map<String, dynamic>.from(b)));
        }
      }
    }

    final srvList = <SalonServiceModel>[];
    if (map['services'] is List) {
      for (final s in map['services'] as List) {
        if (s is Map<String, dynamic>) {
          srvList.add(SalonServiceModel.fromMap(s));
        } else if (s is Map) {
          srvList.add(SalonServiceModel.fromMap(Map<String, dynamic>.from(s)));
        }
      }
    }

    final daysList = <String>[];
    final rawDays = map['operatingDays'] ?? map['workingDays'];
    if (rawDays is List) {
      for (final d in rawDays) {
        daysList.add(d.toString());
      }
    }

    PartnerVerificationStatus parseStatus(dynamic val) {
      if (val == null) return PartnerVerificationStatus.approved;
      final str = val.toString().toLowerCase();
      if (str == 'approved' || str == 'verified') return PartnerVerificationStatus.approved;
      if (str == 'underreview' || str == 'under_review') return PartnerVerificationStatus.underReview;
      if (str == 'rejected') return PartnerVerificationStatus.rejected;
      if (str == 'needsinfo' || str == 'needs_info') return PartnerVerificationStatus.needsInfo;
      if (str == 'submitted' || str == 'pending') return PartnerVerificationStatus.submitted;
      return PartnerVerificationStatus.approved;
    }

    final photosList = <String>[];
    if (map['photos'] is List) {
      for (final p in map['photos'] as List) {
        photosList.add(p.toString());
      }
    } else if (map['logoUrl'] is String && (map['logoUrl'] as String).isNotEmpty) {
      photosList.add(map['logoUrl'] as String);
    }

    return SalonModel(
      salonId: docId ?? (map['salonId'] as String? ?? 'salon_${DateTime.now().millisecondsSinceEpoch}'),
      partnerId: map['partnerId'] as String? ?? '',
      name: map['name'] as String? ?? map['salonName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Unisex Salon',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      placeId: map['placeId'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 26.4719,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 80.3524,
      phone: map['phone'] as String? ?? (map['contactNumber'] as String? ?? ''),
      email: map['email'] as String? ?? '',
      openingHours: map['openingHours'] as String? ?? '09:00 AM',
      closingHours: map['closingHours'] as String? ?? '08:00 PM',
      operatingDays: daysList.isNotEmpty ? daysList : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      photos: photosList,
      facilities: (map['facilities'] as List?)?.map((e) => e.toString()).toList() ??
          const ['Air Conditioned', 'Free Wi-Fi', 'Valet Parking'],
      serviceRadiusKm: (map['serviceRadiusKm'] as num?)?.toDouble() ?? 10.0,
      verificationStatus: parseStatus(map['verificationStatus']),
      salonStatus: map['isActive'] as bool? ?? (map['salonStatus'] as bool? ?? true),
      isHomeServiceEnabled: map['isHomeServiceEnabled'] as bool? ?? (map['homeServiceEnabled'] as bool? ?? true),
      assignedManagerUid: map['assignedManagerUid'] as String? ?? map['managerId'] as String?,
      managerName: map['managerName'] as String?,
      services: srvList,
      branches: branchList,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

class BranchManagerModel {
  final String managerId;
  final String fullName;
  final String phone;
  final String email;
  final String assignedPartnerId;
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
    this.assignedPartnerId = '',
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
    String? assignedPartnerId,
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
      assignedPartnerId: assignedPartnerId ?? this.assignedPartnerId,
      assignedSalonId: assignedSalonId ?? this.assignedSalonId,
      assignedSalonName: assignedSalonName ?? this.assignedSalonName,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
      assignedBranchName: assignedBranchName ?? this.assignedBranchName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'managerId': managerId,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'assignedPartnerId': assignedPartnerId,
      'assignedSalonId': assignedSalonId,
      'assignedSalonName': assignedSalonName,
      'assignedBranchId': assignedBranchId,
      'assignedBranchName': assignedBranchName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BranchManagerModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return BranchManagerModel(
      managerId: docId ?? (map['managerId'] as String? ?? 'mgr_${DateTime.now().millisecondsSinceEpoch}'),
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      assignedPartnerId: map['assignedPartnerId'] as String? ?? '',
      assignedSalonId: map['assignedSalonId'] as String? ?? '',
      assignedSalonName: map['assignedSalonName'] as String? ?? '',
      assignedBranchId: map['assignedBranchId'] as String? ?? '',
      assignedBranchName: map['assignedBranchName'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parseDate(map['createdAt']),
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'durationMinutes': durationMinutes,
      'price': price,
      'offerPrice': offerPrice,
      'imageUrl': imageUrl,
      'availableAtSalon': availableAtSalon,
      'availableAtHome': availableAtHome,
      'isActive': isActive,
    };
  }

  factory SalonServiceModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return SalonServiceModel(
      id: docId ?? (map['id'] as String? ?? 'srv_${DateTime.now().millisecondsSinceEpoch}'),
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      description: map['description'] as String? ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (map['offerPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String?,
      availableAtSalon: map['availableAtSalon'] as bool? ?? true,
      availableAtHome: map['availableAtHome'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

/// Standalone Professional Home Service Profile
class HomeServiceProfileModel {
  final String partnerId;
  final bool isAvailable;
  final String professionalName;
  final String phone;
  final String email;
  final String? profilePhoto;
  final String? bio;
  final List<String> skills;
  final int experienceYears;
  final double serviceRadiusKm;
  final String baseAddress;
  final String baseCity;
  final double latitude;
  final double longitude;
  final List<SalonServiceModel> services;
  final List<String> availableDays;
  final List<String> timeSlots;
  final DateTime? updatedAt;

  const HomeServiceProfileModel({
    required this.partnerId,
    this.isAvailable = true,
    required this.professionalName,
    required this.phone,
    required this.email,
    this.profilePhoto,
    this.bio,
    this.skills = const ['Haircut & Styling', 'Beard Grooming', 'Facial Care', 'Head Massage'],
    this.experienceYears = 5,
    this.serviceRadiusKm = 10.0,
    this.baseAddress = 'Civil Lines',
    this.baseCity = 'Kanpur',
    this.latitude = 26.4719,
    this.longitude = 80.3524,
    this.services = const [],
    this.availableDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.timeSlots = const ['09:00 AM - 12:00 PM', '12:00 PM - 03:00 PM', '03:00 PM - 06:00 PM', '06:00 PM - 08:30 PM'],
    this.updatedAt,
  });

  HomeServiceProfileModel copyWith({
    String? partnerId,
    bool? isAvailable,
    String? professionalName,
    String? phone,
    String? email,
    String? profilePhoto,
    String? bio,
    List<String>? skills,
    int? experienceYears,
    double? serviceRadiusKm,
    String? baseAddress,
    String? baseCity,
    double? latitude,
    double? longitude,
    List<SalonServiceModel>? services,
    List<String>? availableDays,
    List<String>? timeSlots,
    DateTime? updatedAt,
  }) {
    return HomeServiceProfileModel(
      partnerId: partnerId ?? this.partnerId,
      isAvailable: isAvailable ?? this.isAvailable,
      professionalName: professionalName ?? this.professionalName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      baseAddress: baseAddress ?? this.baseAddress,
      baseCity: baseCity ?? this.baseCity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      availableDays: availableDays ?? this.availableDays,
      timeSlots: timeSlots ?? this.timeSlots,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'isAvailable': isAvailable,
      'professionalName': professionalName,
      'phone': phone,
      'email': email,
      'profilePhoto': profilePhoto,
      'bio': bio,
      'skills': skills,
      'experienceYears': experienceYears,
      'serviceRadiusKm': serviceRadiusKm,
      'baseAddress': baseAddress,
      'baseCity': baseCity,
      'latitude': latitude,
      'longitude': longitude,
      'services': services.map((s) => s.toMap()).toList(),
      'availableDays': availableDays,
      'timeSlots': timeSlots,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory HomeServiceProfileModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final srvList = <SalonServiceModel>[];
    if (map['services'] is List) {
      for (final s in map['services'] as List) {
        if (s is Map<String, dynamic>) {
          srvList.add(SalonServiceModel.fromMap(s));
        } else if (s is Map) {
          srvList.add(SalonServiceModel.fromMap(Map<String, dynamic>.from(s)));
        }
      }
    }

    final skillList = <String>[];
    if (map['skills'] is List) {
      for (final sk in map['skills'] as List) {
        skillList.add(sk.toString());
      }
    }

    return HomeServiceProfileModel(
      partnerId: docId ?? (map['partnerId'] as String? ?? ''),
      isAvailable: map['isAvailable'] as bool? ?? true,
      professionalName: map['professionalName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profilePhoto: map['profilePhoto'] as String?,
      bio: map['bio'] as String?,
      skills: skillList.isNotEmpty ? skillList : const ['Haircut & Styling', 'Beard Grooming'],
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 5,
      serviceRadiusKm: (map['serviceRadiusKm'] as num?)?.toDouble() ?? 10.0,
      baseAddress: map['baseAddress'] as String? ?? 'Civil Lines',
      baseCity: map['baseCity'] as String? ?? 'Kanpur',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 26.4719,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 80.3524,
      services: srvList,
      availableDays: (map['availableDays'] as List?)?.map((e) => e.toString()).toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      timeSlots: (map['timeSlots'] as List?)?.map((e) => e.toString()).toList() ??
          const ['09:00 AM - 12:00 PM', '12:00 PM - 03:00 PM', '03:00 PM - 06:00 PM'],
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
  final String? salonId;
  final String? branchId;
  final String? partnerId;
  final String? notes;
  final String? rescheduledNote;
  final String? cancellationReason;

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
    this.salonId,
    this.branchId,
    this.partnerId,
    this.notes,
    this.rescheduledNote,
    this.cancellationReason,
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
    String? salonId,
    String? branchId,
    String? partnerId,
    String? notes,
    String? rescheduledNote,
    String? cancellationReason,
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
      salonId: salonId ?? this.salonId,
      branchId: branchId ?? this.branchId,
      partnerId: partnerId ?? this.partnerId,
      notes: notes ?? this.notes,
      rescheduledNote: rescheduledNote ?? this.rescheduledNote,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  factory PartnerBookingModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    PartnerBookingType parseType(dynamic val) {
      final s = val?.toString().toLowerCase() ?? '';
      if (s.contains('home')) return PartnerBookingType.homeService;
      return PartnerBookingType.salonVisit;
    }

    PartnerBookingStatus parseStatus(dynamic val) {
      final s = val?.toString().toLowerCase() ?? '';
      if (s == 'confirmed') return PartnerBookingStatus.confirmed;
      if (s == 'rescheduled') return PartnerBookingStatus.rescheduled;
      if (s == 'completed') return PartnerBookingStatus.completed;
      if (s == 'cancelled' || s == 'rejected') return PartnerBookingStatus.cancelled;
      return PartnerBookingStatus.newBooking;
    }

    return PartnerBookingModel(
      id: docId ?? (map['id'] as String? ?? 'book_${DateTime.now().millisecondsSinceEpoch}'),
      bookingRef: map['bookingRef'] as String? ?? '#BK-${DateTime.now().millisecondsSinceEpoch % 10000}',
      customerName: map['customerName'] as String? ?? 'Customer',
      customerPhone: map['customerPhone'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? 'Salon Service',
      serviceCategory: map['serviceCategory'] as String? ?? 'Hair & Styling',
      appointmentDateTime: parseDate(map['appointmentDateTime'] ?? map['date']),
      bookingType: parseType(map['bookingType'] ?? map['type']),
      customerAddress: map['customerAddress'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: parseStatus(map['status']),
      branchName: map['branchName'] as String? ?? map['salonName'] as String? ?? 'Main Branch',
      salonId: map['salonId'] as String?,
      branchId: map['branchId'] as String?,
      partnerId: map['partnerId'] as String?,
      notes: map['notes'] as String?,
      rescheduledNote: map['rescheduledNote'] as String?,
      cancellationReason: map['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingRef': bookingRef,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      'bookingType': bookingType.name,
      if (customerAddress != null) 'customerAddress': customerAddress,
      'price': price,
      'status': status.name,
      'branchName': branchName,
      if (salonId != null) 'salonId': salonId,
      if (branchId != null) 'branchId': branchId,
      if (partnerId != null) 'partnerId': partnerId,
      if (notes != null) 'notes': notes,
      if (rescheduledNote != null) 'rescheduledNote': rescheduledNote,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    };
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
  final String? partnerId;
  final String? salonId;

  const EarningsTransactionModel({
    required this.id,
    required this.bookingRef,
    required this.serviceName,
    required this.amount,
    required this.date,
    this.status = 'Completed',
    required this.customerName,
    this.paymentType = 'Online (UPI)',
    this.partnerId,
    this.salonId,
  });

  factory EarningsTransactionModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return EarningsTransactionModel(
      id: docId ?? (map['id'] as String? ?? 'tx_${DateTime.now().millisecondsSinceEpoch}'),
      bookingRef: map['bookingRef'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? 'Service',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(map['date'] ?? map['createdAt']),
      status: map['status'] as String? ?? 'Completed',
      customerName: map['customerName'] as String? ?? 'Customer',
      paymentType: map['paymentType'] as String? ?? 'Online (UPI)',
      partnerId: map['partnerId'] as String?,
      salonId: map['salonId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingRef': bookingRef,
      'serviceName': serviceName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status,
      'customerName': customerName,
      'paymentType': paymentType,
      if (partnerId != null) 'partnerId': partnerId,
      if (salonId != null) 'salonId': salonId,
    };
  }
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
