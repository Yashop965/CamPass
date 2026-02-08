import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pass_model.dart';
// Removed unused service imports
import '../utils/api_client.dart';

class ParentProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // State variables
  List<PassModel> _pendingApprovals = [];
  List<PassModel> _childPasses = [];
  List<Map<String, dynamic>> _children = []; // Store linked children
  Map<String, dynamic> _childLocation = {};
  List<dynamic> _geofenceViolations = [];
  List<dynamic> _sosAlerts = [];
  bool _isLoading = false;
  bool _isTrackingChild = false;
  String? _errorMessage;

  // Getters
  List<PassModel> get pendingApprovals => _pendingApprovals;
  List<PassModel> get childPasses => _childPasses;
  List<Map<String, dynamic>> get children => _children;
  Map<String, dynamic> get childLocation => _childLocation;
  List<dynamic> get geofenceViolations => _geofenceViolations;
  List<dynamic> get sosAlerts => _sosAlerts;
  bool get isLoading => _isLoading;
  bool get isTrackingChild => _isTrackingChild;
  String? get errorMessage => _errorMessage;

  /// Load linked children
  Future<void> loadChildren(String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiClient.get('/api/auth/children');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          _children = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print("Error loading children: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load pending outing approvals for parent
  Future<void> loadPendingApprovals(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/passes/pending/parent');

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
      // ignore: avoid_print
      print('Error loading pending approvals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all child's passes
  Future<void> loadChildPasses(String childId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/passes/user/$childId');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _childPasses =
              jsonData.map((p) => PassModel.fromJson(Map<String, dynamic>.from(p))).toList();
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          _childPasses = (jsonData['data'] as List)
              .map((p) => PassModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }
      } else {
        _errorMessage = 'Failed to load child passes';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error loading child passes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a pass for child
  Future<bool> approvePass(String passId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.patch(
        '/api/passes/$passId/approve-parent',
        {
          'status': 'approved',
          'approvedAt': DateTime.now().toIso8601String()
        },
      );

      if (response.statusCode == 200) {
        // Remove from pending list
        _pendingApprovals.removeWhere((p) => p.id == passId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to approve pass';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error approving pass: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reject a pass for child
  Future<bool> rejectPass(String passId, String reason, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.patch(
        '/api/passes/$passId/reject',
        {
          'reason': reason,
        },
      );

      if (response.statusCode == 200) {
        _pendingApprovals.removeWhere((p) => p.id == passId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to reject pass';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // ignore: avoid_print
      print('Error rejecting pass: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start tracking child's location
  Future<void> startChildTracking(String childId, String token) async {
    try {
      if (_isTrackingChild) return; // Prevent multiple loops
      
      _isTrackingChild = true;
      _errorMessage = null;
      notifyListeners();

      // Recursive function for polling
      Future<void> poll() async {
        if (!_isTrackingChild) return;
        
        await _getChildLocation(childId, token);
        
        if (_isTrackingChild) {
          Future.delayed(const Duration(seconds: 5), poll);
        }
      }

      // Start polling
      poll();
      
    } catch (e) {
      _errorMessage = 'Error starting tracking: $e';
      print('Error starting child tracking: $e');
    }
  }

  /// Stop tracking child's location
  void stopChildTracking() {
    _isTrackingChild = false;
    _childLocation = {};
    notifyListeners();
  }

  /// Get child's current location (internal)
  Future<void> _getChildLocation(String childId, String token) async {
    try {
      final response = await _apiClient.get('/api/location/student/$childId');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map) {
          _childLocation = Map<String, dynamic>.from(jsonData);
        } else if (jsonData is List && jsonData.isNotEmpty) {
          _childLocation = Map<String, dynamic>.from(jsonData.first);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching child location: $e');
    }
  }

  /// Load geofence violations for child
  Future<void> loadGeofenceViolations(String childId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/location/violations');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _geofenceViolations = List.from(jsonData)
              .where((v) => v['studentId'] == childId)
              .toList();
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

  /// Load SOS alerts for child
  Future<void> loadSOSAlerts(String childId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get('/api/sos/history/$childId');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          _sosAlerts = List.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          _sosAlerts = List.from(jsonData['data'] ?? []);
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

  /// Get location history for child
  Future<List<dynamic>> getChildLocationHistory(
    String childId,
    String token,
    {int limit = 100}
  ) async {
    try {
      final response = await _apiClient.get('/api/location/history/$childId?limit=$limit');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          return List.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          return List.from(jsonData['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching location history: $e');
      return [];
    }
  }

  /// Request instant location update
  Future<void> requestInstantUpdate(String childId, String token) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 1. Trigger Request
      await _apiClient.post('/api/location/request-update', {'studentId': childId});
      
      // 2. Wait for student device to respond (mock delay for UX)
      await Future.delayed(const Duration(seconds: 4));
      
      // 3. Fetch latest data
      await _getChildLocation(childId, token);
    } catch (e) {
      print("Error requesting location: $e");
      _errorMessage = "Failed to request location";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
