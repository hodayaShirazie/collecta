import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/donation_service.dart';
import '../../services/donor_service.dart';
import '../../services/driver_service.dart';
import '../../services/route_optimization_service.dart';
import '../../data/models/donation_model.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/driver_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/loading_indicator.dart';
import 'driver_pickup.dart';

/// מיפוי מ-DateTime.weekday (1=ב', 7=א') לשם היום בעברית
const Map<int, String> _weekdayToHebrew = {
  7: 'ראשון',
  1: 'שני',
  2: 'שלישי',
  3: 'רביעי',
  4: 'חמישי',
};

class DailyRouteDriverPage extends StatefulWidget {
  const DailyRouteDriverPage({super.key});

  @override
  State<DailyRouteDriverPage> createState() => _DailyRouteDriverPageState();
}

class _DailyRouteDriverPageState extends State<DailyRouteDriverPage> {
  final DonationService _donationService = DonationService();
  final DonorService _donorService = DonorService();
  final DriverService _driverService = DriverService();
  final RouteOptimizationService _optimizationService = RouteOptimizationService();

  List<DonationModel> donations = [];
  Map<String, String> donorNames = {};
  DestinationModel? _todayDestination;

  bool isLoading = true;
  bool isOptimizing = false;
  bool isOptimized = false;

  @override
  void initState() {
    super.initState();
    _loadDriverRoute();
  }

  Future<void> _loadDriverRoute() async {
    try {
      setState(() => isLoading = true);

      final results = await Future.wait([
        _donationService.getDriverDonationsById(),
        _driverService.getMyDriverProfile(),
      ]);

      final fetchedDonations = results[0] as List<DonationModel>;
      final driverProfile = results[1] as DriverProfile;

      // מצא את יעד היום לפי היום בשבוע
      final todayHebrew = _weekdayToHebrew[DateTime.now().weekday];
      final todayDest = todayHebrew != null
          ? driverProfile.destinations
              .cast<DestinationModel?>()
              .firstWhere(
                (d) => d?.day == todayHebrew,
                orElse: () => null,
              )
          : null;

      for (var donation in fetchedDonations) {
        if (!donorNames.containsKey(donation.donorId)) {
          try {
            final profile = await _donorService.getDonorProfileById(donation.donorId);
            donorNames[donation.donorId] = profile.businessName;
          } catch (_) {
            donorNames[donation.donorId] = "עסק לא ידוע";
          }
        }
      }

      setState(() {
        donations = fetchedDonations;
        _todayDestination = todayDest;
        isLoading = false;
        isOptimized = false;
      });
    } catch (e) {
      debugPrint("🔴 Error loading route: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _optimizeRoute() async {
    if (donations.isEmpty) return;

    setState(() => isOptimizing = true);

    try {
      // בקש הרשאת מיקום
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _showError('לא ניתן לגשת למיקום — אנא אשר הרשאה בהגדרות');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final optimized = await _optimizationService.optimizeDonationRoute(
        donations,
        startLat: position.latitude,
        startLng: position.longitude,
      );

      setState(() {
        donations = optimized;
        isOptimized = true;
      });
    } catch (e) {
      debugPrint("🔴 Error optimizing route: $e");
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => isOptimizing = false);
    }
  }

  Future<void> _navigateWithWaze(double lat, double lng) async {
    final wazeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
    final fallbackUri = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');

    if (await canLaunchUrl(wazeUri)) {
      await launchUrl(wazeUri);
    } else {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showStopOptions(BuildContext context, DonationModel donation, String businessName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          businessName,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Assistant', fontWeight: FontWeight.bold),
        ),
        content: Text(
          donation.businessAddress.name,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Assistant', color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomepageTheme.latetBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.volunteer_activism),
                label: const Text('איסוף תרומה',
                    style: TextStyle(fontFamily: 'Assistant', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverPickupPage(donationId: donation.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.navigation),
                label: const Text('נווט לבית העסק',
                    style: TextStyle(fontFamily: 'Assistant', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _navigateWithWaze(
                    donation.businessAddress.lat,
                    donation.businessAddress.lng,
                  );
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.red,
      ),
    );
  }

  // מספר הפריטים ברשימה: תרומות + יעד סיום (אם קיים ומסלול מוטב)
  int get _itemCount =>
      donations.length + (isOptimized && _todayDestination != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('המסלול היומי שלי',
            style: TextStyle(fontFamily: 'Assistant')),
        backgroundColor: HomepageTheme.latetBlue,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
        child: isLoading
            ? const LoadingIndicator()
            : Column(
                children: [
                  // ── כפתור מיטוב המסלול ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOptimized
                              ? Colors.green.shade600
                              : HomepageTheme.latetBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: isOptimizing ? null : _optimizeRoute,
                        icon: isOptimizing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(isOptimized
                                ? Icons.check_circle_outline
                                : Icons.route),
                        label: Text(
                          isOptimizing
                              ? 'מחשב מסלול מיטבי...'
                              : isOptimized
                                  ? 'המסלול מיוטב ✓'
                                  : 'מטב מסלול (LGCN)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Assistant',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── רשימת התחנות ──
                  Expanded(
                    child: donations.isEmpty
                        ? const Center(child: Text("אין תרומות במסלול היום"))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: _itemCount,
                            itemBuilder: (context, index) {
                              // פריט אחרון — יעד סיום
                              final isDestinationItem = isOptimized &&
                                  _todayDestination != null &&
                                  index == donations.length;

                              if (isDestinationItem) {
                                return _buildDestinationItem(_todayDestination!);
                              }

                              // פריט רגיל — תרומה
                              final donation = donations[index];
                              final businessName =
                                  donorNames[donation.donorId] ?? "טוען...";

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: HomepageTheme.latetBlue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 3,
                                  ),
                                  onPressed: () => _showStopOptions(
                                    context,
                                    donation,
                                    businessName,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_back_ios,
                                          size: 16),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "תחנה ${index + 1}: $businessName",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            donation.businessAddress.name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      const Icon(Icons.location_on,
                                          color: HomepageTheme.latetBlue),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDestinationItem(DestinationModel destination) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade400, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.flag, color: Colors.green, size: 22),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "יעד סיום: ${destination.name.isNotEmpty ? destination.name : 'יעד ${destination.day}'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                Text(
                  destination.address.name,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 15),
            const Icon(Icons.location_on, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
