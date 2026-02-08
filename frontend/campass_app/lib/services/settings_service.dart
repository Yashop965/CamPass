import 'dart:convert';
import '../utils/api_client.dart';

class SettingsService {
  final ApiClient _api = ApiClient();

  ApiClient get api => _api;

  Future<Map<String, dynamic>?> getSettings() async {
    final res = await _api.get('/api/settings');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['settings'];
    }
    return null;
  }

  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    final res = await _api.put('/api/settings', settings);
    return res.statusCode == 200;
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final res = await _api.post('/api/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return res.statusCode == 200;
  }
}