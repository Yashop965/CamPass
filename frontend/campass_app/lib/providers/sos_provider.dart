// lib/providers/sos_provider.dart
import 'package:flutter/material.dart';
import '../services/sos_service.dart';
import '../services/location_service.dart';

class SOSProvider extends ChangeNotifier {
  final SOSService _sosService = SOSService();
  final LocationService _locationService = LocationService();

  bool _isSOSActive = false;
  String? _lastSOSId;
  DateTime? _lastSOSTime;
  List<dynamic> _sosHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isSOSActive => _isSOSActive;
  String? get lastSOSId => _lastSOSId;
  DateTime? get lastSOSTime => _lastSOSTime;
  List<dynamic> get sosHistory => _sosHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Send SOS alert (when student shakes phone)
  Future<void> sendSOSAlert({
    required String studentId,
    required String token,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get current location
      final position = await _locationService.getCurrentLocation();

      // Send SOS to backend
      final response = await _sosService.sendSOSAlert(
        studentId: studentId,
        latitude: position.latitude,
        longitude: position.longitude,
        token: token,
        alertType: 'manual',
      );

      _isSOSActive = true;
      _lastSOSId = response['sos']['id'];
      _lastSOSTime = DateTime.now();
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send SOS: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Resolve SOS alert (admin/warden action)
  Future<void> resolveSOSAlert(String sosId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _sosService.resolveSOSAlert(sosId, token);

      _isSOSActive = false;
      _lastSOSId = null;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to resolve SOS: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get SOS history for a student
  Future<void> getSOSHistory(String studentId, String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _sosHistory = await _sosService.getSOSHistory(studentId, token);
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load SOS history: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get active SOS alerts
  Future<void> getActiveSOSAlerts(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _sosHistory = await _sosService.getActiveSOSAlerts(token);
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load active SOS alerts: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
