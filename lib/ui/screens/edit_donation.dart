
// import 'package:flutter/material.dart';
// import '../theme/homepage_theme.dart';
// import '../theme/report_donation_theme.dart';
// import '../widgets/layout_wrapper.dart';
// import '../widgets/donation_widgets/donation_form.dart';
// import '../utils/donation/donation_constants.dart';
// import '../../data/models/donation_model.dart';

// class EditDonation extends StatefulWidget {
//   final DonationModel donation; 

//   const EditDonation({super.key, required this.donation});

//   @override
//   State<EditDonation> createState() => _EditDonationState();
// }

// class _EditDonationState extends State<EditDonation> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController businessNameCtrl;
//   late TextEditingController addressCtrl;
//   late TextEditingController businessPhoneCtrl;
//   late TextEditingController businessIdCtrl;
//   late TextEditingController contactNameCtrl;
//   late TextEditingController contactPhoneCtrl;

//   List<String> selectedTimeSlots = [];
//   List<String> selectedProducts = [];
//   List<Map<String, dynamic>> donatedItems = [];

//   @override
//   @override
//   void initState() {
//     super.initState();

//     // אתחול controllers עם נתונים קיימים אם קיימים, אחרת עם מחרוזת ריקה
//     businessNameCtrl = TextEditingController(
//         text: '');
//     addressCtrl = TextEditingController(
//         text: '');
//     businessPhoneCtrl = TextEditingController(
//         text:  '');
//     businessIdCtrl = TextEditingController(
//         text:  '');
//     contactNameCtrl = TextEditingController(
//         text: widget.donation.contactName ?? '');
//     contactPhoneCtrl = TextEditingController(
//         text: widget.donation.contactPhone ?? '');

//     // אתחול רשימות או ריקות
//     selectedTimeSlots = List<String>.from([]);
//     selectedProducts = List<String>.from( []);
//     donatedItems = List<Map<String, dynamic>>.from( []);
//   }

//    void toggleTime(String slot) {
//     setState(() {
//       if (selectedTimeSlots.contains(slot)) {
//         selectedTimeSlots.remove(slot);
//       } else {
//         selectedTimeSlots.add(slot);
//       }
//     });
//   }

//   void toggleProduct(Map<String, dynamic> product) {
//     final name = product["name"];

//     setState(() {
//       if (selectedProducts.contains(name)) {
//         selectedProducts.remove(name);
//       } else {
//         selectedProducts.add(name);
//       }
//     });
//   }
//   void editItem(int index) {
//     // בהמשך
//   }

//   void deleteItem(int index) {
//     setState(() {
//       donatedItems.removeAt(index);
//     });
//   }

//   void submit() {
//     // בהמשך update donation
//   }

//   void onLocationSelected(double lat, double lng) {
//     // בהמשך אם תרצי לשמור מיקום
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutWrapper(
//         child: Container(
//           decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 25),
//               child: Column(
//                 children: [
//                   const SizedBox(height: HomepageTheme.topPadding),
//                   const Text("עריכת תרומה", style: ReportDonationTheme.headerStyle),
//                   const SizedBox(height: 35),
//                   DonationForm(
//                     formKey: _formKey,
//                     businessName: businessNameCtrl,
//                     address: addressCtrl,
//                     businessPhone: businessPhoneCtrl,
//                     businessId: businessIdCtrl,
//                     contactName: contactNameCtrl,
//                     contactPhone: contactPhoneCtrl,
//                     timeSlots: DonationConstants.timeSlots,
//                     selectedTimeSlots: selectedTimeSlots,
//                     toggleTime: toggleTime,
//                     products: DonationConstants.products,
//                     selectedProducts: selectedProducts,
//                     toggleProduct: toggleProduct,
//                     donatedItems: donatedItems,
//                     onEditItem: editItem,
//                     onDeleteItem: deleteItem,
//                     onSubmit: submit,
//                     buttonText: "שמור שינויים",
//                     onLocationSelected: onLocationSelected,
//                     buttonStyle: ReportDonationTheme.simpleButton,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }










import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../widgets/layout_wrapper.dart';
import '../widgets/donation_widgets/donation_form.dart';
import '../utils/donation/donation_constants.dart';
import '../../data/models/donation_model.dart';
import '../../data/models/product_model.dart';
// import '../../data/models/pickup_time.dart';

class EditDonation extends StatefulWidget {
  final DonationModel donation;

  const EditDonation({super.key, required this.donation});

  @override
  State<EditDonation> createState() => _EditDonationState();
}

class _EditDonationState extends State<EditDonation> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController businessNameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController businessPhoneCtrl;
  late TextEditingController businessIdCtrl;
  late TextEditingController contactNameCtrl;
  late TextEditingController contactPhoneCtrl;

  List<String> selectedTimeSlots = [];
  List<String> selectedProducts = [];
  List<Map<String, dynamic>> donatedItems = [];

  @override
  void initState() {
    super.initState();


    businessNameCtrl = TextEditingController(
        text: widget.donation.businessAddress.name ?? '');
    addressCtrl = TextEditingController(
        text: widget.donation.businessAddress.name ?? ''); // או כתובת מפורטת
    businessPhoneCtrl = TextEditingController(
        text: widget.donation.contactPhone ?? ''); // change to real field
    businessIdCtrl = TextEditingController(
        text: widget.donation.businessAddress.id ?? '');
    contactNameCtrl = TextEditingController(
        text: widget.donation.contactName ?? '');
    contactPhoneCtrl = TextEditingController(
        text: widget.donation.contactPhone ?? '');

    // ❗ אתחול רשימות
    selectedTimeSlots = widget.donation.pickupTimes.isNotEmpty
        ? widget.donation.pickupTimes
            .map((slot) => "${slot.from} - ${slot.to}")
            .toList()
        : [];

    selectedProducts = widget.donation.products.isNotEmpty
        ? widget.donation.products.map((p) => p.type.name).toList()
        : [];

    donatedItems = widget.donation.products.isNotEmpty
        ? widget.donation.products
            .map((p) => {
                  "id": p.id,
                  "type": {"name": p.type.name, "description": p.type.description},
                  "quantity": p.quantity,
                })
            .toList()
        : [];
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

  void toggleProduct(Map<String, dynamic> product) {
    final name = product["name"];
    setState(() {
      if (selectedProducts.contains(name)) {
        selectedProducts.remove(name);
      } else {
        selectedProducts.add(name);
      }
    });
  }

  void editItem(int index) {
    // TODO: טיפול בעריכת פריט
  }

  void deleteItem(int index) {
    setState(() {
      donatedItems.removeAt(index);
    });
  }

  void submit() {
    // TODO: עדכון התרומה דרך API
  }

  void onLocationSelected(double lat, double lng) {
    // TODO: אם רוצים לשמור מיקום
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
                  const Text("עריכת תרומה", style: ReportDonationTheme.headerStyle),
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