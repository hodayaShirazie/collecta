import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';

import '../widgets/layout_wrapper.dart';
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
import '../widgets/donation_widgets/donated_items_section.dart';
import '../widgets/donation_widgets/dialog/edit_quantity_dialog.dart';
import '../widgets/donation_widgets/dialog/other_item_dialog.dart';
import '../widgets/donation_widgets/donation_form.dart';

import '../utils/validators/phone_validator.dart';
import '../utils/validators/business_id_validator.dart';
import '../utils/donation/donation_toggle_product_helper.dart';
import '../utils/donation/donation_edit_helper.dart';
import '../utils/donation/donation_constants.dart';


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
  final products = DonationConstants.products;
  final timeSlots = DonationConstants.timeSlots;
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

  Future<void> _editDonatedItem(int index) async {
    await DonationEditHelper.editDonatedItem(
      context: context,
      index: index,
      donatedItems: donatedItems,
      refresh: () => setState(() {}),
    );
  }

  Future<void> toggleProduct(Map<String, dynamic> product) async {
    await DonationToggleProductHelper.toggleProduct(
      context: context,
      product: product,
      selectedProducts: selectedProducts,
      donatedItems: donatedItems,
      refresh: () => setState(() {}),
    );
  }

  bool _validateBeforeSubmit() {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid) {
      return false;
    }


    if (selectedTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("יש לבחור לפחות חלון זמן אחד"),
        ),
      );
      return false;
    }


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

                  DonationForm(
                    formKey: _formKey,
                    businessName: businessName,
                    address: address,
                    businessPhone: businessPhone,
                    businessId: businessId,
                    contactName: contactName,
                    contactPhone: contactPhone,
                    timeSlots: timeSlots,
                    selectedTimeSlots: selectedTimeSlots,
                    toggleTime: toggleTime,
                    products: products,
                    selectedProducts: selectedProducts,
                    toggleProduct: toggleProduct,
                    donatedItems: donatedItems,
                    onEditItem: _editDonatedItem,
                    onDeleteItem: (index) {
                      setState(() {
                        donatedItems.removeAt(index);
                      });
                    },
                    onSubmit: submit,
                    buttonText: "אשר תרומה",
                    onLocationSelected: (lat, lng) {
                      setState(() {
                        selectedLat = lat;
                        selectedLng = lng;
                      });
                    },
                    buttonStyle: ReportDonationTheme.simpleButton,
                  ),
    
                 // END FORM

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
