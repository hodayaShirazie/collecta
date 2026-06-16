import '../data/repositories/route_optimization_repository.dart';
import '../data/models/donation_model.dart';

class RouteOptimizationService {
  final RouteOptimizationRepository _repo = RouteOptimizationRepository();

  double _parseTimeToFloat(String time) {
    final parts = time.split(':');
    final hours = double.parse(parts[0]);
    final minutes = parts.length > 1 ? double.parse(parts[1]) : 0.0;
    return hours + minutes / 60.0;
  }

  Future<List<DonationModel>> optimizeDonationRoute(
    List<DonationModel> donations, {
    required String driverId,
    double startLat = 0.0,
    double startLng = 0.0,
    double? endLat,
    double? endLng,
  }) async {
    if (donations.isEmpty) return donations;

    final currentLocation = [startLat, startLng, 0.0, 24.0, 0.0];
    final stops = donations.map((d) {
      final tw = d.pickupTimes.isNotEmpty ? d.pickupTimes.first : null;
      final twStart = tw != null ? _parseTimeToFloat(tw.from) : 0.0;
      final twEnd   = tw != null ? _parseTimeToFloat(tw.to)   : 24.0;
      return [d.businessAddress.lat, d.businessAddress.lng, twStart, twEnd, 20.0];
    }).toList();
    final endPoint = (endLat != null && endLng != null)
        ? [endLat, endLng, 0.0, 24.0, 0.0]
        : null;

    final orderedIds = await _repo.getOptimalRoute(
      currentLocation: currentLocation,
      stops: stops,
      endPoint: endPoint,
      driverId: driverId,
    );

    // ids are positions into `stops`; -1 (current_location) / -2 (end_point)
    // are filtered out here since they aren't donations.
    return orderedIds
        .where((i) => i >= 0 && i < donations.length)
        .map((i) => donations[i])
        .toList();
  }

  Future<void> clearDriverCache(String driverId) {
    return _repo.clearDriverCache(driverId);
  }
}
