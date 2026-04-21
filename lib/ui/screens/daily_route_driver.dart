import 'package:flutter/material.dart';
import '../../services/donation_service.dart';
import '../../services/donor_service.dart';
import '../../services/route_optimization_service.dart';
import '../../data/models/donation_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/loading_indicator.dart';
import 'driver_pickup.dart';

class DailyRouteDriverPage extends StatefulWidget {
  const DailyRouteDriverPage({super.key});

  @override
  State<DailyRouteDriverPage> createState() => _DailyRouteDriverPageState();
}

class _DailyRouteDriverPageState extends State<DailyRouteDriverPage> {
  final DonationService _donationService = DonationService();
  final DonorService _donorService = DonorService();
  final RouteOptimizationService _optimizationService = RouteOptimizationService();

  List<DonationModel> donations = [];
  Map<String, String> donorNames = {};
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

      final List<DonationModel> fetchedDonations =
          await _donationService.getDriverDonationsById();

      for (var donation in fetchedDonations) {
        if (!donorNames.containsKey(donation.donorId)) {
          try {
            final profile = await _donorService.getMyDonorProfile();
            donorNames[donation.donorId] = profile.businessName;
          } catch (e) {
            donorNames[donation.donorId] = "עסק לא ידוע";
          }
        }
      }

      setState(() {
        donations = fetchedDonations;
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
      final optimized = await _optimizationService.optimizeDonationRoute(donations);
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.red,
      ),
    );
  }

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
                            itemCount: donations.length,
                            itemBuilder: (context, index) {
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DriverPickupPage(
                                            donationId: donation.id),
                                      ),
                                    );
                                  },
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
}
