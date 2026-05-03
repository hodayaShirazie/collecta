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
  final Set<String> _collectedIds = {};

  bool isLoading = true;
  bool isOptimizing = false;
  bool isOptimized = false;

  int get _currentStopIndex {
    for (int i = 0; i < donations.length; i++) {
      if (!_collectedIds.contains(donations[i].id)) return i;
    }
    return -1;
  }

  bool get _allCollected =>
      donations.isNotEmpty && _collectedIds.length >= donations.length;

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
        isOptimized = false;
      });

      if (fetchedDonations.isNotEmpty) {
        await _optimizeRoute();
      }
    } catch (e) {
      debugPrint("🔴 Error loading route: $e");
    } finally {
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

  void _showStopOptions(BuildContext context, DonationModel donation, String businessName, {bool isCollected = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          businessName,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Assistant', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              donation.businessAddress.name,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Assistant', color: Colors.grey),
            ),
            if (isCollected) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('נאסף', style: TextStyle(fontFamily: 'Assistant', color: Colors.green, fontSize: 13)),
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                ],
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isCollected)
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DriverPickupPage(donationId: donation.id)),
                    );
                    if (result == true && mounted) {
                      setState(() => _collectedIds.add(donation.id));
                    }
                  },
                ),
              if (!isCollected) const SizedBox(height: 10),
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

  void _showDestinationOptions(DestinationModel destination) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          destination.name.isNotEmpty ? destination.name : 'יעד סיום',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Assistant', fontWeight: FontWeight.bold),
        ),
        content: Text(
          destination.address.name,
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
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.navigation),
                label: const Text('נווט ליעד',
                    style: TextStyle(fontFamily: 'Assistant', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _navigateWithWaze(
                      destination.address.lat, destination.address.lng);
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('אשר פריקה',
                    style: TextStyle(fontFamily: 'Assistant', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmUnloading();
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUnloading() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('אישור פריקה',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Assistant', fontWeight: FontWeight.bold)),
        content: const Text(
          'האם לאשר פריקה וסיום המסלול היומי?',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Assistant'),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('ביטול',
                      style: TextStyle(fontFamily: 'Assistant', color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('אשר',
                      style: TextStyle(fontFamily: 'Assistant')),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _driverService.clearDriverStops();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showError('שגיאה באיפוס המסלול: ${e.toString().replaceFirst('Exception: ', '')}');
    }
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
                              Tooltip(
                                message: 'חשב מסלול מחדש',
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: isOptimizing
                                      ? const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: HomepageTheme.latetBlue,
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            Icons.refresh_rounded,
                                            size: 20,
                                            color: isOptimized
                                                ? Colors.green.shade500
                                                : HomepageTheme.latetBlue
                                                    .withOpacity(0.5),
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: _optimizeRoute,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
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
                                  final canUnload = _allCollected;
                                  return _buildTimelineItem(
                                    isFirst: isFirst,
                                    isLast: isLast,
                                    pinColor: canUnload
                                        ? Colors.green.shade600
                                        : Colors.green.shade300,
                                    pinIcon: Icons.flag_rounded,
                                    label: "יעד סיום",
                                    title: _todayDestination!.name.isNotEmpty
                                        ? _todayDestination!.name
                                        : 'יעד ${_todayDestination!.day}',
                                    subtitle: _todayDestination!.address.name,
                                    onTap: canUnload
                                        ? () => _showDestinationOptions(_todayDestination!)
                                        : null,
                                    destinationHint: canUnload
                                        ? 'נווט ופרוק'
                                        : null,
                                  );
                                }

                                final donation = donations[index];
                                final businessName =
                                    donation.businessName.isNotEmpty
                                        ? donation.businessName
                                        : 'עסק לא ידוע';
                                final isCollected = _collectedIds.contains(donation.id);
                                final currentIdx = _currentStopIndex;
                                final isCurrent = index == currentIdx;

                                return _buildTimelineItem(
                                  isFirst: isFirst,
                                  isLast: isLast,
                                  isCollected: isCollected,
                                  pinColor: isCollected
                                      ? Colors.grey.shade400
                                      : isCurrent
                                          ? const Color(0xFFD32F2F)
                                          : HomepageTheme.latetBlue,
                                  pinIcon: isCollected
                                      ? Icons.check_rounded
                                      : isCurrent
                                          ? Icons.my_location_rounded
                                          : Icons.location_on_rounded,
                                  label: "תחנה ${index + 1}",
                                  title: businessName,
                                  subtitle: donation.businessAddress.name,
                                  onTap: () => _showStopOptions(
                                      context, donation, businessName,
                                      isCollected: isCollected),
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
    bool isCollected = false,
    String? destinationHint,
  }) {
    const lineColor = Color(0xFFB0C4DE);
    const pinSize = 46.0;
    final titleColor = isCollected ? Colors.grey.shade400 : HomepageTheme.latetBlue;
    final cardColor = isCollected ? Colors.grey.shade50 : Colors.white;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // תוכן התחנה (צד שמאל)
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Opacity(
              opacity: isCollected ? 0.72 : 1.0,
              child: Container(
                margin: const EdgeInsets.only(right: 10, bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isCollected ? 0.03 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCollected) ...[
                          Icon(Icons.check_circle, size: 13, color: Colors.green.shade400),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: pinColor,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Assistant',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Assistant',
                        color: titleColor,
                        decoration: isCollected ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey.shade400,
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
                              destinationHint ?? (isCollected ? 'נווט לבית העסק' : 'לחץ לאפשרויות'),
                              style: TextStyle(
                                fontSize: 11,
                                color: destinationHint != null
                                    ? Colors.green.shade500
                                    : isCollected
                                        ? Colors.grey.shade400
                                        : pinColor.withOpacity(0.6),
                                fontFamily: 'Assistant',
                              ),
                            ),
                            Icon(
                              destinationHint != null
                                  ? Icons.flag_outlined
                                  : isCollected
                                      ? Icons.navigation_outlined
                                      : Icons.chevron_left,
                              size: 14,
                              color: destinationHint != null
                                  ? Colors.green.shade500
                                  : isCollected
                                      ? Colors.grey.shade400
                                      : pinColor.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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
