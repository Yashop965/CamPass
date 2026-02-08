// lib/services/barcode_service.dart
import 'dart:convert';
import '../utils/api_client.dart';

class BarcodeService {
  final ApiClient _api = ApiClient();

  /// Scan and verify barcode (for guards)
  Future<Map<String, dynamic>?> scanBarcode(String barcode) async {
    final res = await _api.post('/api/passes/scan', {'barcode': barcode});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data;
    }
    return null;
  }

  /// Generate barcode for a pass
  Future<Map<String, dynamic>?> generateBarcode({
    required String userId,
    required String type,
    required String validFrom,
    required String validTo,
  }) async {
    final res = await _api.post('/api/passes/generate', {
      'userId': userId,
      'type': type,
      'validFrom': validFrom,
      'validTo': validTo,
    });

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data;
    }
    return null;
  }
}
