import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AdminViewManager {
  static String? _adminToken;
  static String? _driverId;
  static String? _driverName;

  static bool get hasPendingView =>
      _driverId != null && _adminToken != null;

  static String? get adminToken => _adminToken;
  static String? get driverId => _driverId;
  static String? get driverName => _driverName;

  static void readFromUrl() {
    if (!kIsWeb) return;
    final params = Uri.base.queryParameters;
    _adminToken = params['adminToken'];
    _driverId = params['driverId'];
    _driverName = params['driverName'];
  }

  static Future<bool> verifyToken() async {
    if (_adminToken == null) return false;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/verifyAdmin'),
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static void clear() {
    _adminToken = null;
    _driverId = null;
    _driverName = null;
  }
}
