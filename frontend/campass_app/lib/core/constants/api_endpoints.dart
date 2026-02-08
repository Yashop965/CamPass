import '../config/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.baseUrl;

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String register = '/api/auth/register';
  static const String updateFcmToken = '/api/auth/update-fcm-token';

  // Pass endpoints
  static const String generatePass = '/api/passes/generate';
  static const String scanPass = '/api/passes/scan';
  static const String getUserPasses = '/api/passes/user';
  static const String getPassById = '/api/passes';
  static const String getPendingParentApprovals = '/api/passes/pending/parent';
  static const String getPendingWardenApprovals = '/api/passes/pending/warden';
  static const String approvePass = '/api/passes/approve';
  static const String rejectPass = '/api/passes/reject';

  // User endpoints
  static const String getUser = '/api/users';
  static const String updateUser = '/api/users';

  // SOS endpoints
  static const String sendSos = '/api/sos/alert';
  static const String getSOSHistory = '/api/sos/history';

  // Location endpoints
  static const String updateLocation = '/api/location/update';
  static const String getStudentLocation = '/api/location/student';
  static const String getLocationHistory = '/api/location/history'; // Added this
}
