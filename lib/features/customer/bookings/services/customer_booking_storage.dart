import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

class CustomerBookingStorage {
  CustomerBookingStorage._();
  static final CustomerBookingStorage instance = CustomerBookingStorage._();

  List<Map<String, dynamic>> _inMemoryBookings = [];
  bool _isLoaded = false;

  File get _file => File('${Directory.systemTemp.path}/salon_customer_local_bookings.json');

  /// Load cached bookings from persistent disk file
  Future<List<Map<String, dynamic>>> loadBookings() async {
    try {
      if (await _file.exists()) {
        final content = await _file.readAsString();
        if (content.isNotEmpty) {
          final list = jsonDecode(content);
          if (list is List) {
            _inMemoryBookings = list
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            _isLoaded = true;
            return List.unmodifiable(_inMemoryBookings);
          }
        }
      }
    } catch (e) {
      developer.log('Error reading local bookings file: $e');
    }
    _isLoaded = true;
    return List.unmodifiable(_inMemoryBookings);
  }

  /// Get current in-memory bookings, auto-loading if needed
  List<Map<String, dynamic>> get currentBookings {
    if (!_isLoaded) {
      loadBookings();
    }
    return List.unmodifiable(_inMemoryBookings);
  }

  /// Save booking locally so it is never lost even if Firestore network or rules fail
  Future<void> saveBookingLocally(Map<String, dynamic> booking) async {
    try {
      if (!_isLoaded) await loadBookings();

      // Convert any non-serializable fields (like Timestamps) to String
      final cleanBooking = Map<String, dynamic>.from(booking);
      cleanBooking['savedLocallyAt'] = DateTime.now().toIso8601String();

      // Check if already exists, else insert at beginning
      final id = cleanBooking['id'];
      final idx = _inMemoryBookings.indexWhere((b) => b['id'] == id);
      if (idx >= 0) {
        _inMemoryBookings[idx] = cleanBooking;
      } else {
        _inMemoryBookings.insert(0, cleanBooking);
      }

      await _file.writeAsString(jsonEncode(_inMemoryBookings));
      developer.log('Saved booking ${cleanBooking['bookingRef']} to local device cache (${_inMemoryBookings.length} total)');
    } catch (e) {
      developer.log('Error saving booking locally: $e');
    }
  }

  /// Update booking status locally (e.g. if confirmed, cancelled, or rescheduled)
  Future<void> updateBookingStatus(
    String bookingId,
    String newStatus, {
    DateTime? rescheduledDateTime,
    String? rescheduledNote,
  }) async {
    try {
      final idx = _inMemoryBookings.indexWhere(
        (b) => b['id'] == bookingId || b['bookingRef'] == bookingId,
      );
      if (idx >= 0) {
        _inMemoryBookings[idx]['status'] = newStatus;
        if (rescheduledDateTime != null) {
          _inMemoryBookings[idx]['appointmentDateTime'] = rescheduledDateTime.toIso8601String();
          _inMemoryBookings[idx]['date'] = rescheduledDateTime.toIso8601String();
        }
        if (rescheduledNote != null) {
          _inMemoryBookings[idx]['rescheduledNote'] = rescheduledNote;
        }
        await _file.writeAsString(jsonEncode(_inMemoryBookings));
        developer.log('Updated local booking $bookingId status to $newStatus');
      }
    } catch (e) {
      developer.log('Error updating local booking status: $e');
    }
  }
}

