import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

class PartnerAuthService {
  PartnerAuthService._();
  static final PartnerAuthService instance = PartnerAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// Helper to convert a 10-digit mobile number into an internal Firebase email credential
  static String formatAuthEmail(String rawPhone) {
    final clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    final tenDigits = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
    return 'partner_$tenDigits@salontimes.internal';
  }

  /// Clean 10-digit formatted phone string
  static String formatPhoneNumber(String rawPhone) {
    final clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    final tenDigits = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
    return '+91 $tenDigits';
  }

  /// Extract 10-digit raw string
  static String extract10Digits(String rawPhone) {
    final clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    return clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
  }

  /// Register new partner account using phone number mapping & password
  Future<UserCredential> registerPartner({
    required String phone,
    required String password,
  }) async {
    final tenDigits = extract10Digits(phone);
    if (tenDigits.length < 10) {
      throw 'Please enter a valid 10-digit mobile number.';
    }

    final authEmail = formatAuthEmail(tenDigits);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
      developer.log('Partner Firebase Auth created: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e, stack) {
      developer.log('Partner registration failed: ${e.code}', error: e, stackTrace: stack);
      switch (e.code) {
        case 'email-already-in-use':
          throw 'An account with this mobile number already exists. Please log in.';
        case 'weak-password':
          throw 'Password is too weak. Please use at least 6 characters.';
        case 'invalid-email':
          throw 'Invalid mobile number format.';
        case 'network-request-failed':
          throw 'Network error. Please check your internet connection.';
        default:
          throw e.message ?? 'Registration failed. Please try again.';
      }
    } catch (e) {
      developer.log('Partner registration unexpected error: $e');
      rethrow;
    }
  }

  /// Sign in partner using mobile number & password
  Future<UserCredential> loginPartner({
    required String phone,
    required String password,
  }) async {
    final tenDigits = extract10Digits(phone);
    if (tenDigits.length < 10) {
      throw 'Please enter a valid 10-digit mobile number.';
    }

    final authEmail = formatAuthEmail(tenDigits);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
      developer.log('Partner logged in successfully: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e, stack) {
      developer.log('Partner login failed: ${e.code}', error: e, stackTrace: stack);
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw 'Invalid mobile number or password. Please verify and retry.';
        case 'user-disabled':
          throw 'This partner account has been disabled. Please contact support.';
        case 'too-many-requests':
          throw 'Too many unsuccessful attempts. Please wait a few moments and retry.';
        case 'network-request-failed':
          throw 'Network error. Please check your internet connection.';
        default:
          throw e.message ?? 'Login failed. Please check credentials.';
      }
    } catch (e) {
      developer.log('Partner login unexpected error: $e');
      rethrow;
    }
  }

  /// Sign out partner session
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      developer.log('Partner signed out successfully');
    } catch (e) {
      developer.log('Error during partner sign out: $e');
      rethrow;
    }
  }
}
