import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';

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
    {"name": "מוצרי יסוד", "icon": Icons.kitchen},
    {"name": "מוצרי חלב", "icon": Icons.local_drink},
    {"name": "היגיינה", "icon": Icons.soap},
    {"name": "אחר", "icon": Icons.category},
  ];

  final List<String> timeSlots = ["8:00-10:00", "10:00-12:00", "12:00-14:00"];

  final List<Map<String, String>> donatedItems = [];

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

  void submit() {
    if (_formKey.currentState!.validate()) {
      print("Items: $donatedItems");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("התרומה נשלחה בהצלחה 💙")),
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
                            buildField("כתובת העסק", address),
                            buildField("פלאפון העסק", businessPhone),
                            buildField("ח\"פ / עוסק מורשה", businessId),
                          ],
                        ),
                      ),
                      buildCard(
                        child: Column(
                          children: [
                            sectionTitle("איש קשר"),
                            buildField("שם איש קשר", contactName),
                            buildField("פלאפון איש קשר", contactPhone),
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

  Widget buildField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          controller: controller,
          validator: (value) => value == null || value.isEmpty ? "שדה חובה" : null,
          decoration: ReportDonationTheme.inputDecoration(hint),
          textAlign: TextAlign.right,
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
