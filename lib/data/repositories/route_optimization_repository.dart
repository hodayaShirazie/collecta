import '../datasources/remote/route_optimization_api.dart';

class RouteOptimizationRepository {
  final RouteOptimizationApi _api = RouteOptimizationApi();

  Future<List<int>> getOptimalRoute({
    required List<double> currentLocation,
    required List<List<double>> stops,
    List<double>? endPoint,
    required String driverId,
  }) {
    return _api.computeOptimalRoute(
      currentLocation: currentLocation,
      stops: stops,
      endPoint: endPoint,
      driverId: driverId,
    );
  }

  Future<void> clearDriverCache(String driverId) {
    return _api.clearDriverCache(driverId);
  }
}
