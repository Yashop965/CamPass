// lib/services/pass_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pass_model.dart';
import '../core/constants/api_endpoints.dart';
import '../utils/api_client.dart';

class PassService {
  final String baseUrl;
  final ApiClient _apiClient = ApiClient();

  PassService({String? baseUrl}) : baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  // simple _api wrapper if you used it in controllers
  http.Client get _api => http.Client();

  Future<Map<String, dynamic>> createPass(Map<String, dynamic> payload,
      String token, DateTime validFrom, DateTime validTo) async {
    final uri = Uri.parse('$baseUrl/api/passes/generate');
    final res = await _api.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload));
    
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create pass: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> scanPass(String barcode) async {
    final uri = Uri.parse('$baseUrl/api/passes/scan');
    final res = await _api.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'barcode': barcode}));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<dynamic> scanBarcode(String raw) async {}

  Future<List<PassModel>> getPassesForUser(String userId, String token) async {
    final uri = Uri.parse('$baseUrl/api/passes/user/$userId');
    final res = await _api.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((json) => PassModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load passes');
    }
  }

  Future<Map<String, dynamic>> approveByWarden(String passId, String token) async {
    final uri = Uri.parse('$baseUrl/api/passes/$passId/approve-warden');
    final res = await _api.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'approved',
          'approvedAt': DateTime.now().toIso8601String()
        }));
    
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to approve pass: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> approveByParent(String passId, String token) async {
    final uri = Uri.parse('$baseUrl/api/passes/$passId/approve-parent');
    final res = await _api.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'approved',
          'approvedAt': DateTime.now().toIso8601String()
        }));
    
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to approve pass: ${res.body}');
    }
  }

  Future<void> rejectPass(String passId, String reason, String token) async {
    final path = '/api/passes/$passId/reject';
    // Use _apiClient to utilize stored token, ignoring 'token' arg if stale
    final res = await _apiClient.patch(path, {'reason': reason});
    
    if (res.statusCode != 200) {
      throw Exception('Failed to reject pass: ${res.body}');
    }
  }
}
