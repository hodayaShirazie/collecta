import '../datasources/remote/route_optimization_api.dart';

class RouteOptimizationRepository {
  final RouteOptimizationApi _api = RouteOptimizationApi();

  /// מחזיר רשימת אינדקסים לפי סדר אופטימלי.
  /// [nodes] – רשימת [lat, lng] לפי הסדר הנוכחי.
  Future<List<int>> getOptimalRoute(List<List<double>> nodes) {
    return _api.computeOptimalRoute(nodes);
  }
}
