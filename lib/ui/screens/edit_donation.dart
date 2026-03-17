
import 'package:flutter/material.dart';

import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';

import '../widgets/layout_wrapper.dart';
import '../widgets/donation_widgets/donation_form.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_popup_dialog.dart'; 

import '../utils/donation/donation_toggle_product_helper.dart';
import '../utils/donation/donation_edit_helper.dart';
import '../utils/donation/donation_constants.dart';
import '../utils/donation/donation_category_helper.dart'; 

import '../../services/donation_service.dart';
import '../../services/donor_service.dart';

import '../../data/models/donation_model.dart';

class EditDonation extends StatefulWidget {
  final String donationId;

  const EditDonation({super.key, required this.donationId});

  @override
  State<EditDonation> createState() => _EditDonationState();
}

class _EditDonationState extends State<EditDonation> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController businessNameCtrl = TextEditingController();
  late TextEditingController addressCtrl = TextEditingController();
  late TextEditingController businessPhoneCtrl = TextEditingController();
  late TextEditingController businessIdCtrl = TextEditingController();
  late TextEditingController contactNameCtrl = TextEditingController();
  late TextEditingController contactPhoneCtrl = TextEditingController();

  List<String> selectedTimeSlots = [];
  List<String> selectedProducts = [];
  List<Map<String, dynamic>> donatedItems = [];

  double? selectedLat;
  double? selectedLng;

  bool isLoading = true;

  DonationModel? currentDonation;

  @override
  void initState() {
    super.initState();
    _loadDonation();
  }

  Future<void> _loadDonation() async {
    try {
      final donation = await DonationService().getDonationById(widget.donationId);
      currentDonation = donation;

      final donor = await DonorService().getMyDonorProfile();


      businessNameCtrl.text = donor.businessName;
      addressCtrl.text = donation.businessAddress.name;
      businessPhoneCtrl.text = donor.businessPhone;
      businessIdCtrl.text = donor.crn;
      contactNameCtrl.text = donation.contactName ?? '';
      contactPhoneCtrl.text = donation.contactPhone ?? '';

      selectedLat = donor.businessAddress.lat;
      selectedLng = donor.businessAddress.lng;


      selectedTimeSlots = donation.pickupTimes.map((e) => "${e.from}-${e.to}").toList();


      donatedItems = (donation.products ?? []).map<Map<String, dynamic>>((p) {
      final typeName = p.type?.name ?? 'ש';
      final quantity = p.quantity;

      return <String, dynamic>{
        "id": p.type?.id ?? '',
        "name": typeName,
        "icon": '',
        "quantity": quantity.toString(),
        "unit": 'ק"ג/יחידות',
        "display": "$typeName",
      };
    }).toList();

      selectedProducts = donatedItems.map((e) => e["name"] as String).toList();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading donation: $e");

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleTime(String slot) {
    setState(() {
      if (selectedTimeSlots.contains(slot)) {
        selectedTimeSlots.remove(slot);
      } else {
        selectedTimeSlots.add(slot);
      }
    });
  }

  Future<void> toggleProduct(Map<String, dynamic> product) async {
  final safeProduct = Map<String, dynamic>.from(product);

  await DonationToggleProductHelper.toggleProduct(
    context: context,
    product: safeProduct,
    selectedProducts: selectedProducts,
    donatedItems: donatedItems,
    refresh: () => setState(() {}),
  );
}

  Future<void> editItem(int index) async {
    await DonationEditHelper.editDonatedItem(
      context: context,
      index: index,
      donatedItems: donatedItems,
      refresh: () => setState(() {}),
    );
  }

  void deleteItem(int index) {
    setState(() {
      donatedItems.removeAt(index);
    });
  }

  void onLocationSelected(double lat, double lng) {
    setState(() {
      selectedLat = lat;
      selectedLng = lng;
    });
  }

  // Future<void> submit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   if (selectedTimeSlots.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("יש לבחור לפחות חלון זמן אחד")),
  //     );
  //     return;
  //   }

  //   if (donatedItems.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("יש להוסיף לפחות מוצר אחד לתרומה")),
  //     );
  //     return;
  //   }

  //   // final updatedDonation = currentDonation!.copyWith(
  //   //   contactName: contactNameCtrl.text,
  //   //   contactPhone: contactPhoneCtrl.text,
  //   // );

  //   // try {
  //   //   await DonationService().updateDonation(
  //   //     donationId: widget.donationId,
  //   //     businessName: businessNameCtrl.text,
  //   //     businessPhone: businessPhoneCtrl.text,
  //   //     contactName: contactNameCtrl.text,
  //   //     contactPhone: contactPhoneCtrl.text,
  //   //     businessId: businessIdCtrl.text,
  //   //     donatedItems: donatedItems,
  //   //     selectedTimeSlots: selectedTimeSlots,
  //   //     lat: selectedLat,
  //   //     lng: selectedLng,
  //   //   );

    


  //     await showDialog(
  //       context: context,
  //       builder: (context) => const CustomPopupDialog(
  //         title: "תודה על תרומתך!",
  //         message: "התרומה עודכנה בהצלחה",
  //         buttonText: "סגור",
  //       ),
  //     );
  //     Navigator.pop(context); // חזרה למסך הקודם
  //   // } catch (e) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     SnackBar(content: Text("Error: $e")),
  //   //   );
  //   // }
  // }

  Future<void> submit() async {
  if (!_formKey.currentState!.validate()) return;

  // בדיקת חלונות זמן
  if (selectedTimeSlots.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("יש לבחור לפחות חלון זמן אחד")),
    );
    return;
  }

  // בדיקת מוצרים
  if (donatedItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("יש להוסיף לפחות מוצר אחד לתרומה")),
    );
    return;
  }

  try {
    // יצירת ה-body שנשלח ל-API
    final body = <String, dynamic>{
      "donationId": widget.donationId, // חובה!
    };

    // מוסיפים רק אם יש ערך
    if (businessNameCtrl.text.isNotEmpty) body["businessName"] = businessNameCtrl.text;
    if (businessPhoneCtrl.text.isNotEmpty) body["businessPhone"] = businessPhoneCtrl.text;
    if (businessIdCtrl.text.isNotEmpty) body["businessId"] = businessIdCtrl.text;
    if (contactNameCtrl.text.isNotEmpty) body["contactName"] = contactNameCtrl.text;
    if (contactPhoneCtrl.text.isNotEmpty) body["contactPhone"] = contactPhoneCtrl.text;

    body["businessAddress"] = {
      "id": currentDonation?.businessAddress.id,
      "name": addressCtrl.text,
      "lat": selectedLat ?? 0,
      "lng": selectedLng ?? 0,
    };

    body["pickupTimes"] = selectedTimeSlots.map((slot) {
      final parts = slot.split("-");
      return {"from": parts[0], "to": parts[1]};
    }).toList();

    body["products"] = donatedItems.map((item) {
      return {
        "id": item["id"] ?? '',
        "name": item["name"] ?? '',
        "quantity": int.tryParse(item["quantity"] ?? '0') ?? 0,
        "unit": item["unit"] ?? 'ק"ג/יחידות',
        "description": item["description"] ?? '',
      };
    }).toList();

    // קריאה ל-Service לעדכון התרומה
    await DonationService().updateDonation(body);

    // הודעה למשתמש
    await showDialog(
      context: context,
      builder: (context) => const CustomPopupDialog(
        title: "תודה על תרומתך!",
        message: "התרומה עודכנה בהצלחה",
        buttonText: "סגור",
      ),
    );

    Navigator.pop(context); // חזרה למסך הקודם

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}






  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: LoadingIndicator());

    return Scaffold(
      body: LayoutWrapper(
        child: Container(
          decoration: const BoxDecoration(
            gradient: HomepageTheme.pageGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: HomepageTheme.topPadding),
                  const Text(
                    "עריכת תרומה",
                    style: ReportDonationTheme.headerStyle,
                  ),
                  const SizedBox(height: 35),
                  DonationForm(
                    formKey: _formKey,
                    businessName: businessNameCtrl,
                    address: addressCtrl,
                    businessPhone: businessPhoneCtrl,
                    businessId: businessIdCtrl,
                    contactName: contactNameCtrl,
                    contactPhone: contactPhoneCtrl,
                    timeSlots: DonationConstants.timeSlots,
                    selectedTimeSlots: selectedTimeSlots,
                    toggleTime: toggleTime,
                    products: DonationConstants.products,
                    selectedProducts: selectedProducts,
                    toggleProduct: toggleProduct,
                    donatedItems: donatedItems,
                    onEditItem: editItem,
                    onDeleteItem: deleteItem,
                    onSubmit: submit,
                    buttonText: "שמור שינויים",
                    onLocationSelected: onLocationSelected,
                    buttonStyle: ReportDonationTheme.simpleButton,
                    isCategoryDisabled: (product) => DonationCategoryHelper.isCategoryDisabled(
                    product: product,
                    donatedItems: donatedItems,
                ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}