// lib/utils/cache_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheManager {
  static const String _passCacheKey = 'cached_passes';
  static const String _userCacheKey = 'cached_user';

  static Future<void> cachePasses(List<Map<String, dynamic>> passes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passCacheKey, jsonEncode(passes));
  }

  static Future<List<Map<String, dynamic>>> getCachedPasses() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_passCacheKey);
    if (cached != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cached));
    }
    return [];
  }

  static Future<void> cacheUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_userCacheKey);
    if (cached != null) {
      return jsonDecode(cached);
    }
    return null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passCacheKey);
    await prefs.remove(_userCacheKey);
  }
}