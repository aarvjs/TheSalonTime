import 'package:cloud_firestore/cloud_firestore.dart';

class FeaturedServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FeaturedServiceModel({
    required this.id,
    required this.name,
    this.category = 'Haircut',
    this.description = '',
    required this.imageUrl,
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory FeaturedServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    int parseDisplayOrder(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    bool parseIsActive(dynamic val) {
      if (val == null) return true;
      if (val is bool) return val;
      if (val is String) {
        final lower = val.toLowerCase().trim();
        return lower == 'true' || lower == '1' || lower == 'active';
      }
      if (val is num) return val != 0;
      return true;
    }

    final rawName = map['name'] ?? map['serviceName'] ?? map['title'];
    final rawCategory = map['category'] ?? map['categoryId'];
    final rawDescription = map['description'] ?? '';
    final rawImageUrl = map['imageUrl'] ?? map['image'] ?? map['photo'] ?? map['thumbnail'];

    return FeaturedServiceModel(
      id: docId,
      name: rawName != null && rawName.toString().trim().isNotEmpty
          ? rawName.toString().trim()
          : 'Featured Service',
      category: rawCategory != null && rawCategory.toString().trim().isNotEmpty
          ? rawCategory.toString().trim()
          : 'Haircut',
      description: rawDescription.toString().trim(),
      imageUrl: rawImageUrl != null ? rawImageUrl.toString().trim() : '',
      isActive: parseIsActive(map['isActive'] ?? map['status']),
      displayOrder: parseDisplayOrder(map['displayOrder'] ?? map['order']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'serviceName': name,
      'category': category,
      'categoryId': category.toLowerCase().replaceAll(' ', '_'),
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'displayOrder': displayOrder,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  FeaturedServiceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeaturedServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

