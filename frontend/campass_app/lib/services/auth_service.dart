import 'dart:convert';
import '../utils/api_client.dart';
import '../models/user_model.dart';
import 'session_manager.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  ApiClient get api => _api;

  Future<Map<String, dynamic>?> register(String name, String email, String password, String role) async {
    final res = await _api.post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role
    });
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data;
      return data;
    } else {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  Future<UserModel?> login(String email, String password) async {
    final res = await _api.post('/api/auth/login', {'email': email, 'password': password});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final token = data['token'];
      if (token != null) {
        await _api.saveToken(token);
        return UserModel.fromJson(data['user']);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> linkStudent(String email, String token) async {
      // Note: Backend expects 'studentEmail', frontend sends 'studentEmail' 
      // but let's make sure the key matches validRegistration or similar if needed.
      // Based on controller: const { studentEmail } = req.body;
      final res = await _api.post('/api/auth/link-student', {
        'studentEmail': email
      });
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to link student');
      }
  }

  Future<void> logout() async {
    await _api.deleteToken();
    await SessionManager.logout();
  }
}
