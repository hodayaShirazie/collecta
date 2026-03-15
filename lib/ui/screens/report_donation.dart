import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

import '../../services/donation_flow_service.dart';
import '../../services/donor_service.dart';

import '../../data/models/donor_model.dart';



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

  DonorProfile? donor;


  @override
  void initState() {
    super.initState();
    _loadDonorProfileIfExists();
  }

  Future<void> _loadDonorProfileIfExists() async {
    try {
      donor = await DonorService().getMyDonorProfile();

      businessName.text = donor!.businessName;
      businessPhone.text = donor!.businessPhone;
      contactName.text = donor!.contactName;
      contactPhone.text = donor!.contactPhone;
      businessId.text = donor!.crn;
      address.text = donor!.businessAddress.name;

      selectedLat = donor!.businessAddress.lat;
      selectedLng = donor!.businessAddress.lng;

      setState(() {});
    } catch (e) {
      debugPrint("No donor profile found: $e");
    }
  }


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

  Future<bool> _validateBeforeSubmit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid) {
      return false;
    }


    if (selectedTimeSlots.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "שים לב",
          message: "יש לבחור לפחות חלון זמן אחד",
          buttonText: "סגור",
        ),
      );
      return false;
    }


    if (donatedItems.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "שים לב",
          message: "יש להוסיף לפחות מוצר אחד לתרומה",
          buttonText: "סגור",
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> submit() async {
    if (!await _validateBeforeSubmit()) {
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

      await showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "תודה על תרומתך!",
          message: "התרומה נשלחה בהצלחה",
          buttonText: "סגור",
        ),
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

    if (donor == null) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

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
                    isCategoryDisabled: (product) => DonationCategoryHelper.isCategoryDisabled(
                      product: product,
                      donatedItems: donatedItems,
                    ),
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
