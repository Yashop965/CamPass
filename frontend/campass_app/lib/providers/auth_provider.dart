import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../utils/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final ApiClient _apiClient = ApiClient();

  String? _userId;
  String? _role;
  bool _isLoggedIn = false;

  String? get userId => _userId;
  String? get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  /// Login user and handle FCM setup
  Future<bool> login(String userId, String password) async {
    try {
      // Simulate login - replace with actual API call
      final response = await _apiClient.post('/api/auth/login', {
        'userId': userId,
        'password': password,
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _userId = jsonData['user']['id'].toString();
        _role = jsonData['user']['role'];
        _isLoggedIn = true;

        // Handle FCM after login
        await _handleFCMSetup();

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// Handle FCM token update and topic subscription
  Future<void> _handleFCMSetup() async {
    try {
      // Get FCM token
      String? fcmToken = await _firebaseService.getFCMToken();

      if (fcmToken != null) {
        // Send to backend
        await _updateUserFCMToken(fcmToken);

        // Subscribe to topics based on role
        await _subscribeToTopics();
      }
    } catch (e) {
      print('FCM setup error: $e');
    }
  }

  /// Update FCM token in backend
  Future<void> _updateUserFCMToken(String fcmToken) async {
    try {
      await _apiClient.post('/api/auth/update-fcm-token', {
        'fcmToken': fcmToken,
      });
    } catch (e) {
      print('Update FCM token error: $e');
    }
  }

  /// Subscribe to appropriate topics based on role
  Future<void> _subscribeToTopics() async {
    if (_role == 'student') {
      _firebaseService.subscribeToStudentAlerts(_userId!);
    } else if (_role == 'parent') {
      _firebaseService.subscribeToParentAlerts(_userId!);
    } else if (_role == 'admin' || _role == 'warden') {
      _firebaseService.subscribeToAdminAlerts();
    }
  }

  /// Logout and unsubscribe from topics
  Future<void> logout() async {
    try {
      // Unsubscribe from topics
      if (_role == 'student') {
        _firebaseService.unsubscribeFromStudentAlerts(_userId!);
      } else if (_role == 'parent') {
        _firebaseService.unsubscribeFromParentAlerts(_userId!);
      }

      _userId = null;
      _role = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
