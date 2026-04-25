
import 'dart:convert';

import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_popup_dialog.dart';
import '../../data/models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../data/models/product_model.dart';

class DriverPickupPage extends StatefulWidget {
  final String donationId;
  const DriverPickupPage({super.key, required this.donationId});

  @override
  State<DriverPickupPage> createState() => _DriverPickupPageState();
}

class _DriverPickupPageState extends State<DriverPickupPage> {
  final DonationService _donationService = DonationService();

  final businessNameController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final businessAddressController = TextEditingController();
  final crnController = TextEditingController();

  final Map<String, TextEditingController> otherDescriptionControllers = {};

  DonationModel? donation;
  bool isLoading = true;
  bool _isSubmitting = false;

  Map<String, int> collectedQuantities = {};
  Map<String, bool?> productStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDonationData();
  }

  @override
  void dispose() {
    for (var controller in otherDescriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDonationData() async {
    try {
      setState(() => isLoading = true);
      final currentDonation = await _donationService.getDonationById(widget.donationId);
      setState(() {
        donation = currentDonation;
        businessNameController.text = currentDonation.businessName;
        businessPhoneController.text = currentDonation.businessPhone;
        businessAddressController.text = currentDonation.businessAddress.name;
        crnController.text = currentDonation.crn;

        for (var item in donation!.products) {
          collectedQuantities[item.id] = item.quantity;
          productStatus[item.id] = null;

          if (item.type.name == "אחר") {
            otherDescriptionControllers[item.id] =
                TextEditingController(text: item.type.description ?? "");
          }
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("🔴 Error loading donation details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitPickup() async {
    bool allSelected = productStatus.values.every((status) => status != null);
    if (!allSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("יש לסמן אישור או ביטול לכל המוצרים"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      List<Map<String, dynamic>> productsToUpdate = donation!.products.map((item) {
        bool isOther = item.type.name == "אחר";
        return {
          "productId": item.id,
          "productTypeId": item.type.id,
          "isOther": isOther,
          "collectedQuantity": collectedQuantities[item.id],
          "isPickedUp": productStatus[item.id],
          "newDescription": isOther ? otherDescriptionControllers[item.id]?.text : null,
        };
      }).toList();

      print("🚀 Sending to Server: ${json.encode(productsToUpdate)}");

      await _donationService.submitPickup(
        donationId: widget.donationId,
        donorId: donation!.donorId,
        products: productsToUpdate,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "האיסוף נשמר",
          message: "נתוני האיסוף עודכנו בהצלחה",
          buttonText: "מעולה",
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("שגיאה: $e")));
      }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: HomepageTheme.latetBlue, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text("איסוף תרומה",
                          textAlign: TextAlign.center,
                          style: ReportDonationTheme.headerStyle),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    "פרטי התחנה",
                    style: TextStyle(
                      color: HomepageTheme.latetBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Assistant',
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                _buildCard(
                  title: "פרטי העסק",
                  child: Column(
                    children: [
                      _buildReadOnlyField("שם העסק", businessNameController),
                      _buildReadOnlyField("פלאפון עסק", businessPhoneController),
                      _buildReadOnlyField("כתובת עסק", businessAddressController),
                      _buildReadOnlyField('ח"פ / עוסק מורשה', crnController),
                    ],
                  ),
                ),

                _buildCard(
                  title: "מוצרים לאיסוף",
                  child: Column(
                    children: donation!.products.map(_buildProductRow).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPickup,
                    style: ReportDonationTheme.simpleButton,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "אשר איסוף תרומה",
                            style: TextStyle(fontSize: 18, fontFamily: 'Assistant'),
                          ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(title, style: ReportDonationTheme.labelStyle),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          readOnly: true,
          textAlign: TextAlign.right,
          decoration: ReportDonationTheme.inputDecoration(hint),
        ),
      ),
    );
  }

  Widget _buildProductRow(ProductModel item) {
    final productId = item.id;
    final currentQty = collectedQuantities[productId] ?? 0;
    final status = productStatus[productId];
    final isCancelled = status == false;
    final isApproved = status == true;
    final isOther = item.type.name == "אחר";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isCancelled
            ? Colors.grey.shade50
            : isApproved
                ? const Color(0xFFEBF3FF)
                : const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved
              ? HomepageTheme.latetBlue.withValues(alpha: 0.4)
              : isCancelled
                  ? Colors.grey.shade300
                  : HomepageTheme.latetBlue.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // שם המוצר או שדה עריכה לסוג "אחר"
          if (isOther)
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                controller: otherDescriptionControllers[productId],
                enabled: !isCancelled,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Assistant',
                  color: isCancelled ? Colors.grey : HomepageTheme.latetBlue,
                ),
                decoration: ReportDonationTheme.inputDecoration("תאר את המוצר...").copyWith(
                  fillColor: isCancelled ? Colors.grey.shade100 : Colors.white,
                  suffixIcon: isCancelled
                      ? null
                      : const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.edit_outlined, size: 18, color: HomepageTheme.latetBlue),
                        ),
                ),
              ),
            )
          else
            Text(
              item.type.name,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Assistant',
                color: isCancelled ? Colors.grey : HomepageTheme.latetBlue,
                decoration: isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),

          const SizedBox(height: 12),

          // שורה תחתונה: בורר כמות + כפתורי אשר/בטל
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // כפתורי אשר / בטל
              Row(
                children: [
                  _buildChoiceButton(
                    "בטל",
                    isCancelled ? const Color(0xFF78909C) : Colors.grey.shade200,
                    isCancelled ? Colors.white : Colors.black54,
                    () => setState(() => productStatus[productId] = false),
                  ),
                  const SizedBox(width: 8),
                  _buildChoiceButton(
                    "אשר",
                    isApproved ? HomepageTheme.latetBlue : Colors.grey.shade200,
                    isApproved ? Colors.white : Colors.black54,
                    () => setState(() => productStatus[productId] = true),
                  ),
                ],
              ),

              // בורר כמות
              Opacity(
                opacity: isCancelled ? 0.3 : 1.0,
                child: AbsorbPointer(
                  absorbing: isCancelled,
                  child: Row(
                    children: [
                      _buildQtyButton(
                        Icons.remove_circle_outline,
                        () {
                          if (currentQty > 1) setState(() => collectedQuantities[productId] = currentQty - 1);
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$currentQty",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: HomepageTheme.latetBlue,
                          fontFamily: 'Assistant',
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildQtyButton(
                        Icons.add_circle_outline,
                        () => setState(() => collectedQuantities[productId] = currentQty + 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Icon(icon, size: 26, color: HomepageTheme.latetBlue),
    );
  }

  Widget _buildChoiceButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Assistant',
          ),
        ),
      ),
    );
  }
}
