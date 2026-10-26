import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/services/customer_profile_service.dart';

typedef VerificationFailedCallback = void Function(String errorMessage);
typedef CodeSentCallback = void Function(String verificationId, int? resendToken);
typedef VerificationCompletedCallback = void Function(PhoneAuthCredential credential);
typedef AutoRetrievalTimeoutCallback = void Function(String verificationId);

class CustomerAuthService {
  CustomerAuthService._();
  static final CustomerAuthService instance = CustomerAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Starts Firebase Phone Number verification
  Future<void> sendOtp({
    required String fullPhoneNumber,
    required VerificationFailedCallback onVerificationFailed,
    required CodeSentCallback onCodeSent,
    VerificationCompletedCallback? onVerificationCompleted,
    AutoRetrievalTimeoutCallback? onAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    try {
      developer.log('Initiating Firebase Phone Auth for: $fullPhoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          developer.log('Instant verification completed.');
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          developer.log('Verification failed: ${e.code} - ${e.message}', error: e);
          final readableMessage = _mapAuthException(e);
          onVerificationFailed(readableMessage);
        },
        codeSent: (String verificationId, int? newResendToken) {
          developer.log('OTP codeSent successfully. VerificationId: $verificationId');
          onCodeSent(verificationId, newResendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          developer.log('Auto-retrieval timed out for: $verificationId');
          if (onAutoRetrievalTimeout != null) {
            onAutoRetrievalTimeout(verificationId);
          }
        },
      );
    } catch (e, stack) {
      developer.log('Unexpected verifyPhoneNumber error: $e', error: e, stackTrace: stack);
      onVerificationFailed('Failed to send verification code. Please check your network and try again.');
    }
  }

  /// Sign in with SMS code and verificationId
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final userCredential = await _auth.signInWithCredential(credential);
      developer.log('Firebase user successfully signed in: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('SignIn error: ${e.code} - ${e.message}', error: e);
      throw _mapAuthException(e);
    } catch (e) {
      developer.log('SignIn unexpected error: $e', error: e);
      throw 'Authentication failed. Please verify the code and try again.';
    }
  }

  /// Sign in with instant credential (auto-retrieval)
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Sign out the current customer
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      CustomerProfileService.instance.clearLocalProfile();
      developer.log('Customer signed out from Firebase Auth.');
    } catch (e) {
      developer.log('Error during sign out: $e', error: e);
      rethrow;
    }
  }

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number entered is invalid. Please check the 10-digit number.';
      case 'invalid-verification-code':
        return 'The verification code entered is incorrect. Please re-enter the code.';
      case 'session-expired':
        return 'The verification code has expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded for today. Please try again later or contact support.';
      case 'too-many-requests':
        return 'Too many attempts made from this device. Please wait a few minutes before trying again.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'app-not-authorized':
        return 'App verification failed. Please verify that SHA-1/SHA-256 fingerprint is added in Firebase Console.';
      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }
}
