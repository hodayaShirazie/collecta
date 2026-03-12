import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';

import '../widgets/layout_wrapper.dart';
// import '../widgets/submit_button.dart';
import '../widgets/donation_widgets/card.dart';
import '../widgets/donation_widgets/input_field.dart';
import '../widgets/donation_widgets/section_title.dart';
import '../widgets/donation_widgets/quantity_dialog.dart';
import '../widgets/donation_widgets/donated_item_tile.dart';
import '../widgets/donation_widgets/address_field.dart';
import '../widgets/donation_widgets/product_chip.dart';
import '../widgets/donation_widgets/products_card.dart';
import '../widgets/donation_widgets/time_slots_card.dart';
import '../widgets/personal_details/business_details_card.dart';
import '../widgets/personal_details/contact_details_card.dart';

import '../utils/validators/phone_validator.dart';
import '../utils/validators/business_id_validator.dart';

import '../../services/donation_flow_service.dart';
import '../../services/places_service.dart';

import '../../data/models/place_prediction.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class ReportDonation extends StatefulWidget {
  const ReportDonation({super.key});

  @override
  State<ReportDonation> createState() => _ReportDonationState();
}

class _ReportDonationState extends State<ReportDonation> {
  final _formKey = GlobalKey<FormState>();

  final businessName = TextEditingController();
  final address = TextEditingController();
  final businessPhone = TextEditingController();
  final businessId = TextEditingController();
  final contactName = TextEditingController();
  final contactPhone = TextEditingController();

  final List<String> selectedTimeSlots = [];
  final List<String> selectedProducts = [];

  final List<Map<String, dynamic>> products = [
    {"name": "מאפים", "id": dotenv.env['PRODUCT_BAKERY_ID'], "icon": "assets/images/category_icons/croissant.png"},
    {"name": "עוגות", "id": dotenv.env['PRODUCT_CAKE_ID'], "icon": "assets/images/category_icons/cake.png"},
    {"name": "פירות וירקות", "id": dotenv.env['PRODUCT_FRUITS_ID'], "icon": "assets/images/category_icons/carrot.png"},
    {"name": "מוצרי חלב", "id": dotenv.env['PRODUCT_DAIRY_ID'], "icon": "assets/images/category_icons/milk.png"},
    {"name": "היגיינה", "id": dotenv.env['PRODUCT_HYGIENE_ID'], "icon": "assets/images/category_icons/hygiene.png"},
    {"name": "מוצרי יסוד", "id": dotenv.env['PRODUCT_BASIC_ID'], "icon": "assets/images/category_icons/box.png"},
    {"name": "אחר", "id": dotenv.env['PRODUCT_OTHER_ID'], "icon": "assets/images/category_icons/more.png"},
  ];

  final List<String> timeSlots = ["8:00-10:00", "10:00-12:00", "12:00-14:00"];

  final List<Map<String, dynamic>> donatedItems = [];

  double? selectedLat;
  double? selectedLng;


  void toggleTime(String slot) {
    setState(() {
      selectedTimeSlots.contains(slot)
          ? selectedTimeSlots.remove(slot)
          : selectedTimeSlots.add(slot);
    });
  }
  
  void _editDonatedItem(int index) {
    Map<String, dynamic> item = donatedItems[index];
    String name = item["name"] ?? "";
    String quantity = item["quantity"] ?? "";
    String unit = item["unit"] ?? "";

    if (name.startsWith("אחר")) {
      final TextEditingController otherController =
          TextEditingController(text: name.replaceFirst("אחר: ", ""));
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Text(
              "פרט פריט לתרומה",
              style: TextStyle(color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: TextFormField(
              controller: otherController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "תיאור הפריט",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: HomepageTheme.latetBlue, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: HomepageTheme.latetBlue, width: 2),
                ),
              ),
              textAlign: TextAlign.right,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (otherController.text.isNotEmpty) {
                      donatedItems[index] = {
                        "name": "אחר: ${otherController.text}",
                        "productTypeId": null,
                        "quantity": "",
                        "unit": ""
                      };
                    }
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: HomepageTheme.latetBlue, width: 1.5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "אשר",
                    style: TextStyle(color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {

      int currentQuantity = int.tryParse(quantity) ?? 1;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Text(
              "ערוך כמות",
              style: TextStyle(color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (currentQuantity > 1) setStateDialog(() => currentQuantity--);
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      currentQuantity.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => setStateDialog(() => currentQuantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                );
              },
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    donatedItems[index] = {
                      "name": name,
                      "quantity": currentQuantity.toString(),
                      "unit": unit
                    };
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: HomepageTheme.latetBlue, width: 1.5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "אשר",
                    style: TextStyle(color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void toggleProduct(Map<String, dynamic> product) async {
    final name = product["name"];
    final id = product["id"];

    if (selectedProducts.contains(name)) {
      selectedProducts.remove(name);
    } else {
      selectedProducts.add(name);

      if (name == "אחר") {
        _showOtherDialog(); 
      } else {
        final result = await showQuantityDialog(context: context, productName: name, productId: id);
        if (result != null) {
          donatedItems.add(result);
          setState(() {});
        }
      }
    }
  }

  void _showOtherDialog() {
    final TextEditingController otherController = TextEditingController();
    int quantity = 1;

    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        title: Text(
          "פרט פריט לתרומה",
          style: TextStyle(
              color: HomepageTheme.latetBlue,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 🔢 כמות
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setStateDialog(() => quantity--);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        setStateDialog(() => quantity++);
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 📝 תיאור
                TextFormField(
                  controller: otherController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "תיאור הפריט",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: HomepageTheme.latetBlue,
                          width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: HomepageTheme.latetBlue,
                          width: 2),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            );
          },
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (otherController.text.isNotEmpty) {
                  donatedItems.add({
                    "name": "אחר: ${otherController.text}",
                    "productTypeId": null,
                    "quantity": quantity.toString(),
                    "unit": "קג/יחידות"
                  });
                }
                Navigator.pop(context);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: HomepageTheme.latetBlue,
                    width: 1.5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "אשר",
                style: TextStyle(
                    color: HomepageTheme.latetBlue,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    },
    );
  }

  bool _validateBeforeSubmit() {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid) {
      return false;
    }

    // 2️⃣ בדיקת חלונות זמן
    if (selectedTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("יש לבחור לפחות חלון זמן אחד"),
        ),
      );
      return false;
    }

    // 3️⃣ בדיקת מוצרים
    if (donatedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("יש להוסיף לפחות מוצר אחד לתרומה"),
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> submit() async {
    if (!_validateBeforeSubmit()) {
      return false;
    }

    try {
      await DonationFlowService().submitDonation(
        businessName: businessName.text,
        businessPhone: businessPhone.text,
        contactName: contactName.text,
        contactPhone: contactPhone.text,
        businessId: businessId.text,
        donatedItems: donatedItems,
        selectedTimeSlots: selectedTimeSlots,
        lat: selectedLat,
        lng: selectedLng,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("💙 התרומה נשלחה בהצלחה")),
      );
      return true; 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      return false; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutWrapper(
        child: Container(
          decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: HomepageTheme.topPadding),
                  const Text("דיווח תרומה", style: ReportDonationTheme.headerStyle),
                  const SizedBox(height: 35),

                  // ===================== FORM =====================
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        BusinessDetailsCard(
                          businessName: businessName,
                          address: address,
                          businessPhone: businessPhone,
                          businessId: businessId,
                          onLocationSelected: (lat, lng) {
                            setState(() {
                              selectedLat = lat;
                              selectedLng = lng;
                            });
                          },
                        ),
                        ContactDetailsCard(
                          contactName: contactName,
                          contactPhone: contactPhone,
                        ),
                        TimeSlotsCard(
                          timeSlots: timeSlots,
                          selectedTimeSlots: selectedTimeSlots,
                          toggleTime: toggleTime,
                        ),
                        ProductsCard(
                          products: products,
                          selectedProducts: selectedProducts,
                          toggleProduct: toggleProduct,
                        ),
                        const SizedBox(height: 30),

                        // ================== Donated Items ==================
                        if (donatedItems.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 25),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "פריטים שנוספו",
                                  textAlign: TextAlign.right,
                                  style: ReportDonationTheme.labelStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: HomepageTheme.latetBlue,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: donatedItems.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Map<String, dynamic> item = entry.value;
                                    return DonatedItemTile(
                                      item: item,
                                      onEdit: () => _editDonatedItem(index),
                                      onDelete: () {
                                        setState(() {
                                          donatedItems.removeAt(index);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                        // ================== Submit Button ==================
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 140,
                            child: ElevatedButton(
                              onPressed: submit,
                              style: ReportDonationTheme.simpleButton,
                              child: const Text("אשר תרומה"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ), // END FORM
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
