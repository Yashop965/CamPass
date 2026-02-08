// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/audio_asset_manager.dart';
import 'services/session_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services before running the app
  try {
    // Initialize audio assets first
    await AudioAssetManager().initializeAudioAssets();
    print('Audio assets initialized successfully');

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('⚠️ Firebase initialization failed (Running in Mock/Demo Mode): $e');
      // Proceed without Firebase
    }

    // Check for existing session
    final isLoggedIn = await SessionManager.isLoggedIn();
    final isRoleSelected = await SessionManager.isRoleSelected();

    String initialRoute = '/';
    if (isLoggedIn && isRoleSelected) {
      final role = await SessionManager.getRole();
      if (role != null) {
        initialRoute = '/$role';
      }
    }

    // Now run the app
    runApp(CampassApp(initialRoute: initialRoute));
  } catch (e) {
    print('Error initializing app: $e');
    // Run app anyway with error handling
    runApp(const CampassApp());
  }
}
