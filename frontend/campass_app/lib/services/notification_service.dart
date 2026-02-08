import '../utils/api_client.dart';
import '../core/constants/api_endpoints.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  NotificationService();

  /// Show SOS alert notification (now handled by FCM)
  Future<void> showSOSAlertNotification({
    required String studentName,
    required String message,
    required double latitude,
    required double longitude,
  }) async {
    // Since using FCM, the notification is sent from backend
    // For foreground, the app will receive it via FirebaseMessaging.onMessage
    print('SOS Alert: $studentName - $message at $latitude, $longitude');
  }

  /// Send SOS via backend API
  Future<bool> sendSos(
    String userId,
    double lat,
    double lng,
    String token,
  ) async {
    try {
      final res = await _api.post(ApiEndpoints.sendSos, {
        'studentId': userId,
        'latitude': lat,
        'longitude': lng,
        'alertType': 'manual',
      });
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print('Error sending SOS: $e');
      return false;
    }
  }

  /// Show geofence violation notification (now handled by FCM)
  Future<void> showGeofenceViolationNotification({
    required String studentName,
    required String message,
  }) async {
    // Since using FCM, the notification is sent from backend
    print('Geofence Violation: $studentName - $message');
  }

  /// Show general notification (now handled by FCM)
  Future<void> showNotification({
    required String title,
    required String body,
    required String? payload,
  }) async {
    // Since using FCM, the notification is sent from backend
    print('Notification: $title - $body');
  }
}
