import '../data/repositories/route_optimization_repository.dart';
import '../data/models/donation_model.dart';

class RouteOptimizationService {
  final RouteOptimizationRepository _repo = RouteOptimizationRepository();

  /// מקבל תרומות + מיקום נוכחי של הנהג.
  /// מחזיר את התרומות מסודרות לפי המסלול האופטימלי.
  ///
  /// [startLat] / [startLng] — מיקום הנהג (depot, נקודה 0 באלגוריתם).
  /// האלגוריתם מקבל: [currentLocation, ...donations] ומחזיר אינדקסים מסודרים.
  Future<List<DonationModel>> optimizeDonationRoute(
    List<DonationModel> donations, {
    required double startLat,
    required double startLng,
  }) async {
    if (donations.isEmpty) return donations;

    // node[0] = מיקום נוכחי (depot), node[1..N] = כתובות התרומות
    final nodes = [
      [startLat, startLng],
      ...donations.map((d) => [d.businessAddress.lat, d.businessAddress.lng]),
    ];

    final orderedIndices = await _repo.getOptimalRoute(nodes);

    // סנן את ה-depot (אינדקס 0) והמיר אינדקסים → תרומות (1-based)
    return orderedIndices
        .where((i) => i > 0 && i <= donations.length)
        .map((i) => donations[i - 1])
        .toList();
  }
}
