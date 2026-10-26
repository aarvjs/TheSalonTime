import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  bool firebaseInitialized = false;
  String? firebaseInitError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    developer.log('Firebase initialized successfully for The Salon Times.');
  } catch (e, stack) {
    firebaseInitError = e.toString();
    developer.log('Firebase initialization failed: $e', error: e, stackTrace: stack);
  }

  runApp(SalonTimesApp(
    firebaseInitialized: firebaseInitialized,
    firebaseInitError: firebaseInitError,
  ));
}
