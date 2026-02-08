// lib/providers/pass_provider.dart
import 'package:flutter/foundation.dart';
import '../models/pass_model.dart';
import '../services/pass_service.dart';

class PassProvider with ChangeNotifier {
  final PassService _passService = PassService();
  List<PassModel> _passes = [];
  bool _isLoading = false;
  String? _error;

  List<PassModel> get passes => _passes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPasses(String userId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _passes = await _passService.getPassesForUser(userId, token);
    } catch (e) {
      _error = e.toString();
      _passes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPasses(List<PassModel> passes) {
    _passes = passes;
    notifyListeners();
  }

  Future<void> createPass(
    Map<String, dynamic> payload,
    String token,
    DateTime validFrom,
    DateTime validTo,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _passService.createPass(payload, token, validFrom, validTo);
      // Optionally refresh passes after creation
      // await loadPasses(userId, token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
