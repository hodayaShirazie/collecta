import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import 'api_source.dart';

class RouteOptimizationApi extends ApiSource {
  // currentLocation = driver's current position, stops = donation pickups,
  // endPoint = today's destination (optional). The server returns route ids
  // with -1 marking current_location and -2 marking end_point (when sent).
  Future<List<int>> computeOptimalRoute({
    required List<double> currentLocation,
    required List<List<double>> stops,
    List<double>? endPoint,
    required String driverId,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/computeRoutes'),
          headers: await headers(),
          body: jsonEncode({
            'driver_id': driverId,
            'current_location': currentLocation,
            'nodes': stops,
            if (endPoint != null) 'end_point': endPoint,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('שגיאה בחישוב המסלול (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'שגיאה לא ידועה מהשרת');
    }

    return (data['routes']['0'] as List).cast<int>();
  }

  Future<void> clearDriverCache(String driverId) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}/deleteDriver/$driverId'),
          headers: await headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('שגיאה באיפוס הנהג בשרת (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> removeDriverStop(String driverId, double lat, double lng) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/removeDriverStop/$driverId')
        .replace(queryParameters: {'x': lat.toString(), 'y': lng.toString()});

    final response = await http
        .delete(uri, headers: await headers())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('שגיאה בהסרת תחנה מהשרת (${response.statusCode}): ${response.body}');
    }
  }
}
