import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pass_model.dart';
import '../utils/api_client.dart';

class WardenProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // State variables
  // State variables
  List<PassModel> _pendingApprovals = [];
  List<PassModel> _passHistory = [];
  List<dynamic> _allSOSAlerts = [];
  List<dynamic> _geofenceViolations = [];
  List<dynamic> _lateEntryAlerts = [];
  List<dynamic> _allStudentLocations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PassModel> get pendingApprovals => _pendingApprovals;
  List<PassModel> get passHistory => _passHistory;
  List<dynamic> get allSOSAlerts => _allSOSAlerts;
  List<dynamic> get geofenceViolations => _geofenceViolations;
  List<dynamic> get lateEntryAlerts => _lateEntryAlerts;
  List<dynamic> get allStudentLocations => _allStudentLocations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load pending warden approvals
  Future<void> loadPendingApprovals(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/passes/pending/warden');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _pendingApprovals =
              jsonData.map((p) => PassModel.fromJson(Map<String, dynamic>.from(p))).toList();
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          _pendingApprovals = (jsonData['data'] as List)
              .map((p) => PassModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }
      } else {
        _errorMessage = 'Failed to load pending approvals';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error loading pending approvals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load pass history for warden
  Future<void> loadHistory(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/passes/history/warden');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _passHistory =
              jsonData.map((p) => PassModel.fromJson(Map<String, dynamic>.from(p))).toList();
        } else if (jsonData is Map && jsonData.containsKey('data')) {
           _passHistory = (jsonData['data'] as List)
              .map((p) => PassModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }
      } else {
        _errorMessage = 'Failed to load history';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a pass as warden
  Future<bool> approvePass(String passId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.patch(
        '/api/passes/$passId/approve-warden',
        {'approvedAt': DateTime.now().toIso8601String()},
      );

      if (response.statusCode == 200) {
        _pendingApprovals.removeWhere((p) => p.id == passId);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to approve pass';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error approving pass: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all SOS alerts for monitoring
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
      } else {
        _errorMessage = 'Failed to load SOS alerts';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
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
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          _geofenceViolations = List.from(jsonData['data'] ?? []);
        }
      } else {
        _errorMessage = 'Failed to load geofence violations';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error loading geofence violations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolve an SOS alert
  Future<bool> resolveSOSAlert(String sosId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.patch(
        '/api/sos/$sosId/resolve',
        {'resolvedAt': DateTime.now().toIso8601String()},
      );

      if (response.statusCode == 200) {
        _allSOSAlerts.removeWhere((s) => s['id'] == sosId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to resolve SOS alert';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error resolving SOS alert: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolve ALL active SOS alerts
  Future<void> resolveAllSOS(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create a copy to iterate
      final alertsToResolve = List.from(_allSOSAlerts);
      
      // Process in parallel or sequence. Parallel is faster.
      await Future.wait(alertsToResolve.map((alert) async {
         final id = alert['id'];
         if (id != null) {
            await resolveSOSAlert(id, token);
         }
      }));
      
      // Refresh list to be sure
      _allSOSAlerts.clear();
      notifyListeners();
      
    } catch (e) {
      _errorMessage = "Failed to resolve all alerts: $e";
      print("Error resolving all: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get all student locations for monitoring
  Future<void> loadAllStudentLocations(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // This endpoint would need to be created on backend to get all students
      // For now, using violations which shows students outside geofence
      final response = await _apiClient.get('/api/location/violations');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _allStudentLocations = List.from(jsonData);
        }
      }
    } catch (e) {
      print('Error loading student locations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get statistics for dashboard
  Map<String, int> getDashboardStats() {
    return {
      'pendingApprovals': _pendingApprovals.length,
      'activeSOSAlerts': _allSOSAlerts.length,
      'geofenceViolations': _geofenceViolations.length,
      'lateEntries': _lateEntryAlerts.length,
      'outOfBoundsStudents': _geofenceViolations.length,
    };
  }

  void addLateEntryAlert(Map<String, dynamic> data) {
    _lateEntryAlerts.insert(0, data);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
