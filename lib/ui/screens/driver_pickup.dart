// import 'package:flutter/material.dart';
// import '../theme/homepage_theme.dart';
// import '../theme/report_donation_theme.dart';
// import '../widgets/layout_wrapper.dart';
// import '../widgets/loading_indicator.dart';
// import '../widgets/custom_popup_dialog.dart';
// import '../../data/models/donation_model.dart'; 
// import '../../data/models/donor_model.dart';
// import '../../services/donation_service.dart';
// import '../../services/donor_service.dart';

// class DriverPickupPage extends StatefulWidget {
//   final String donationId;
//   const DriverPickupPage({super.key, required this.donationId});

//   @override
//   State<DriverPickupPage> createState() => _DriverPickupPageState();
// }

// class _DriverPickupPageState extends State<DriverPickupPage> {
//   final DonationService _donationService = DonationService();
//   final DonorService _donorService = DonorService();
  
//   // קונטרולרים לשדות המידע
//   final businessNameController = TextEditingController();
//   final businessPhoneController = TextEditingController();
//   final businessAddressController = TextEditingController();
//   final crnController = TextEditingController();

//   DonationModel? donation;
//   bool isLoading = true;
//   Map<String, int> collectedQuantities = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadDonationData();
//   }

//   Future<void> _loadDonationData() async {
//     try {
//       setState(() => isLoading = true);

//       // 1. שליפת רשימת התרומות של הנהג
//       final List<DonationModel> results = await _donationService.getDriverDonationsById();
      
//       if (results.isNotEmpty) {
//         // מוצאים את התרומה הספציפית לפי ה-ID שנשלח לעמוד
//         final currentDonation = results.firstWhere((d) => d.id == widget.donationId);

//         // 2. שליפת פרופיל התורם כדי לקבל שם עסק וח"פ
//         // הערה: וודאי שקיימת פונקציה getDonorProfileById ב-DonorService שלך
//         final DonorProfile donorProfile = await _donorService.getDonorProfileById(currentDonation.donorId);

//         setState(() {
//           donation = currentDonation;
          
//           // מילוי השדות במידע מהפרופיל של התורם
//           businessNameController.text = donorProfile.businessName;
//           businessPhoneController.text = donorProfile.businessPhone;
//           businessAddressController.text = donorProfile.businessAddress.name;
//           crnController.text = donorProfile.crn; // ח"פ / עוסק מורשה

//           // אתחול כמויות המוצרים
//           for (var item in donation!.products) {
//             collectedQuantities[item.type.id] = item.quantity;
//           }
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       debugPrint("🔴 Error loading donation details: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _submitPickup() async {
//     try {
//       // כאן תבוא הלוגיקה לעדכון ה-Status ל"נאסף" ושליחת כמויות מעודכנות
//       if (!mounted) return;
//       await showDialog(
//         context: context,
//         builder: (context) => const CustomPopupDialog(
//           title: "איסוף הושלם",
//           message: "נתוני האיסוף עודכנו במערכת בהצלחה",
//           buttonText: "אישור",
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("שגיאה בעדכון האיסוף: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Scaffold(body: LoadingIndicator());
//     if (donation == null) return const Scaffold(body: Center(child: Text("תרומה לא נמצאה")));

//     return Scaffold(
//       body: LayoutWrapper(
//         child: Container(
//           decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 25),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end, // יישור כללי לימין
//                 children: [
//                   const SizedBox(height: 20),
//                   const Center(child: Text("איסוף תרומה", style: ReportDonationTheme.headerStyle)),
//                   const Center(
//                     child: Text(
//                       "פרטי התחנה לעדכון", 
//                       style: TextStyle(color: HomepageTheme.latetBlue, fontSize: 18, fontWeight: FontWeight.w500)
//                     )
//                   ),
//                   const SizedBox(height: 25),

//                   // כרטיס פרטי העסק - הכל לקריאה בלבד
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: ReportDonationTheme.cardDecoration,
//                     child: Column(
//                       children: [
//                         _buildReadOnlyField("שם העסק:", businessNameController),
//                         _buildReadOnlyField("פלאפון עסק:", businessPhoneController),
//                         _buildReadOnlyField("כתובת עסק:", businessAddressController),
//                         _buildReadOnlyField("ח\"פ / עוסק מורשה:", crnController),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 25),
//                   const Text("עדכון כמויות שנאספו בפועל:", style: ReportDonationTheme.labelStyle),
//                   const SizedBox(height: 10),
                  
//                   // רשימת מוצרים עם בורר כמות
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: ReportDonationTheme.cardDecoration,
//                     child: Column(
//                       children: donation!.products.map((product) {
//                         return _buildProductRow(product.type.name, product.type.id);
//                       }).toList(),
//                     ),
//                   ),

//                   const SizedBox(height: 35),

//                   // כפתור אישור סופי
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _submitPickup,
//                       style: ReportDonationTheme.simpleButton,
//                       child: const Text("אשר איסוף תרומה", style: TextStyle(fontSize: 20)),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // שורת מוצר עם כפתורי פלוס/מינוס - מותאם לימין
//   Widget _buildProductRow(String label, String productId) {
//     int currentQty = collectedQuantities[productId] ?? 0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           // כפתור סטטוס מהיר (אישור)
//           _buildActionButton("אישור", Colors.green),
          
//           const Spacer(),
          
//           // בורר כמות (Stepper)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.blue.shade100),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Column(
//                   children: [
//                     InkWell(
//                       onTap: () => setState(() => collectedQuantities[productId] = currentQty + 1),
//                       child: const Icon(Icons.arrow_drop_up, size: 22, color: HomepageTheme.latetBlue),
//                     ),
//                     InkWell(
//                       onTap: () => setState(() {
//                         if (currentQty > 0) collectedQuantities[productId] = currentQty - 1;
//                       }),
//                       child: const Icon(Icons.arrow_drop_down, size: 22, color: HomepageTheme.latetBlue),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   "$currentQty", 
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(width: 15),
          
//           // שם המוצר מיושר לימין
//           SizedBox(
//             width: 110,
//             child: Text(
//               "$label:",
//               textAlign: TextAlign.right,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HomepageTheme.latetBlue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.85),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Text(
//         text, 
//         style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
//       ),
//     );
//   }

//   // שדה טקסט לקריאה בלבד - מיושר לימין ב-100%
//   Widget _buildReadOnlyField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Column(
//         // התיקון המרכזי: מיישר את הכותרת (ה-Label) לצד ימין
//         crossAxisAlignment: CrossAxisAlignment.start, 
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
//             child: Text(
//               label, 
//               style: ReportDonationTheme.labelStyle,
//               textAlign: TextAlign.right, // מבטיח שהטקסט עצמו יזרום לימין
//             ),
//           ),
//           TextField(
//             controller: controller,
//             readOnly: true,
//             textAlign: TextAlign.right, // מיישר את התוכן שבתוך התיבה לימין
//             style: const TextStyle(
//               fontSize: 15, 
//               fontWeight: FontWeight.w600, 
//               color: Colors.black87,
//               fontFamily: 'Assistant',
//             ),
//             decoration: ReportDonationTheme.inputDecoration(""),
//           ),
//         ],
//       ),
//     );
//   }
// }












import 'dart:convert';

import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_popup_dialog.dart';
import '../../data/models/donation_model.dart'; 
import '../../data/models/donor_model.dart';
import '../../services/donation_service.dart';
import '../../services/donor_service.dart';
import '../../data/models/product_model.dart';

class DriverPickupPage extends StatefulWidget {
  final String donationId;
  const DriverPickupPage({super.key, required this.donationId});

  @override
  State<DriverPickupPage> createState() => _DriverPickupPageState();
}

class _DriverPickupPageState extends State<DriverPickupPage> {
  final DonationService _donationService = DonationService();
  final DonorService _donorService = DonorService();
  
  final businessNameController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final businessAddressController = TextEditingController();
  final crnController = TextEditingController();

  // מפות לניהול התיאורים של מוצרי "אחר"
  final Map<String, TextEditingController> otherDescriptionControllers = {};

  DonationModel? donation;
  bool isLoading = true;
  
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
      final List<DonationModel> results = await _donationService.getDriverDonationsById();
      
      if (results.isNotEmpty) {
        final currentDonation = results.firstWhere((d) => d.id == widget.donationId);
        final DonorProfile donorProfile = await _donorService.getDonorProfileById(currentDonation.donorId);

        setState(() {
          donation = currentDonation;
          businessNameController.text = donorProfile.businessName;
          businessPhoneController.text = donorProfile.businessPhone;
          businessAddressController.text = donorProfile.businessAddress.name;
          crnController.text = donorProfile.crn;

          for (var item in donation!.products) {
            collectedQuantities[item.id] = item.quantity;
            productStatus[item.id] = null; 

            // אם זה מוצר מסוג "אחר", נשמור את התיאור שלו בקונטרולר לעריכה
            if (item.type.name == "אחר") {
              otherDescriptionControllers[item.id] = 
                  TextEditingController(text: item.type.description ?? "");
            }
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("🔴 Error loading donation details: $e");
      setState(() => isLoading = false);
    }
  }


Future<void> _submitPickup() async {
  // 1. ולידציה - האם הכל סומן?
  bool allSelected = productStatus.values.every((status) => status != null);
  if (!allSelected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("יש לסמן אישור או ביטול לכל המוצרים"), backgroundColor: Colors.red),
    );
    return;
  }

  try {
    setState(() => isLoading = true);

    List<Map<String, dynamic>> productsToUpdate = donation!.products.map((item) {
    bool isOther = item.type.name == "אחר";
    return {
      "productId": item.id,
      "productTypeId": item.type.id,
      "isOther": isOther, // דגל שעוזר לשרת לדעת אם למחוק גם את ה-Type
      "collectedQuantity": collectedQuantities[item.id],
      "isPickedUp": productStatus[item.id], // true לאישור, false לביטול
      "newDescription": isOther ? otherDescriptionControllers[item.id]?.text : null,
    };
  }).toList();

    print("🚀 Sending to Server: ${json.encode(productsToUpdate)}"); 

    await _donationService.submitPickup(
      donationId: widget.donationId,
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
    Navigator.pop(context, true);
  } catch (e) {
    // גם כאן - בדיקה לפני setState
    if (mounted) {
      setState(() => isLoading = false);
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
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  const Center(child: Text("איסוף תרומה", style: ReportDonationTheme.headerStyle)),
                  const Center(child: Text("פרטי התחנה לעדכון", style: TextStyle(color: HomepageTheme.latetBlue, fontSize: 18, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ReportDonationTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildReadOnlyField("שם העסק:", businessNameController),
                        _buildReadOnlyField("פלאפון עסק:", businessPhoneController),
                        _buildReadOnlyField("כתובת עסק:", businessAddressController),
                        _buildReadOnlyField("ח\"פ / עוסק מורשה:", crnController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text("עדכון כמויות שנאספו בפועל:", style: ReportDonationTheme.labelStyle),
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: ReportDonationTheme.cardDecoration,
                    child: Column(
                      children: donation!.products.map((product) {
                        // מעבירים את כל אובייקט ה-Product כדי לבדוק אם הוא "אחר"
                        return _buildProductRow(product);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPickup,
                      style: ReportDonationTheme.simpleButton,
                      child: const Text("אשר איסוף תרומה", style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(ProductModel item) {
    String productId = item.id;
    int currentQty = collectedQuantities[productId] ?? 0;
    bool? status = productStatus[productId];
    bool isOther = item.type.name == "אחר";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // 1. כפתורי בחירה (שמאל)
          _buildChoiceButton(
            "אשר",
            status == true ? HomepageTheme.latetBlue : Colors.grey.shade300,
            status == true ? Colors.white : Colors.black54,
            () => setState(() => productStatus[productId] = true)
          ),
          const SizedBox(width: 4),
          _buildChoiceButton(
            "בטל",
            status == false ? const Color(0xFF78909C) : Colors.grey.shade300,
            status == false ? Colors.white : Colors.black54,
            () => setState(() => productStatus[productId] = false)
          ),

          const Spacer(),

          // 2. בורר כמות קומפקטי (מרכז)
          Flexible(
            flex: 3,
            child: Opacity(
              opacity: status == false ? 0.3 : 1.0,
              child: AbsorbPointer(
                absorbing: status == false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20, color: HomepageTheme.latetBlue),
                          onPressed: () => setState(() => collectedQuantities[productId] = currentQty + 1),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        Text("$currentQty", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomepageTheme.latetBlue)),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20, color: HomepageTheme.latetBlue),
                          onPressed: () => setState(() { if (currentQty > 1) collectedQuantities[productId] = currentQty - 1; }),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 3. שם המוצר / תיאור "אחר" (ימין)
          Expanded(
            flex: 5,
            child: isOther 
              ? TextFormField(
                  controller: otherDescriptionControllers[productId],
                  textAlign: TextAlign.right,
                  enabled: status != false,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: status == false ? Colors.grey : HomepageTheme.latetBlue,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    hintText: "תאר את המוצר...",
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  "${item.type.name}:",
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: status == false ? Colors.grey : HomepageTheme.latetBlue,
                    decoration: status == false ? TextDecoration.lineThrough : null,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, 
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
              child: Text(label, style: ReportDonationTheme.labelStyle, textAlign: TextAlign.right),
            ),
            TextField(
              controller: controller,
              readOnly: true,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: 'Assistant'),
              decoration: ReportDonationTheme.inputDecoration(""),
            ),
          ],
        ),
      ),
    );
  }
}