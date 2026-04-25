import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/donation_service.dart';
import '../../services/driver_service.dart';
import '../../services/route_optimization_service.dart';
import '../../data/models/donation_model.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/driver_model.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../widgets/loading_indicator.dart';
import 'driver_pickup.dart';

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
  final DriverService _driverService = DriverService();
  final RouteOptimizationService _optimizationService = RouteOptimizationService();

  List<DonationModel> donations = [];
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

      final todayHebrew = _weekdayToHebrew[DateTime.now().weekday];
      final todayDest = todayHebrew != null
          ? driverProfile.destinations
              .cast<DestinationModel?>()
              .firstWhere((d) => d?.day == todayHebrew, orElse: () => null)
          : null;

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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.volunteer_activism),
                label: const Text('איסוף תרומה',
                    style: TextStyle(fontFamily: 'Assistant', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DriverPickupPage(donationId: donation.id)),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.navigation),
                label: const Text('נווט לבית העסק',
                    style: TextStyle(fontFamily: 'Assistant', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _navigateWithWaze(
                      donation.businessAddress.lat, donation.businessAddress.lng);
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

  int get _itemCount =>
      donations.length + (_todayDestination != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
        child: SafeArea(
          child: isLoading
              ? const LoadingIndicator()
              : Column(
                  children: [
                    // ── כותרת ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          const SizedBox(height: HomepageTheme.topPadding),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: HomepageTheme.latetBlue, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Expanded(
                                child: Text(
                                  "המסלול היומי",
                                  textAlign: TextAlign.center,
                                  style: ReportDonationTheme.headerStyle,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // ── כפתור מיטוב ──
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOptimized
                                      ? Colors.green.shade600
                                      : HomepageTheme.latetBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                  elevation: 3,
                                ),
                                onPressed:
                                    isOptimizing ? null : _optimizeRoute,
                                icon: isOptimizing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : Icon(isOptimized
                                        ? Icons.check_circle_outline
                                        : Icons.route),
                                label: Text(
                                  isOptimizing
                                      ? 'מחשב מסלול אופטימלי...'
                                      : isOptimized
                                          ? 'המסלול אופטימלי ✓'
                                          : 'חשב מסלול אופטימלי',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Assistant',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // ── רשימת תחנות ──
                    Expanded(
                      child: donations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.route,
                                      size: 64,
                                      color: HomepageTheme.latetBlue
                                          .withOpacity(0.25)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "אין תרומות במסלול היום",
                                    style: TextStyle(
                                      fontFamily: 'Assistant',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 8, 30),
                              itemCount: _itemCount,
                              itemBuilder: (context, index) {
                                final isFirst = index == 0;
                                final isLast = index == _itemCount - 1;
                                final isDestinationItem =
                                    _todayDestination != null &&
                                    index == donations.length;

                                if (isDestinationItem) {
                                  return _buildTimelineItem(
                                    isFirst: isFirst,
                                    isLast: isLast,
                                    pinColor: Colors.green.shade600,
                                    pinIcon: Icons.flag_rounded,
                                    label: "יעד סיום",
                                    title: _todayDestination!.name.isNotEmpty
                                        ? _todayDestination!.name
                                        : 'יעד ${_todayDestination!.day}',
                                    subtitle: _todayDestination!.address.name,
                                    onTap: null,
                                  );
                                }

                                final donation = donations[index];
                                final businessName =
                                    donation.businessName.isNotEmpty
                                        ? donation.businessName
                                        : donation.contactName.isNotEmpty
                                            ? donation.contactName
                                            : 'עסק לא ידוע';

                                return _buildTimelineItem(
                                  isFirst: isFirst,
                                  isLast: isLast,
                                  pinColor: index == 0
                                      ? const Color(0xFFD32F2F)
                                      : HomepageTheme.latetBlue,
                                  pinIcon: index == 0
                                      ? Icons.my_location_rounded
                                      : Icons.location_on_rounded,
                                  label: "תחנה ${index + 1}",
                                  title: businessName,
                                  subtitle: donation.businessAddress.name,
                                  onTap: () => _showStopOptions(
                                      context, donation, businessName),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isFirst,
    required bool isLast,
    required Color pinColor,
    required IconData pinIcon,
    required String label,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    const lineColor = Color(0xFFB0C4DE);
    const pinSize = 46.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // תוכן התחנה (צד שמאל)
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(right: 10, bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: pinColor,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Assistant',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Assistant',
                      color: HomepageTheme.latetBlue,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Assistant',
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey),
                      ],
                    ),
                  ],
                  if (onTap != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'לחץ לאפשרויות',
                            style: TextStyle(
                              fontSize: 11,
                              color: pinColor.withOpacity(0.6),
                              fontFamily: 'Assistant',
                            ),
                          ),
                          Icon(Icons.chevron_left,
                              size: 14, color: pinColor.withOpacity(0.6)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // עמודת timeline — פין + קו (צד ימין)
        SizedBox(
          width: 52,
          child: Column(
            children: [
              Container(
                width: 3,
                height: 16,
                color: isFirst ? Colors.transparent : lineColor,
              ),
              Container(
                width: pinSize,
                height: pinSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pinColor,
                  boxShadow: [
                    BoxShadow(
                      color: pinColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(pinIcon, color: Colors.white, size: 22),
              ),
              Container(
                width: 3,
                height: 44,
                color: isLast ? Colors.transparent : lineColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
