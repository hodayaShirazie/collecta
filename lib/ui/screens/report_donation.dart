import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final crn = TextEditingController();
  final contactName = TextEditingController();
  final contactPhone = TextEditingController();
  final List<String> selectedTimeSlots = [];
  final List<String> selectedProducts = [];
  final products = DonationConstants.products;
  final timeSlots = DonationConstants.timeSlots;
  final List<Map<String, dynamic>> donatedItems = [];

  double? selectedLat;
  double? selectedLng;
  bool _isSubmitting = false;

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
      crn.text = donor!.crn;
      address.text = donor!.businessAddress.name;

      selectedLat = donor!.businessAddress.lat;
      selectedLng = donor!.businessAddress.lng;

      if (!mounted) return;

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
      refresh: () {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  Future<void> toggleProduct(Map<String, dynamic> product) async {
    await DonationToggleProductHelper.toggleProduct(
      context: context,
      product: product,
      selectedProducts: selectedProducts,
      donatedItems: donatedItems,
      refresh: () {
        if (!mounted) return;
        setState(() {});
      },
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
    if (_isSubmitting) return false;
    if (!await _validateBeforeSubmit()) {
      return false;
    }

    setState(() => _isSubmitting = true);

    try {
      await DonationFlowService().submitDonation(
        businessName: businessName.text,
        businessPhone: businessPhone.text,
        address: address.text,
        contactName: contactName.text,
        contactPhone: contactPhone.text,
        crn: crn.text,
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

      if (!mounted) return false;

      Navigator.pop(context);

      return true; 

    } catch (e) {
      if (!mounted) return false;
      setState(() => _isSubmitting = false);
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
          child: SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: HomepageTheme.topPadding),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                          color: HomepageTheme.latetBlue, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text("דיווח תרומה",
                          textAlign: TextAlign.center,
                          style: ReportDonationTheme.headerStyle),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 35),

                // ===================== FORM =====================

                DonationForm(
                  formKey: _formKey,
                  businessName: businessName,
                  address: address,
                  businessPhone: businessPhone,
                  crn: crn,
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
                  onSubmit: _isSubmitting ? null : submit,
                  buttonText: "אשר תרומה",
                  isLoading: _isSubmitting,
                  isAddressConfirmed: selectedLat != null,
                  onLocationSelected: (lat, lng) {
                    setState(() {
                      selectedLat = lat;
                      selectedLng = lng;
                    });
                  },
                  onLocationCleared: () {
                    setState(() {
                      selectedLat = null;
                      selectedLng = null;
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
