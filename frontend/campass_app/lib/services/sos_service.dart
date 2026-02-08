// lib/services/sos_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class SOSService {
  final String baseUrl;

  SOSService({String? baseUrl}) : baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  http.Client get _api => http.Client();

  /// Send SOS alert to backend
  Future<Map<String, dynamic>> sendSOSAlert({
    required String studentId,
    required double latitude,
    required double longitude,
    String token = '',
    String alertType = 'manual',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.sendSos}');
      final res = await _api.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'latitude': latitude,
          'longitude': longitude,
          'alertType': alertType,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to send SOS alert: ${res.body}');
      }
    } catch (e) {
      throw Exception('SOS service error: $e');
    }
  }

  /// Get active SOS alerts (for admin/parent/warden view)
  Future<List<dynamic>> getActiveSOSAlerts(String token) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.sendSos}/active');
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
        throw Exception('Failed to get SOS alerts');
      }
    } catch (e) {
      throw Exception('SOS service error: $e');
    }
  }

  /// Resolve an SOS alert
  Future<Map<String, dynamic>> resolveSOSAlert(
    String sosId,
    String token,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.sendSos}/$sosId/resolve');
      final res = await _api.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to resolve SOS alert');
      }
    } catch (e) {
      throw Exception('SOS service error: $e');
    }
  }

  /// Get SOS history for a student
  Future<List<dynamic>> getSOSHistory(
    String studentId,
    String token,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.getSOSHistory}/$studentId');
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
        throw Exception('Failed to get SOS history');
      }
    } catch (e) {
      throw Exception('SOS service error: $e');
    }
  }
}
