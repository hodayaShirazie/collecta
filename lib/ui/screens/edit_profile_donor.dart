import 'package:flutter/material.dart';

import '../../services/donor_service.dart';
import '../../services/address_service.dart';
import '../../services/user_service.dart';

import '../../data/models/donor_model.dart';

import '../theme/homepage_theme.dart';
import '../theme/edit_profile_donor_theme.dart';

import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';

import '../widgets/personal_details/business_details_card.dart';
import '../widgets/personal_details/contact_details_card.dart';
import '../widgets/personal_details/user_details_card.dart';
import '../widgets/donation_widgets/input_field.dart';

import '../utils/validators/phone_validator.dart';
import '../utils/validators/business_id_validator.dart';

import 'package:collecta/app/routes.dart';

class DonorEditProfileScreen extends StatefulWidget {
  const DonorEditProfileScreen({super.key});

  @override
  State<DonorEditProfileScreen> createState() => _DonorEditProfileScreenState();
}

class _DonorEditProfileScreenState extends State<DonorEditProfileScreen> {

  final DonorService _donorService = DonorService();
  final AddressService _addressService = AddressService();
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();

  DonorProfile? donor;

  double? selectedLat;
  double? selectedLng;

  final nameCtrl = TextEditingController();
  final businessNameCtrl = TextEditingController();
  final businessPhoneCtrl = TextEditingController();
  final businessAddressCtrl = TextEditingController();
  final contactNameCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final crnCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDonorProfile();
  }

  Future<void> _loadDonorProfile() async {
    try {

      donor = await _donorService.getMyDonorProfile();

      nameCtrl.text = donor!.user.name;
      businessNameCtrl.text = donor!.businessName;
      businessPhoneCtrl.text = donor!.businessPhone;
      // businessAddressCtrl.text = donor!.businessAddress.name;
      contactNameCtrl.text = donor!.contactName;
      contactPhoneCtrl.text = donor!.contactPhone;
      crnCtrl.text = donor!.crn;

      if (donor!.businessAddress.name.isNotEmpty) {
        businessAddressCtrl.text = donor!.businessAddress.name;
        selectedLat = donor!.businessAddress.lat;
        selectedLng = donor!.businessAddress.lng;
      }

      setState(() {});

    } catch (e) {
      debugPrint("Error loading donor: $e");
    }
  }

  Future<void> _saveProfile() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (donor == null) return;

    try {

      /// update user
      await _userService.updateUserProfile(
        name: nameCtrl.text,
      );

      String addressId = donor!.businessAddress.id;
      var address = donor!.businessAddress;

      final hasAddress =
          addressId.isNotEmpty &&
          addressId.trim().isNotEmpty &&
          address.name.trim().isNotEmpty;

      /// אם אין כתובת → צור חדשה
      if (!hasAddress) {

        addressId = await _addressService.createAddress(
          name: businessAddressCtrl.text,
          lat: selectedLat!,
          lng: selectedLng!,
        );

        address = address.copyWith(
          id: addressId,
          name: businessAddressCtrl.text,
          lat: selectedLat!,
          lng: selectedLng!,
        );

      } else {

        /// אם יש כתובת → עדכן
        final updatedAddress = address.copyWith(
          name: businessAddressCtrl.text,
          lat: selectedLat ?? address.lat,
          lng: selectedLng ?? address.lng,
        );

        await _addressService.updateAddress(updatedAddress);
        address = updatedAddress;
      }

      /// update donor
      final updatedDonor = donor!.copyWith(
        businessName: businessNameCtrl.text,
        businessPhone: businessPhoneCtrl.text,
        contactName: contactNameCtrl.text,
        contactPhone: contactPhoneCtrl.text,
        crn: crnCtrl.text,
        businessAddress: address,
      );

      await _donorService.updateDonorProfile(updatedDonor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("הפרטים נשמרו")),
      );

      Navigator.pushReplacementNamed(context, Routes.donor);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה: $e")),
      );

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
                    "עריכת פרטי תורם",
                    style: DonorEditProfileTheme.headerStyle,
                  ),

                  const SizedBox(height: 35),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        DonorDetailsCard(
                          donorName: nameCtrl,
                        ),

                        // InputFieldWidget(
                        //   controller: nameCtrl,
                        //   hint: "שם בעל העסק",
                        // ),
                        // const SizedBox(height: 20),

                        BusinessDetailsCard(
                          businessName: businessNameCtrl,
                          address: businessAddressCtrl,
                          businessPhone: businessPhoneCtrl,
                          businessId: crnCtrl,
                          onLocationSelected: (lat, lng) {
                            setState(() {
                              selectedLat = lat;
                              selectedLng = lng;
                            });
                          },
                        ),

                        ContactDetailsCard(
                          contactName: contactNameCtrl,
                          contactPhone: contactPhoneCtrl,
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: DonorEditProfileTheme.saveButtonStyle,
                            child: const Text("שמור"),
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
      ),
    );
  }
}