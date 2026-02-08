// lib/services/location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../core/constants/api_endpoints.dart';

class LocationService {
  final String baseUrl;

  LocationService({String? baseUrl}) : baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  http.Client get _api => http.Client();

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  /// Get current location
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Start real-time location tracking (listen to position changes)
  Stream<Position> getLocationUpdates({
    int intervalSeconds = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update when moved 10 meters
      ),
    );
  }

  /// Update location on backend
  Future<Map<String, dynamic>> updateLocation({
    required String studentId,
    required double latitude,
    required double longitude,
    required String token,
    double? accuracy,
    bool isGeofenceViolation = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.updateLocation}');
      final res = await _api.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'isGeofenceViolation': isGeofenceViolation,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update location: ${res.body}');
      }
    } catch (e) {
      throw Exception('Location service error: $e');
    }
  }

  /// Get current location of a student (for parents/warden)
  Future<Map<String, dynamic>> getStudentLocation(
    String studentId,
    String token,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.getStudentLocation}/$studentId');
      final res = await _api.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get student location');
      }
    } catch (e) {
      throw Exception('Location service error: $e');
    }
  }

  /// Get location history
  Future<List<dynamic>> getLocationHistory(
    String studentId,
    String token, {
    int limit = 100,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl${ApiEndpoints.getLocationHistory}/$studentId?limit=$limit',
      );
      final res = await _api.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data;
      } else {
        throw Exception('Failed to get location history');
      }
    } catch (e) {
      throw Exception('Location service error: $e');
    }
  }

  /// Check if student is within geofence
  bool isWithinGeofence({
    required double studentLat,
    required double studentLng,
    required double campusLat,
    required double campusLng,
    required double radiusInMeters,
  }) {
    final distance = Geolocator.distanceBetween(
      studentLat,
      studentLng,
      campusLat,
      campusLng,
    );
    return distance <= radiusInMeters;
  }
}
