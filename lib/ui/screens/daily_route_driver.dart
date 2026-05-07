import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../widgets/custom_popup_dialog.dart';
import 'driver_pickup.dart';

const Map<int, String> _weekdayToHebrew = {
  7: 'ראשון',
  1: 'שני',
  2: 'שלישי',
  3: 'רביעי',
  4: 'חמישי',
};

// Layout constants
const double _kCircleR    = 30.0;   // circle radius (60px diameter)
const double _kEdgeOff    = 10.0;   // gap between circle edge and content edge
const double _kCardGap    = 10.0;   // gap between circle and card
const double _kEdgePad    = 14.0;   // card outer edge padding
const double _kSlotH      = 72.0;   // vertical slot per stop (circle zone)
const double _kConnH      = 80.0;   // vertical space between stops (curve zone)
const double _kCardW      = 140.0;  // fixed card width
const double _kTopPad     = 20.0;
const double _kBotPad     = 36.0;

// distance from the edge of the Stack to the near side of the card
// = 2*r + edgeOff + cardGap = 60 + 10 + 10 = 80
const double _kCardInset  = 2 * _kCircleR + _kEdgeOff + _kCardGap;

class DailyRouteDriverPage extends StatefulWidget {
  const DailyRouteDriverPage({super.key});

  @override
  State<DailyRouteDriverPage> createState() => _DailyRouteDriverPageState();
}

class _DailyRouteDriverPageState extends State<DailyRouteDriverPage> {
  final DonationService _donationService = DonationService();
  final DriverService _driverService = DriverService();
  final RouteOptimizationService _optimizationService = RouteOptimizationService();
  final ScrollController _scrollController = ScrollController();

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

  int get _itemCount => donations.length + (_todayDestination != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _loadDriverRoute();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToCurrentStop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final int cur = _currentStopIndex;
      // If all collected, scroll to destination (display index 0, top)
      final int displayIdx = cur < 0 ? 0 : _itemCount - 1 - cur;
      final double circleCenterY =
          _kTopPad + displayIdx * (_kSlotH + _kConnH) + _kSlotH / 2;
      final double viewportH = _scrollController.position.viewportDimension;
      // Position the stop at ~65% from the top of the viewport
      final double target =
          (circleCenterY - viewportH * 0.65).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  String get _collectedIdsKey {
    final today = DateTime.now();
    return 'collected_stops_${today.year}_${today.month}_${today.day}';
  }

  String get _collectedDataKey {
    final today = DateTime.now();
    return 'collected_donations_${today.year}_${today.month}_${today.day}';
  }

  // Returns collected donations saved from previous sessions today.
  // Also fills _collectedIds.
  Future<List<DonationModel>> _loadPersistedCollectedDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_collectedIdsKey) ?? [];
    final dataList = prefs.getStringList(_collectedDataKey) ?? [];
    if (mounted) setState(() => _collectedIds.addAll(ids));
    return dataList
        .map((s) {
          try {
            return DonationModel.fromApi(
                Map<String, dynamic>.from(jsonDecode(s) as Map));
          } catch (_) {
            return null;
          }
        })
        .whereType<DonationModel>()
        .toList();
  }

  Future<void> _persistCollectedDonation(DonationModel donation) async {
    final prefs = await SharedPreferences.getInstance();
    // persist ID
    final ids = prefs.getStringList(_collectedIdsKey) ?? [];
    if (!ids.contains(donation.id)) {
      ids.add(donation.id);
      await prefs.setStringList(_collectedIdsKey, ids);
    }
    // persist full data (deduplicated by id)
    final dataList = prefs.getStringList(_collectedDataKey) ?? [];
    final alreadySaved = dataList.any((s) {
      try {
        return (jsonDecode(s) as Map)['id'] == donation.id;
      } catch (_) {
        return false;
      }
    });
    if (!alreadySaved) {
      dataList.add(jsonEncode(donation.toJson()));
      await prefs.setStringList(_collectedDataKey, dataList);
    }
  }

  Future<void> _clearPersistedCollectedData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_collectedIdsKey),
      prefs.remove(_collectedDataKey),
    ]);
  }

  Future<void> _loadDriverRoute() async {
    try {
      setState(() => isLoading = true);
      final results = await Future.wait([
        _donationService.getDriverDonationsById(),
        _driverService.getMyDriverProfile(),
        _loadPersistedCollectedDonations(),
      ]);
      final fetchedDonations = results[0] as List<DonationModel>;
      final driverProfile = results[1] as DriverProfile;
      final persistedCollected = results[2] as List<DonationModel>;

      // Merge: add persisted collected donations that the API no longer returns
      final fetchedIds = fetchedDonations.map((d) => d.id).toSet();
      final missingCollected = persistedCollected
          .where((d) => !fetchedIds.contains(d.id))
          .toList();

      final todayHebrew = _weekdayToHebrew[DateTime.now().weekday];
      final todayDest = todayHebrew != null
          ? driverProfile.destinations
              .cast<DestinationModel?>()
              .firstWhere((d) => d?.day == todayHebrew, orElse: () => null)
          : null;

      setState(() {
        // Collected stops go at the front so they appear at the bottom of
        // the visual route (route is displayed bottom-first).
        donations = [...missingCollected, ...fetchedDonations];
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
      _scrollToBottom();
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

  void _showStopOptions(BuildContext context, DonationModel donation, String businessName,
      {bool isCollected = false}) {
    showDialog(
      context: context,
      builder: (_) => CustomPopupDialog(
        title: businessName,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              donation.businessAddress.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Assistant',
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
            if (isCollected) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade500, size: 15),
                  const SizedBox(width: 4),
                  Text('נאסף',
                      style: TextStyle(
                          fontFamily: 'Assistant',
                          color: Colors.green.shade600,
                          fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
        buttonText: isCollected ? 'נווט לבית העסק' : 'איסוף תרומה',
        cancelText: isCollected ? null : 'נווט',
        onConfirm: isCollected
            ? () {
                Navigator.of(context).pop();
                _navigateWithWaze(
                    donation.businessAddress.lat, donation.businessAddress.lng);
              }
            : () async {
                Navigator.of(context).pop();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DriverPickupPage(donationId: donation.id)),
                );
                if (result == true && mounted) {
                  setState(() => _collectedIds.add(donation.id));
                  await _persistCollectedDonation(donation);
                  _scrollToCurrentStop();
                }
              },
        onCancel: isCollected
            ? null
            : () => _navigateWithWaze(
                donation.businessAddress.lat, donation.businessAddress.lng),
      ),
    );
  }

  void _showDestinationOptions(DestinationModel destination) {
    showDialog(
      context: context,
      builder: (_) => CustomPopupDialog(
        title: destination.name.isNotEmpty ? destination.name : 'יעד סיום',
        content: Text(
          destination.address.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Assistant',
            fontSize: 13,
            color: Color(0xFF555555),
            height: 1.5,
          ),
        ),
        buttonText: 'אשר פריקה',
        cancelText: 'נווט ליעד',
        onConfirm: () {
          Navigator.of(context).pop();
          _confirmUnloading();
        },
        onCancel: () =>
            _navigateWithWaze(destination.address.lat, destination.address.lng),
      ),
    );
  }

  void _confirmUnloading() {
    showDialog(
      context: context,
      builder: (_) => CustomPopupDialog(
        title: 'אישור פריקה',
        message: 'האם לאשר פריקה וסיום המסלול היומי?',
        buttonText: 'אשר',
        cancelText: 'ביטול',
        onConfirm: () async {
          Navigator.of(context).pop();
          try {
            await Future.wait([
              _driverService.clearDriverStops(),
              _clearPersistedCollectedData(),
            ]);
            if (!mounted) return;
            Navigator.pop(context);
          } catch (e) {
            _showError(
                'שגיאה באיפוס המסלול: ${e.toString().replaceFirst('Exception: ', '')}');
          }
        },
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

  // ── UI ──────────────────────────────────────────────────────────────────────

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
                    _buildHeader(),
                    Expanded(
                      child: donations.isEmpty
                          ? _buildEmpty()
                          : SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                  _kEdgePad, 4, _kEdgePad, 0),
                              child: _buildProgressMap(),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                child: Text('המסלול היומי',
                    textAlign: TextAlign.center,
                    style: ReportDonationTheme.headerStyle),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: isOptimizing
                    ? const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: HomepageTheme.latetBlue),
                        ),
                      )
                    : Tooltip(
                        message: 'חשב מסלול מחדש',
                        child: IconButton(
                          icon: Icon(Icons.refresh_rounded,
                              size: 20,
                              color: isOptimized
                                  ? Colors.green.shade500
                                  : HomepageTheme.latetBlue.withValues(alpha: 0.5)),
                          padding: EdgeInsets.zero,
                          onPressed: _optimizeRoute,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.route,
              size: 64, color: HomepageTheme.latetBlue.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          const Text('אין תרומות במסלול היום',
              style: TextStyle(
                  fontFamily: 'Assistant', fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Progress map (Stack-based) ───────────────────────────────────────────────

  Widget _buildProgressMap() {
    final int n = _itemCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;

        // Calculate circle center for each display index (top = destination, bottom = current)
        final centers = List<Offset>.generate(n, (di) {
          final bool onRight = di % 2 == 0;
          final double x = onRight ? w - _kCircleR - _kEdgeOff : _kCircleR + _kEdgeOff;
          final double y = _kTopPad + di * (_kSlotH + _kConnH) + _kSlotH / 2;
          return Offset(x, y);
        });

        final double totalH =
            _kTopPad + n * _kSlotH + (n - 1) * _kConnH + _kBotPad;

        return SizedBox(
          height: totalH,
          child: Stack(
            children: [
              // ── Winding route path ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _RouteMapPainter(centers: centers),
                ),
              ),
              // ── Stops ──
              for (int di = 0; di < n; di++) ...[
                _buildPositionedCircle(di, centers[di], w),
                _buildPositionedCard(di, centers[di], w),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Stop helpers ─────────────────────────────────────────────────────────────

  _StopData _stopData(int di) {
    final int dataIdx = _itemCount - 1 - di;
    final bool isDestination = _todayDestination != null && dataIdx == donations.length;

    if (isDestination) {
      return _StopData(
        label: 'יעד סיום',
        title: _todayDestination!.name.isNotEmpty
            ? _todayDestination!.name
            : 'יעד ${_todayDestination!.day}',
        subtitle: _todayDestination!.address.name,
        isCollected: false,
        isCurrent: false,
        isDestination: true,
        onTap: _allCollected ? () => _showDestinationOptions(_todayDestination!) : null,
      );
    }

    final donation = donations[dataIdx];
    final name =
        donation.businessName.isNotEmpty ? donation.businessName : 'עסק לא ידוע';
    final collected = _collectedIds.contains(donation.id);
    return _StopData(
      label: 'תחנה ${dataIdx + 1}',
      title: name,
      subtitle: donation.businessAddress.name,
      isCollected: collected,
      isCurrent: dataIdx == _currentStopIndex,
      isDestination: false,
      onTap: () => _showStopOptions(context, donation, name, isCollected: collected),
    );
  }

  Color _nodeColor(_StopData d) {
    if (d.isCollected) return Colors.grey.shade400;
    if (d.isCurrent) return const Color(0xFFD32F2F);
    return HomepageTheme.latetBlue;
  }

  Widget _buildPositionedCircle(int di, Offset center, double w) {
    final d = _stopData(di);
    final color = _nodeColor(d);
    final bool isRegularStop = !d.isCollected && !d.isCurrent && !d.isDestination;
    final Color circleBg = isRegularStop ? const Color(0xFFD0E8F8) : color;
    final Color circleIconColor = isRegularStop ? HomepageTheme.latetBlue : Colors.white;

    return Positioned(
      left: center.dx - _kCircleR,
      top: center.dy - _kCircleR,
      width: _kCircleR * 2,
      height: _kCircleR * 2,
      child: GestureDetector(
        onTap: d.onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleBg,
            boxShadow: [
              BoxShadow(
                color: circleBg.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              if (d.isCurrent)
                BoxShadow(
                  color: circleBg.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 6,
                ),
            ],
          ),
          child: Icon(
            d.isCollected
                ? Icons.check_rounded
                : d.isCurrent
                    ? Icons.my_location_rounded
                    : d.isDestination
                        ? Icons.flag_rounded
                        : Icons.storefront_rounded,
            color: circleIconColor,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedCard(int di, Offset center, double w) {
    final bool onRight = di % 2 == 0;
    final d = _stopData(di);
    final color = _nodeColor(d);

    // Vertically centered on the circle with a fixed card width
    return Positioned(
      top: center.dy - _kCircleR,      // align card top with circle top
      left: onRight ? null : _kCardInset,
      right: onRight ? _kCardInset : null,
      width: _kCardW,
      child: GestureDetector(
        onTap: d.onTap,
        child: Opacity(
          opacity: d.isCollected
              ? 0.72
              : (d.isDestination && d.onTap == null)
                  ? 0.5
                  : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: d.isCurrent
                    ? color.withValues(alpha: 0.35)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Label + badge row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (d.isCollected)
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Icon(Icons.check_circle_outline,
                            size: 10, color: Colors.grey.shade400),
                      ),
                    if (d.isCurrent)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('עכשיו',
                            style: TextStyle(
                              fontSize: 9,
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Assistant',
                            )),
                      ),
                    Text(d.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Assistant',
                        )),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  d.title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Assistant',
                    color: d.isCollected
                        ? Colors.grey.shade400
                        : HomepageTheme.latetBlue,
                    decoration:
                        d.isCollected ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey.shade400,
                  ),
                ),
                if (d.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          d.subtitle,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontFamily: 'Assistant'),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.location_on_outlined,
                          size: 10, color: Colors.grey),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _StopData {
  final String label, title, subtitle;
  final bool isCollected, isCurrent, isDestination;
  final VoidCallback? onTap;

  const _StopData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.isCollected,
    required this.isCurrent,
    required this.isDestination,
    required this.onTap,
  });
}

// ── Custom painter — single smooth path through all circle centers ─────────────

class _RouteMapPainter extends CustomPainter {
  final List<Offset> centers;

  const _RouteMapPainter({required this.centers});

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFD0E8F8)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Build one smooth cubic-bezier path through all centers
    final path = Path()..moveTo(centers[0].dx, centers[0].dy);

    for (int i = 0; i < centers.length - 1; i++) {
      final from = centers[i];
      final to = centers[i + 1];
      final dy = to.dy - from.dy;
      path.cubicTo(
        from.dx, from.dy + dy * 0.5,
        to.dx,   to.dy   - dy * 0.5,
        to.dx,   to.dy,
      );
    }

    // Draw dashed
    const double dash = 10;
    const double gap  = 7;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      bool draw = true;
      while (dist < metric.length) {
        final len = draw ? dash : gap;
        if (draw) {
          canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        }
        dist += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_RouteMapPainter old) => old.centers != centers;
}
