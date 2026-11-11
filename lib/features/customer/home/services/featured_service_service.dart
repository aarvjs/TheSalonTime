import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/featured_service_model.dart';
import '../models/salon_model.dart';

class FeaturedServiceService {
  FeaturedServiceService._();
  static final FeaturedServiceService instance = FeaturedServiceService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _featuredCol =>
      _firestore.collection('featuredServices');

  /// Fallback curated initial featured services with high-resolution imagery
  static const List<FeaturedServiceModel> defaultFeaturedServices = [
    FeaturedServiceModel(
      id: 'fs_haircut',
      name: 'Haircut',
      category: 'Haircut',
      description: 'Precision haircut, fade styling, head wash, and professional blowdry finish.',
      imageUrl:
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&w=800&q=80',
      displayOrder: 0,
      isActive: true,
    ),
    FeaturedServiceModel(
      id: 'fs_hair_styling',
      name: 'Hair Styling',
      category: 'Hair Styling',
      description: 'Trend-setting salon blowdry, curls, volume setting, and party-ready hair design.',
      imageUrl:
          'https://images.unsplash.com/photo-1562322140-8baeececf3df?auto=format&fit=crop&w=800&q=80',
      displayOrder: 1,
      isActive: true,
    ),
    FeaturedServiceModel(
      id: 'fs_hair_colour',
      name: 'Hair Colour',
      category: 'Hair Colour',
      description: 'Ammonia-free organic shades, highlights, balayage, and root touchup blending.',
      imageUrl:
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?auto=format&fit=crop&w=800&q=80',
      displayOrder: 2,
      isActive: true,
    ),
    FeaturedServiceModel(
      id: 'fs_beard_grooming',
      name: 'Beard Grooming',
      category: 'Beard Grooming',
      description: 'Razor sharp lining, beard trimming, conditioning oils, and soothing hot towel wrap.',
      imageUrl:
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&w=800&q=80',
      displayOrder: 3,
      isActive: true,
    ),
    FeaturedServiceModel(
      id: 'fs_facial',
      name: 'Facial',
      category: 'Facial',
      description: 'Hydra glow therapy, deep pore cleanse, blackhead extraction, and relaxing facial spa.',
      imageUrl:
          'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=800&q=80',
      displayOrder: 4,
      isActive: true,
    ),
  ];

  /// Real-time stream of all active featured services from Cloud Firestore
  /// Listens to both `featuredServices` collection AND `salons/featured_services_data` (dual-sync)
  /// so services added by Super Admin appear instantly even if rules are pending.
  Stream<List<FeaturedServiceModel>> streamActiveFeaturedServices() {
    late StreamController<List<FeaturedServiceModel>> controller;
    StreamSubscription? subCol;
    StreamSubscription? subDoc;

    List<FeaturedServiceModel> lastFeaturedColItems = [];
    List<FeaturedServiceModel> lastFallbackDocItems = [];

    void emitBest() {
      if (controller.isClosed) return;
      if (lastFeaturedColItems.isNotEmpty) {
        controller.add(List.unmodifiable(lastFeaturedColItems));
      } else if (lastFallbackDocItems.isNotEmpty) {
        controller.add(List.unmodifiable(lastFallbackDocItems));
      } else {
        controller.add(defaultFeaturedServices);
      }
    }

    controller = StreamController<List<FeaturedServiceModel>>(
      onListen: () {
        // Emit initial defaults or cached immediately upon subscribe
        emitBest();

        // 1. Primary Source: Cloud Firestore `featuredServices` collection
        subCol = _featuredCol.snapshots().listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final items = <FeaturedServiceModel>[];
            for (final doc in snapshot.docs) {
              try {
                final model = FeaturedServiceModel.fromMap(doc.data(), doc.id);
                if (model.isActive) items.add(model);
              } catch (_) {}
            }
            if (items.isNotEmpty) {
              items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
              lastFeaturedColItems = items;
              emitBest();
            }
          }
        }, onError: (e) {
          developer.log('Notice streaming featuredServices collection: $e');
          emitBest();
        });

        // 2. Open-Access Fallback Source: `salons/featured_services_data` doc (100% open permissions)
        subDoc = _firestore
            .collection('salons')
            .doc('featured_services_data')
            .snapshots()
            .listen((docSnap) {
          if (docSnap.exists && docSnap.data() != null) {
            final data = docSnap.data()!;
            final rawList = data['services'];
            if (rawList is List && rawList.isNotEmpty) {
              final items = <FeaturedServiceModel>[];
              for (int i = 0; i < rawList.length; i++) {
                final item = rawList[i];
                if (item is Map) {
                  try {
                    final map = Map<String, dynamic>.from(item);
                    final id = map['id']?.toString() ?? 'fs_$i';
                    final model = FeaturedServiceModel.fromMap(map, id);
                    if (model.isActive) items.add(model);
                  } catch (_) {}
                }
              }
              if (items.isNotEmpty) {
                items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
                lastFallbackDocItems = items;
                emitBest();
              }
            }
          }
        }, onError: (e) {
          developer.log('Notice streaming salons/featured_services_data doc: $e');
          emitBest();
        });
      },
      onCancel: () {
        subCol?.cancel();
        subDoc?.cancel();
      },
    );

    return controller.stream;
  }

  /// Check whether a salon offers this featured service
  /// (compares against salon services array, salon category, and subcollection)
  Future<bool> doesSalonOfferService({
    required SalonModel salon,
    required FeaturedServiceModel featuredService,
  }) async {
    final searchTerms = [
      featuredService.name.toLowerCase(),
      featuredService.category.toLowerCase(),
    ];

    // 1. Check salon category
    for (final term in searchTerms) {
      if (salon.category.toLowerCase().contains(term)) return true;
    }

    // 2. Check salon document `services` field in Firestore
    try {
      final docSnap = await _firestore.collection('salons').doc(salon.id).get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final rawServices = data['services'];
        if (rawServices is List) {
          for (final s in rawServices) {
            if (s is Map) {
              final sName = (s['name'] as String? ?? '').toLowerCase();
              final sCat = (s['category'] as String? ?? '').toLowerCase();
              for (final term in searchTerms) {
                if (sName.contains(term) || sCat.contains(term)) {
                  return true;
                }
              }
            }
          }
        }
      }

      // 3. Check salon `services` subcollection
      final subSnap = await _firestore
          .collection('salons')
          .doc(salon.id)
          .collection('services')
          .where('isActive', isEqualTo: true)
          .limit(25)
          .get();

      for (final sDoc in subSnap.docs) {
        final sData = sDoc.data();
        final sName = (sData['name'] as String? ?? sData['serviceName'] as String? ?? '').toLowerCase();
        final sCat = (sData['category'] as String? ?? '').toLowerCase();
        for (final term in searchTerms) {
          if (sName.contains(term) || sCat.contains(term)) {
            return true;
          }
        }
      }
    } catch (e) {
      developer.log('Notice checking salon service offer: $e');
    }

    // Fallback heuristic: general unisex / salon locations support standard haircut/styling
    if (featuredService.category.toLowerCase().contains('hair') ||
        featuredService.name.toLowerCase().contains('hair')) {
      return true;
    }

    return false;
  }
}

