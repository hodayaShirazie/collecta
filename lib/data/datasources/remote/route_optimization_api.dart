import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import 'api_source.dart';

class RouteOptimizationApi extends ApiSource {
  /// שולח רשימת נקודות לפונקציה שמפעילה את שרת LGCN.
  /// מחזיר רשימת אינדקסים לפי הסדר האופטימלי.
  Future<List<int>> computeOptimalRoute(List<List<double>> points) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/computeRoutes'),
          headers: await headers(),
          body: jsonEncode({
            'points': points,
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

    final rawRoute = (data['routes']['0'] as List).cast<int>();

    // הסר depot כפול בסוף אם קיים
    if (rawRoute.length > 1 && rawRoute.first == rawRoute.last) {
      return rawRoute.sublist(0, rawRoute.length - 1);
    }
    return rawRoute;
  }
}
