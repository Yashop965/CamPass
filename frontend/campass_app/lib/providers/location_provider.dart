// lib/providers/location_provider.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../core/constants/map_constants.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOutsideGeofence = false;
  Stream<Position>? _positionStream;



  // Campus geofence parameters from MapConstants

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOutsideGeofence => _isOutsideGeofence;

  /// Initialize location tracking
  Future<void> initializeLocationTracking({
    required String studentId,
    required String token,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Request permissions
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        _errorMessage = 'Location permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get initial position
      _currentPosition = await _locationService.getCurrentLocation();

      // Check geofence
      _checkGeofence();

      // Start continuous tracking
      _positionStream = _locationService.getLocationUpdates();
      _positionStream?.listen((position) async {
        _currentPosition = position;
        _checkGeofence();

        // Send location to backend
        await _updateLocationOnBackend(
          studentId: studentId,
          position: position,
          token: token,
        );

        notifyListeners();
      });

      _isTracking = true;
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize location tracking: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if student is within geofence
  void _checkGeofence() {
    if (_currentPosition == null) return;

    _isOutsideGeofence = !_locationService.isWithinGeofence(
      studentLat: _currentPosition!.latitude,
      studentLng: _currentPosition!.longitude,
      campusLat: MapConstants.campusLatitude,
      campusLng: MapConstants.campusLongitude,
      radiusInMeters: MapConstants.geofenceRadiusMeters,
    );

    notifyListeners();
  }

  /// Update location on backend
  Future<void> _updateLocationOnBackend({
    required String studentId,
    required Position position,
    required String token,
  }) async {
    try {
      await _locationService.updateLocation(
        studentId: studentId,
        latitude: position.latitude,
        longitude: position.longitude,
        token: token,
        accuracy: position.accuracy,
        isGeofenceViolation: _isOutsideGeofence,
      );
    } catch (e) {
      print('Error updating location on backend: $e');
      // Don't throw error, just log it
    }
  }

  /// Get student location (for parents/warden to view)
  Future<Map<String, dynamic>> getStudentLocation(
    String studentId,
    String token,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final location = await _locationService.getStudentLocation(studentId, token);
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = 'Failed to get student location: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Stop location tracking
  void stopTracking() {
    _isTracking = false;
    // Cancel the stream subscription if needed
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
