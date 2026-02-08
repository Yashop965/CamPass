import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Initialize Firebase Cloud Messaging
  Future<void> initializeFirebase() async {
    try {
      // Request user permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User denied notification permission');
      }

      // Get FCM token for this device
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked from background/terminated state');
        _handleBackgroundMessage(message);
      });

      // Handle terminated app state
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from terminated state via notification');
        _handleBackgroundMessage(initialMessage);
      }

      // Optional: Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        print('FCM token refreshed: $token');
        // Update backend with new token if needed
        _updateFCMTokenOnBackend(token);
      });
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Handle messages in foreground - show dialog since FCM doesn't auto-show in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message data: ${message.data}');

    if (message.notification != null) {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';
      final messageType = message.data['type'] ?? 'general';

      // Show dialog for foreground messages
      _showForegroundNotificationDialog(title, body, messageType, message.data);
    }
  }

  /// Show dialog for foreground FCM messages
  void _showForegroundNotificationDialog(String title, String body, String messageType, Map<String, dynamic> data) {
    // Get the current context - this assumes we have a navigator key or similar
    // For now, we'll just print and rely on backend FCM for actual notifications
    print('Showing foreground dialog: $title - $body (type: $messageType)');

    // Since we can't easily get context here without global key, we'll use NotificationService for now
    NotificationService().showNotification(title: title, body: body, payload: messageType);
  }

  /// Handle messages from background/terminated state
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Background message data: ${message.data}');
    // Additional logic for handling background messages
    // e.g., navigate to specific screen, update UI, etc.
  }

  /// Update backend with FCM token
  Future<void> _updateFCMTokenOnBackend(String token) async {
    try {
      // This would typically be called after user login
      // Update backend with new token for push notification routing
      print('FCM token update: $token');
    } catch (e) {
      print('Error updating FCM token on backend: $e');
    }
  }

  /// Subscribe to topic for group notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe to student-specific notifications
  void subscribeToStudentAlerts(String studentId) {
    subscribeToTopic('student_${studentId}_alerts');
    subscribeToTopic('student_${studentId}_tracking');
  }

  /// Unsubscribe from student notifications
  void unsubscribeFromStudentAlerts(String studentId) {
    unsubscribeFromTopic('student_${studentId}_alerts');
    unsubscribeFromTopic('student_${studentId}_tracking');
  }

  /// Subscribe to parent notifications
  void subscribeToParentAlerts(String parentId) {
    subscribeToTopic('parent_${parentId}_alerts');
    subscribeToTopic('parent_${parentId}_tracking');
  }

  /// Unsubscribe from parent notifications
  void unsubscribeFromParentAlerts(String parentId) {
    unsubscribeFromTopic('parent_${parentId}_alerts');
    unsubscribeFromTopic('parent_${parentId}_tracking');
  }

  /// Subscribe to admin/warden notifications
  void subscribeToAdminAlerts() {
    subscribeToTopic('admin_sos_alerts');
    subscribeToTopic('admin_geofence_violations');
  }

  /// Unsubscribe from admin notifications
  void unsubscribeFromAdminAlerts() {
    unsubscribeFromTopic('admin_sos_alerts');
    unsubscribeFromTopic('admin_geofence_violations');
  }
}
