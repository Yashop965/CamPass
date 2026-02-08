import 'dart:convert';
import '../utils/api_client.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient _api = ApiClient();

  Future<UserModel?> getUserById(String id) async {
    final res = await _api.get('/api/users/$id');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return UserModel.fromJson(data);
    }
    return null;
  }

  Future<bool> updateProfile(String id, Map<String, dynamic> body) async {
    final res = await _api.patch('/api/users/$id', body);
    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>> updateProfileData(
    Map<String, dynamic> profileData,
  ) async {
    final res = await _api.put('/api/users/profile', profileData);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    final res = await _api.put('/api/users/settings', settings);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update settings: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> changePassword(
    Map<String, dynamic> passwordData,
  ) async {
    final res = await _api.post('/api/auth/change-password', passwordData);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to change password: ${res.body}');
    }
  }
}
