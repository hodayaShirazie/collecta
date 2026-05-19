import '../datasources/remote/route_optimization_api.dart';

class RouteOptimizationRepository {
  final RouteOptimizationApi _api = RouteOptimizationApi();
  Future<List<int>> getOptimalRoute(List<List<double>> nodes) {
    return _api.computeOptimalRoute(nodes);
  }
}
