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
    bool useCache = false,
    double startLat = 0.0,
    double startLng = 0.0,
  }) async {
    if (donations.isEmpty) return donations;

    final points = useCache
        ? <List<double>>[]
        : <List<double>>[
            [startLat, startLng, 0.0, 24.0, 0.0],
            ...donations.map((d) {
              final tw = d.pickupTimes.isNotEmpty ? d.pickupTimes.first : null;
              final twStart = tw != null ? _parseTimeToFloat(tw.from) : 0.0;
              final twEnd   = tw != null ? _parseTimeToFloat(tw.to)   : 24.0;
              return [d.businessAddress.lat, d.businessAddress.lng, twStart, twEnd, 20.0];
            }),
          ];

    final orderedIndices = await _repo.getOptimalRoute(points, driverId);

    return orderedIndices
        .where((i) => i > 0 && i <= donations.length)
        .map((i) => donations[i - 1])
        .toList();
  }

  Future<void> clearDriverCache(String driverId) {
    return _repo.clearDriverCache(driverId);
  }
}
