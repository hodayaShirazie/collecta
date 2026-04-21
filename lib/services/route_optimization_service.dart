import '../data/repositories/route_optimization_repository.dart';
import '../data/models/donation_model.dart';

class RouteOptimizationService {
  final RouteOptimizationRepository _repo = RouteOptimizationRepository();

  // ממיר מחרוזת שעה "HH:MM" למספר עשרוני (למשל "08:30" → 8.5)
  double _parseTimeToFloat(String time) {
    final parts = time.split(':');
    final hours = double.parse(parts[0]);
    final minutes = parts.length > 1 ? double.parse(parts[1]) : 0.0;
    return hours + minutes / 60.0;
  }

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

    // point[0] = מיקום נוכחי (depot) — חלון זמן פתוח, אין המתנה
    // point[1..N] = כתובות התרומות עם חלון הזמן הראשון ו-20 דק' המתנה
    final points = <List<double>>[
      [startLat, startLng, 0.0, 24.0, 0.0],
      ...donations.map((d) {
        final tw = d.pickupTimes.isNotEmpty ? d.pickupTimes.first : null;
        final twStart = tw != null ? _parseTimeToFloat(tw.from) : 0.0;
        final twEnd   = tw != null ? _parseTimeToFloat(tw.to)   : 24.0;
        return [d.businessAddress.lat, d.businessAddress.lng, twStart, twEnd, 20.0];
      }),
    ];

    final orderedIndices = await _repo.getOptimalRoute(points);

    // סנן את ה-depot (אינדקס 0) והמיר אינדקסים → תרומות (1-based)
    return orderedIndices
        .where((i) => i > 0 && i <= donations.length)
        .map((i) => donations[i - 1])
        .toList();
  }
}
