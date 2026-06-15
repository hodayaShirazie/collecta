import '../datasources/remote/route_optimization_api.dart';

class RouteOptimizationRepository {
  final RouteOptimizationApi _api = RouteOptimizationApi();

  Future<List<int>> getOptimalRoute(List<List<double>> nodes, String driverId) {
    return _api.computeOptimalRoute(nodes, driverId);
  }

  Future<void> clearDriverCache(String driverId) {
    return _api.clearDriverCache(driverId);
  }
}
