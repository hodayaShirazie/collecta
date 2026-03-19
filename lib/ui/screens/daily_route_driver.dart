import 'package:flutter/material.dart';
import '../../services/donation_service.dart';
import '../../services/donor_service.dart'; // ייבוא הסרוויס של התורמים
import '../../data/models/donation_model.dart';
import '../../data/models/donor_model.dart';
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

  List<DonationModel> donations = [];
  // מפה שתשמור את שמות העסקים לפי donorId כדי שלא נשלוף פעמיים אותו תורם
  Map<String, String> donorNames = {}; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriverRoute();
  }

  Future<void> _loadDriverRoute() async {
    try {
      setState(() => isLoading = true);

      // 1. שליפת רשימת התרומות של הנהג
      final List<DonationModel> fetchedDonations = await _donationService.getDriverDonationsById();

      // 2. עבור כל תרומה, נשלוף את שם העסק של התורם אם הוא עוד לא אצלנו
      for (var donation in fetchedDonations) {
        if (!donorNames.containsKey(donation.donorId)) {
          try {
            // כאן אנחנו משתמשים ב-donorId שנמצא בתוך ה-DonationModel
            // את צריכה לוודא שיש לך פונקציה שמקבלת ID ספציפי (ולא רק את המחובר)
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
      });
    } catch (e) {
      debugPrint("🔴 Error loading route: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('המסלול היומי שלי', style: TextStyle(fontFamily: 'Assistant')),
        backgroundColor: HomepageTheme.latetBlue,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
        child: isLoading
            ? const LoadingIndicator()
            : donations.isEmpty
                ? const Center(child: Text("אין תרומות במסלול היום"))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final donation = donations[index];
                      // שליפת שם העסק מהמפה שבנינו
                      final businessName = donorNames[donation.donorId] ?? "טוען...";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: HomepageTheme.latetBlue,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverPickupPage(donationId: donation.id),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_back_ios, size: 16),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "תחנה ${index + 1}: $businessName",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Text(
                                    donation.businessAddress.name,
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              const Icon(Icons.location_on, color: HomepageTheme.latetBlue),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}