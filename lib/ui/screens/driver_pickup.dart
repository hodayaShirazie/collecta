import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_popup_dialog.dart';
import '../../data/models/donation_model.dart'; 
import '../../services/donation_service.dart';

class DriverPickupPage extends StatefulWidget {
  final String donationId;
  const DriverPickupPage({super.key, required this.donationId});

  @override
  State<DriverPickupPage> createState() => _DriverPickupPageState();
}

class _DriverPickupPageState extends State<DriverPickupPage> {
  final DonationService _donationService = DonationService();
  
  final businessName = TextEditingController();
  final businessPhone = TextEditingController();
  final businessAddress = TextEditingController();
  final businessId = TextEditingController();

  DonationModel? donation; // כאן השתמשנו ב-? כי הוא מתחיל כ-null
  bool isLoading = true;
  Map<String, int> collectedQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadDonationData();
  }

  Future<void> _loadDonationData() async {
    try {
      // תיקון השגיאה: מקבלים רשימה ולוקחים את הראשון
      final List<DonationModel> results = await _donationService.getDriverDonationsById();
      
      if (results.isNotEmpty) {
        setState(() {
          donation = results.first; // השמה תקינה של איבר ראשון
          
          // businessName.text = donation!.businessName;
          businessPhone.text = donation!.contactPhone;
          businessAddress.text = donation!.businessAddress.name;
          businessId.text = donation!.id;

          for (var item in donation!.products) {
            collectedQuantities[item.type.id] = item.quantity;
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading donation details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitPickup() async {
    try {
      // כאן תקראי ל-Function של עדכון האיסוף כשתהיה מוכנה
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "איסוף הושלם",
          message: "נתוני האיסוף עודכנו בהצלחה",
          buttonText: "מעולה",
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: LoadingIndicator());
    if (donation == null) return const Scaffold(body: Center(child: Text("תרומה לא נמצאה")));

    return Scaffold(
      body: LayoutWrapper(
        child: Container(
          decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("איסוף תרומה", style: ReportDonationTheme.headerStyle),
                  const Text("פרטי התחנה", style: TextStyle(color: HomepageTheme.latetBlue, fontSize: 18)),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ReportDonationTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildReadOnlyField("שם העסק:", businessName),
                        _buildReadOnlyField("פלאפון:", businessPhone),
                        _buildReadOnlyField("כתובת:", businessAddress),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerRight, child: Text("עדכון כמויות שנאספו:", style: ReportDonationTheme.labelStyle)),
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: ReportDonationTheme.cardDecoration,
                    child: Column(
                      children: donation!.products.map((product) {
                        return _buildProductRow(product.type.name, product.type.id);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPickup,
                      style: ReportDonationTheme.simpleButton,
                      child: const Text("אשר איסוף", style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(String label, String productId) {
    int currentQty = collectedQuantities[productId] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildActionButton("אישור", Colors.green),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                Column(
                  children: [
                    InkWell(onTap: () => setState(() => collectedQuantities[productId] = currentQty + 1), child: const Icon(Icons.arrow_drop_up, size: 20)),
                    InkWell(onTap: () => setState(() { if (currentQty > 0) collectedQuantities[productId] = currentQty - 1; }), child: const Icon(Icons.arrow_drop_down, size: 20)),
                  ],
                ),
                const SizedBox(width: 8),
                Text("$currentQty", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text("$label:", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HomepageTheme.latetBlue)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: ReportDonationTheme.labelStyle),
          TextField(controller: controller, readOnly: true, textAlign: TextAlign.right, decoration: ReportDonationTheme.inputDecoration("")),
        ],
      ),
    );
  }
}