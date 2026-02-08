import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/api_client.dart';

class AdminProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // State variables
  List<dynamic> _allUsers = [];
  List<dynamic> _systemLogs = [];
  List<dynamic> _allSOSAlerts = [];
  List<dynamic> _geofenceViolations = [];
  Map<String, dynamic> _systemStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<dynamic> get allUsers => _allUsers;
  List<dynamic> get systemLogs => _systemLogs;
  List<dynamic> get allSOSAlerts => _allSOSAlerts;
  List<dynamic> get geofenceViolations => _geofenceViolations;
  Map<String, dynamic> get systemStats => _systemStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all users
  Future<void> loadAllUsers(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/users');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _allUsers = List.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          _allUsers = List.from(jsonData['data'] ?? []);
        }
      } else {
        _errorMessage = 'Failed to load users';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new user
  Future<bool> createUser(Map<String, dynamic> userData, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.post('/api/auth/register', userData);

      if (response.statusCode == 201) {
        // Reload users list
        await loadAllUsers(token);
        return true;
      } else {
        _errorMessage = 'Failed to create user';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error creating user: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.delete('/api/users/$userId');

      if (response.statusCode == 200) {
        _allUsers.removeWhere((u) => u['id'] == userId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete user';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error deleting user: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load system logs
  Future<void> loadSystemLogs(String token) async {
    try {
      // This would need a backend endpoint to be created
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Placeholder - logs would come from backend
      _systemLogs = [
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'event': 'User login',
          'userId': 'user123',
          'status': 'success'
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'event': 'SOS alert triggered',
          'userId': 'user456',
          'status': 'resolved'
        },
      ];

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error loading system logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all SOS alerts (admin view)
  Future<void> loadAllSOSAlerts(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/sos/active');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _allSOSAlerts = List.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          _allSOSAlerts = List.from(jsonData['data'] ?? []);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading SOS alerts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load geofence violations
  Future<void> loadGeofenceViolations(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/location/violations');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _geofenceViolations = List.from(jsonData);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading geofence violations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate system statistics
  void calculateStats() {
    _systemStats = {
      'totalUsers': _allUsers.length,
      'students': _allUsers.where((u) => u['role'] == 'student').length,
      'parents': _allUsers.where((u) => u['role'] == 'parent').length,
      'staff': _allUsers.where((u) => u['role'] == 'warden' || u['role'] == 'guard').length,
      'activeSOSAlerts': _allSOSAlerts.length,
      'geofenceViolations': _geofenceViolations.length,
      'totalEvents': _systemLogs.length,
    };
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
