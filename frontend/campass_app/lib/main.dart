// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/audio_asset_manager.dart';
import 'services/session_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'core/config/app_config.dart';
import 'core/constants/map_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");

  if (message.data['type'] == 'location_request') {
    try {
       print("Received location request in background");
       final token = await SessionManager.getToken();
       if (token == null) {
          print("No token found in background handler");
          return;
       }

       final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       
       double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          MapConstants.campusLatitude,
          MapConstants.campusLongitude,
       );
       
       bool isGeofenceViolation = distanceInMeters > MapConstants.geofenceRadiusMeters;
       
       final url = Uri.parse('${AppConfig.baseUrl}/api/location/update');
       
       final user = await SessionManager.getUser();
       if (user == null) return;

       final response = await http.post(
          url,
          headers: {
             'Content-Type': 'application/json',
             'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
             'studentId': user.id, 
             'latitude': position.latitude,
             'longitude': position.longitude,
             'accuracy': position.accuracy,
             'isGeofenceViolation': isGeofenceViolation
          })
       );
       
       print("Background location update response: ${response.statusCode}");

    } catch (e) {
       print("Error in background location handler: $e");
    }
  }
}

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
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
