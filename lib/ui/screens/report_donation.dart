import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../../services/donation_service.dart';
import '../../data/models/donation_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'];
const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';



Future<List<Map<String, String>>> fetchPlaceSuggestions(String input) async {
  final String url =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$kGoogleApiKey&types=address&language=he';
  
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List predictions = data['predictions'];

    return predictions.map<Map<String, String>>((p) {
      return {
        "description": p['description'],
        "place_id": p['place_id'],
      };
    }).toList();
  } else {
    throw Exception('Failed to fetch place suggestions');
  }
}

Future<Map<String, double>> getPlaceLatLng(String placeId) async {
  final String url =
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$kGoogleApiKey';
  
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final location = data['result']['geometry']['location'];
    return {
      "lat": location['lat'],
      "lng": location['lng'],
    };
  } else {
    throw Exception('Failed to fetch place details');
  }
}

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
    {"name": "מאפים", "icon": Icons.bakery_dining},
    {"name": "עוגות", "icon": Icons.cake_rounded},
    {"name": "פירות וירקות", "icon": Icons.eco},
    {"name": "מוצרי חלב", "icon": Icons.local_drink},
    {"name": "היגיינה", "icon": Icons.soap},
    {"name": "מוצרי יסוד", "icon": Icons.kitchen},
    {"name": "אחר", "icon": Icons.category},
  ];

  final List<String> timeSlots = ["8:00-10:00", "10:00-12:00", "12:00-14:00"];

  final List<Map<String, String>> donatedItems = [];

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
  Map<String, String> item = donatedItems[index];
  String name = item["name"] ?? "";
  String quantity = item["quantity"] ?? "";
  String unit = item["unit"] ?? "";

  // אם הפריט הוא "אחר" – פותחים את הדיאלוג של "פרט פריט"
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
    // אם זה פריט רגיל – פותחים דיאלוג של כמות
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


  void toggleProduct(String name) {
    if (selectedProducts.contains(name)) {
      selectedProducts.remove(name);
    } else {
      selectedProducts.add(name);
      if (name == "אחר") {
        _showOtherDialog();
      } else {
        _showQuantityDialog(name);
      }
    }
    setState(() {});
  }

  void _showQuantityDialog(String productName) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            "הכנס כמות ב-יחידות/קג",
            style: TextStyle(
                color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(builder: (context, setStateDialog) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      if (quantity > 1) setStateDialog(() => quantity--);
                    },
                    icon: const Icon(Icons.remove)),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      setStateDialog(() => quantity++);
                    },
                    icon: const Icon(Icons.add)),
              ],
            );
          }),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  donatedItems.add({
                    "name": productName,
                    "quantity": quantity.toString(),
                    "unit": "קג/יחידות"
                  });
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: HomepageTheme.latetBlue, width: 1.5),
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

  void _showOtherDialog() {
    final TextEditingController otherController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            "פרט פריט לתרומה",
            style: TextStyle(
                color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: TextFormField(
            controller: otherController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "תיאור הפריט",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: HomepageTheme.latetBlue.withAlpha((255 * 1.0).toInt()),
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: HomepageTheme.latetBlue.withAlpha((255 * 1.0).toInt()),
                    width: 2),
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
                    donatedItems.add({
                      "name": "אחר: ${otherController.text}",
                      "quantity": "",
                      "unit": ""
                    });
                  }
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: HomepageTheme.latetBlue, width: 1.5),
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
  // 1️⃣ בדיקת שדות טופס רגילים
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

String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return "שדה חובה";
  }

  final phone = value.replaceAll(RegExp(r'\D'), '');

  if (!RegExp(r'^05\d{8}$').hasMatch(phone)) {
    return "מספר פלאפון לא תקין";
  }

  return null;
}

String? _validateBusinessId(String? value) {
  if (value == null || value.isEmpty) {
    return "שדה חובה";
  }

  final id = value.replaceAll(RegExp(r'\D'), '');

  if (id.length != 9) {
    return "ח\"פ חייב להכיל 9 ספרות";
  }

  int sum = 0;

  for (int i = 0; i < 8; i++) {
    int digit = int.parse(id[i]);
    int step = digit * ((i % 2) + 1);

    if (step > 9) {
      step = (step ~/ 10) + (step % 10);
    }

    sum += step;
  }

  int checkDigit = (10 - (sum % 10)) % 10;

  if (checkDigit != int.parse(id[8])) {
    return "ח\"פ לא תקין";
  }

  return null;
}




//   void submit() {
//   if (_validateBeforeSubmit()) {
//     print("Items: $donatedItems");

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("💙התרומה נשלחה בהצלחה")),
//     );

//     // כאן בהמשך תוכלי גם לנקות טופס אם תרצי
//   }
// }


void submit() async {
  if (!_validateBeforeSubmit()) return;

  try {
    final service = DonationService();

    final donation = DonationModel(
      businessName: businessName.text,
      businessAddress: address.text,
      lat: selectedLat!,   
      lng: selectedLng!,
      businessPhone: businessPhone.text,
      businessId: businessId.text,
      contactName: contactName.text,
      contactPhone: contactPhone.text,
      products: donatedItems,
      pickupTimes: selectedTimeSlots,
      organizationId: kOrganizationId,
      driverId: "",
      cancelingReason: "",
      recipe: "",
    );

    await service.reportDonation(donation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("💙 התרומה נשלחה בהצלחה")),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("שגיאה: $e")),
    );
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: HomepageTheme.topPadding),
                const Text("דיווח תרומה",
                    style: ReportDonationTheme.headerStyle),
                const SizedBox(height: 35),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildCard(
                        child: Column(
                          children: [
                            sectionTitle("פרטי העסק"),
                            buildField("שם העסק", businessName),
                            // buildField("כתובת העסק", address),
                            buildAddressField(),

                            
                            buildField(
                              "פלאפון העסק",
                              businessPhone,
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone
                            ),

                            buildField(
                              "ח\"פ / עוסק מורשה",
                              businessId,
                              validator: _validateBusinessId,
                              keyboardType: TextInputType.number
                            ),

                          ],
                        ),
                      ),
                      buildCard(
                        child: Column(
                          children: [
                            sectionTitle("איש קשר"),
                            buildField("שם איש קשר", contactName),
                            buildField(
                              "פלאפון איש קשר",
                              contactPhone,
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone
                            ),

                          ],
                        ),
                      ),
                      buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("חלונות זמן לאיסוף"),
                            Row(
                              children: timeSlots.map((slot) {
                                final selected = selectedTimeSlots.contains(slot);
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: GestureDetector(
                                      onTap: () => toggleTime(slot),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        alignment: Alignment.center,
                                        decoration:
                                            ReportDonationTheme.chipDecoration(selected),
                                        child: Text(
                                          slot,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: HomepageTheme.latetBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 30),
                            sectionTitle("מוצרים לתרומה"),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: products.sublist(0, 4).map((product) {
                                    return Flexible(
                                      fit: FlexFit.tight,
                                      child: GestureDetector(
                                        onTap: () => toggleProduct(product["name"]),
                                        child: Column(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withAlpha((255 * 0.06).toInt()),
                                                    blurRadius: 10,
                                                  )
                                                ],
                                              ),
                                              child: Icon(
                                                product["icon"],
                                                color: HomepageTheme.latetBlue,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              product["name"],
                                              style: const TextStyle(
                                                fontFamily: 'Assistant',
                                                fontSize: 13,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: products.sublist(4).map((product) {
                                    return Flexible(
                                      fit: FlexFit.tight,
                                      child: GestureDetector(
                                        onTap: () => toggleProduct(product["name"]),
                                        child: Column(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withAlpha((255 * 0.06).toInt()),
                                                    blurRadius: 10,
                                                  )
                                                ],
                                              ),
                                              child: Icon(
                                                product["icon"],
                                                color: HomepageTheme.latetBlue,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              product["name"],
                                              style: const TextStyle(
                                                fontFamily: 'Assistant',
                                                fontSize: 13,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // רשימת הפריטים שהוספו – ריבוע נפרד
                      if (donatedItems.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(bottom: 25),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, // רקע לבן
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
      crossAxisAlignment: CrossAxisAlignment.stretch, // מרחיב לשטח הקונטיינר
      children: [
        Text(
          "פריטים שנוספו",
          textAlign: TextAlign.right, // יישור לימין
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
            Map<String, String> item = entry.value;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl, // יישור מימין לשמאל
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // שם פריט, כמות ויחידות
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item["name"] ?? "",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item["quantity"] ?? ""} ${item["unit"] ?? ""}",
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // כפתורי עריכה ומחיקה
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _editDonatedItem(index);
                        },
                        icon: Icon(Icons.edit, color: HomepageTheme.latetBlue),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            donatedItems.removeAt(index);
                          });
                        },
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submit,
                          style: ReportDonationTheme.simpleButton,
                          child: const Text("אשר תרומה"),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.95).toInt()),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).toInt()),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }



  Widget buildField(
  String hint,
  TextEditingController controller, {
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        validator: validator ??
            (value) =>
                value == null || value.isEmpty ? "שדה חובה" : null,
        decoration: ReportDonationTheme.inputDecoration(hint),
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
      ),
    ),
  );
}


  Widget buildAddressField() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Autocomplete<Map<String, String>>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.isEmpty) return const Iterable<Map<String, String>>.empty();
          return await fetchPlaceSuggestions(textEditingValue.text);
        },
        displayStringForOption: (option) => option["description"]!,
        onSelected: (selection) async {
          address.text = selection["description"]!;
          
          // קבלת lat/lng
          final coords = await getPlaceLatLng(selection["place_id"]!);
          print("Selected coordinates: ${coords['lat']}, ${coords['lng']}");

          // כאן אפשר לשמור במשתנה של ה-State כדי לשלוח בפרטי התרומה
          setState(() {
            selectedLat = coords['lat'];
            selectedLng = coords['lng'];
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: (value) =>
                value == null || value.isEmpty ? "שדה חובה" : null,
            decoration: ReportDonationTheme.inputDecoration("כתובת העסק"),
            textAlign: TextAlign.right,
            onEditingComplete: onEditingComplete,
          );
        },
      ),
    ),
  );
}


  

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          text,
          style: ReportDonationTheme.labelStyle,
        ),
      ),
    );
  }
}
