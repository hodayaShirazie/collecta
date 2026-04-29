import 'package:flutter/material.dart';

import '../../services/donor_service.dart';
import '../../services/address_service.dart';
import '../../services/user_service.dart';

import '../../data/models/donor_model.dart';

import '../theme/homepage_theme.dart';
import '../theme/edit_profile_donor_theme.dart';
import '../theme/report_donation_theme.dart';

import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_popup_dialog.dart';

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
  bool _isSaving = false;

  String _origName = '';
  String _origBusinessName = '';
  String _origBusinessPhone = '';
  String _origAddressName = '';
  double? _origLat;
  double? _origLng;
  String _origContactName = '';
  String _origContactPhone = '';
  String _origCrn = '';

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

  @override
  void dispose() {
    for (final ctrl in [nameCtrl, businessNameCtrl, businessPhoneCtrl,
                         businessAddressCtrl, contactNameCtrl, contactPhoneCtrl, crnCtrl]) {
      ctrl.removeListener(_onAnyFieldChanged);
    }
    super.dispose();
  }

  void _onAnyFieldChanged() => setState(() {});

  bool get _hasChanges =>
      nameCtrl.text != _origName ||
      businessNameCtrl.text != _origBusinessName ||
      businessPhoneCtrl.text != _origBusinessPhone ||
      businessAddressCtrl.text != _origAddressName ||
      selectedLat != _origLat ||
      selectedLng != _origLng ||
      contactNameCtrl.text != _origContactName ||
      contactPhoneCtrl.text != _origContactPhone ||
      crnCtrl.text != _origCrn;

  Future<void> _loadDonorProfile() async {
    try {

      donor = await _donorService.getMyDonorProfile();

      nameCtrl.text = donor!.user.name;
      businessNameCtrl.text = donor!.businessName;
      businessPhoneCtrl.text = donor!.businessPhone;
      contactNameCtrl.text = donor!.contactName;
      contactPhoneCtrl.text = donor!.contactPhone;
      crnCtrl.text = donor!.crn;

      if (donor!.businessAddress.name.isNotEmpty) {
        businessAddressCtrl.text = donor!.businessAddress.name;
        selectedLat = donor!.businessAddress.lat;
        selectedLng = donor!.businessAddress.lng;
      }

      _origName = nameCtrl.text;
      _origBusinessName = businessNameCtrl.text;
      _origBusinessPhone = businessPhoneCtrl.text;
      _origAddressName = businessAddressCtrl.text;
      _origLat = selectedLat;
      _origLng = selectedLng;
      _origContactName = contactNameCtrl.text;
      _origContactPhone = contactPhoneCtrl.text;
      _origCrn = crnCtrl.text;

      if (mounted) {
        for (final ctrl in [nameCtrl, businessNameCtrl, businessPhoneCtrl,
                             businessAddressCtrl, contactNameCtrl, contactPhoneCtrl, crnCtrl]) {
          ctrl.addListener(_onAnyFieldChanged);
        }
        setState(() {});
      }

    } catch (e) {
      debugPrint("Error loading donor: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (donor == null) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final userChanged = nameCtrl.text != _origName;
      final donorFieldsChanged =
          businessNameCtrl.text != _origBusinessName ||
          businessPhoneCtrl.text != _origBusinessPhone ||
          contactNameCtrl.text != _origContactName ||
          contactPhoneCtrl.text != _origContactPhone ||
          crnCtrl.text != _origCrn;
      final addressChanged =
          businessAddressCtrl.text != _origAddressName ||
          selectedLat != _origLat ||
          selectedLng != _origLng;

      if (userChanged) {
        await _userService.updateUserProfile(name: nameCtrl.text);
      }

      String addressId = donor!.businessAddress.id;
      var address = donor!.businessAddress;

      if (addressChanged) {
        final hasAddress =
            addressId.isNotEmpty &&
            addressId.trim().isNotEmpty &&
            address.name.trim().isNotEmpty;

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
          final updatedAddress = address.copyWith(
            name: businessAddressCtrl.text,
            lat: selectedLat ?? address.lat,
            lng: selectedLng ?? address.lng,
          );
          await _addressService.updateAddress(updatedAddress);
          address = updatedAddress;
        }
      }

      if (donorFieldsChanged || addressChanged) {
        final updatedDonor = donor!.copyWith(
          businessName: businessNameCtrl.text,
          businessPhone: businessPhoneCtrl.text,
          contactName: contactNameCtrl.text,
          contactPhone: contactPhoneCtrl.text,
          crn: crnCtrl.text,
          businessAddress: address,
        );
        await _donorService.updateDonorProfile(updatedDonor);
      }

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "הפרטים נשמרו",
          message: "פרטיך עודכנו בהצלחה",
          buttonText: "סגור",
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.donor);

    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("שגיאה: $e")),
        );
      }
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [

                const SizedBox(height: HomepageTheme.topPadding),

                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: HomepageTheme.latetBlue, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text("עריכת פרטי תורם",
                          textAlign: TextAlign.center,
                          style: DonorEditProfileTheme.headerStyle),
                    ),
                    const SizedBox(width: 48),
                  ],
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
                        crn: crnCtrl,
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
                      ),

                      ContactDetailsCard(
                        contactName: contactNameCtrl,
                        contactPhone: contactPhoneCtrl,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: (_hasChanges && !_isSaving) ? _saveProfile : null,
                          style: ReportDonationTheme.simpleButton,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text("שמור"),
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
}