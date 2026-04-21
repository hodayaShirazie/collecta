import '../data/repositories/route_optimization_repository.dart';
import '../data/models/donation_model.dart';

class RouteOptimizationService {
  final RouteOptimizationRepository _repo = RouteOptimizationRepository();

  /// מקבל רשימת תרומות ומחזיר אותן מסודרות לפי המסלול האופטימלי.
  Future<List<DonationModel>> optimizeDonationRoute(
    List<DonationModel> donations,
  ) async {
    if (donations.length < 2) return donations;

    final nodes = donations
        .map((d) => [d.businessAddress.lat, d.businessAddress.lng])
        .toList();

    final orderedIndices = await _repo.getOptimalRoute(nodes);

    return orderedIndices
        .where((i) => i < donations.length)
        .map((i) => donations[i])
        .toList();
  }
}
