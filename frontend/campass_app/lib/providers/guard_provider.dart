import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pass_model.dart';
import '../utils/api_client.dart';

class GuardProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // State variables
  PassModel? _lastScannedPass;
  final List<dynamic> _scannedHistory = [];
  String? _scanMessage;
  bool _isScanning = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PassModel? get lastScannedPass => _lastScannedPass;
  List<dynamic> get scannedHistory => _scannedHistory;
  String? get scanMessage => _scanMessage;
  bool get isScanning => _isScanning;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Scan and verify a pass barcode
  Future<bool> scanPass(String barcode, String token) async {
    try {
      _isScanning = true;
      _isLoading = true;
      _errorMessage = null;
      _scanMessage = 'Scanning...';
      notifyListeners();

      final response = await _apiClient.post('/api/passes/scan', {'barcode': barcode});

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map) {
          // Fix: Extract 'pass' object from response: { message: "...", pass: {...}, scanType: "..." }
          final passData = jsonData['pass'];
          final scanType = jsonData['scanType'];
          
          if (passData != null) {
              _lastScannedPass = PassModel.fromJson(Map<String, dynamic>.from(passData));
          } else {
             _lastScannedPass = PassModel.fromJson(Map<String, dynamic>.from(jsonData)); 
          }
          _scanMessage = 'Student ${scanType == 'exit' ? 'Exited' : 'Entered'} ✓';
          
          // Add to history
          _scannedHistory.insert(
            0,
            {
              'barcode': barcode,
              'status': 'verified',
              'timestamp': DateTime.now(),
              'passType': _lastScannedPass!.type,
              'studentName': _lastScannedPass!.studentName,
              'scanType': scanType,
            },
          );
        }
        notifyListeners();
        return true;
      } else {
        _scanMessage = 'Invalid pass ✗';
        _errorMessage = 'Pass verification failed';
        
        _scannedHistory.insert(
          0,
          {
            'barcode': barcode,
            'status': 'invalid',
            'timestamp': DateTime.now(),
          },
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error scanning pass: $e';
      _scanMessage = 'Scan failed ✗';
      // ignore: avoid_print
      print('Error scanning pass: $e');
      
      _scannedHistory.insert(
        0,
        {
          'barcode': barcode,
          'status': 'error',
          'timestamp': DateTime.now(),
          'error': e.toString(),
        },
      );
      notifyListeners();
      return false;
    } finally {
      _isScanning = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load scan history
  Future<void> loadScanHistory(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load from backend - would need an endpoint
      // For now, using local history which is built up from scans
      
    } catch (e) {
      _errorMessage = 'Error loading scan history: $e';
      // ignore: avoid_print
      print('Error loading scan history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get pass details by ID
  Future<PassModel?> getPassDetails(String passId, String token) async {
    try {
      final response = await _apiClient.get('/api/passes/$passId');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map) {
          return PassModel.fromJson(Map<String, dynamic>.from(jsonData));
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting pass details: $e');
      return null;
    }
  }

  /// Check if pass is valid (not expired, not cancelled)
  bool isPassValid(PassModel pass) {
    if (pass.status != 'active') return false;
    if (DateTime.now().isAfter(pass.validTo)) return false;
    return true;
  }

  /// Clear last scanned pass
  void clearLastScannedPass() {
    _lastScannedPass = null;
    _scanMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get scan statistics
  Map<String, int> getScanStats() {
    return {
      'totalScans': _scannedHistory.length,
      'verified': _scannedHistory.where((s) => s['status'] == 'verified').length,
      'invalid': _scannedHistory.where((s) => s['status'] == 'invalid').length,
      'errors': _scannedHistory.where((s) => s['status'] == 'error').length,
    };
  }
}
