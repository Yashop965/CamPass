import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_endpoints.dart';
import '../core/config/app_config.dart';

class ApiClient {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  // Getters for tokens
  Future<String?> getToken() => _storage.read(key: 'jwt_token');
  Future<void> saveToken(String token) => _storage.write(key: 'jwt_token', value: token);
  Future<void> deleteToken() => _storage.delete(key: 'jwt_token');

  // Default headers
  Future<Map<String, String>> _getDefaultHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // HTTP methods with timeout and error handling
  Future<http.Response> get(String path) async {
    try {
      final headers = await _getDefaultHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');

      if (AppConfig.enableLogging) {
        print('GET: $uri');
      }

      final response = await _client.get(uri, headers: headers)
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e, 'GET $path');
    }
  }

  Future<http.Response> post(String path, Object body) async {
    try {
      final headers = await _getDefaultHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');

      if (AppConfig.enableLogging) {
        print('POST: $uri');
        print('Body: $body');
      }

      final response = await _client.post(uri, headers: headers, body: jsonEncode(body))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e, 'POST $path');
    }
  }

  Future<http.Response> patch(String path, Object body) async {
    try {
      final headers = await _getDefaultHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');

      if (AppConfig.enableLogging) {
        print('PATCH: $uri');
        print('Body: $body');
      }

      final response = await _client.patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e, 'PATCH $path');
    }
  }

  Future<http.Response> delete(String path) async {
    try {
      final headers = await _getDefaultHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');

      if (AppConfig.enableLogging) {
        print('DELETE: $uri');
      }

      final response = await _client.delete(uri, headers: headers)
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e, 'DELETE $path');
    }
  }

  Future<http.Response> put(String path, Object body) async {
    try {
      final headers = await _getDefaultHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');

      if (AppConfig.enableLogging) {
        print('PUT: $uri');
        print('Body: $body');
      }

      final response = await _client.put(uri, headers: headers, body: jsonEncode(body))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e, 'PUT $path');
    }
  }

  // Response handler
  http.Response _handleResponse(http.Response response) {
    if (AppConfig.enableLogging) {
      print('Response: ${response.statusCode} - ${response.body}');
    }
    return response;
  }

  // Error handler
  http.Response _handleError(dynamic error, String operation) {
    if (AppConfig.enableLogging) {
      print('API Error in $operation: $error');
    }

    // Return a custom response for errors
    return http.Response(
      jsonEncode({'error': error.toString(), 'message': 'Network error occurred'}),
      500, // Custom status code for network errors (0 is invalid in http package)
      headers: {'content-type': 'application/json'},
    );
  }

  // Cleanup
  void dispose() {
    _client.close();
  }
}
