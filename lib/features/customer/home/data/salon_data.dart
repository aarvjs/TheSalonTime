import '../models/salon_model.dart';

/// Deprecated: All salon data is now loaded dynamically from Firebase Firestore.
class SalonData {
  SalonData._();

  static const List<SalonModel> maleSalons = [];
  static const List<SalonModel> femaleSalons = [];
}
