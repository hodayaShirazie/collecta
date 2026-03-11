import 'package:flutter/material.dart';
import '../../services/donor_service.dart';
import '../theme/edit_profile_donor_theme.dart';
import '../theme/homepage_theme.dart';
import '../../data/models/donor_model.dart';
import 'package:collecta/app/routes.dart';
import '../../services/places_service.dart';
import '../../services/user_service.dart';
import '../../services/address_service.dart';
import '../../data/models/lat_lng_model.dart';
import '../../data/models/place_prediction.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/address_autocomplete_field.dart';
import '../widgets/loading_indicator.dart';

class DonorEditProfileScreen extends StatefulWidget {
  const DonorEditProfileScreen({super.key});

  @override
  State<DonorEditProfileScreen> createState() => _DonorEditProfileScreenState();
}

class _DonorEditProfileScreenState extends State<DonorEditProfileScreen> {
  final DonorService _donorService = DonorService();
  final PlacesService _placesService = PlacesService();
  final AddressService _addressService = AddressService();
  final UserService _userService = UserService();


  DonorProfile? donor;

  LatLngModel? selectedLatLng;
  List<PlacePrediction> predictions = [];

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
      businessAddressCtrl.text = donor!.businessAddress.name;
      contactNameCtrl.text = donor!.contactName;
      contactPhoneCtrl.text = donor!.contactPhone;
      crnCtrl.text = donor!.crn;

      setState(() {});
    } catch (e) {
      print("Error loading donor: $e");
    }
  }

  Future<void> _searchAddress(String input) async {
    if (input.isEmpty) {
        setState(() => predictions = []);
        return;
    }

    final results = await _placesService.autocomplete(input);

    setState(() {
        predictions = results;
    });
  }

  Future<void> _selectPlace(PlacePrediction place) async {

    final details = await _placesService.getPlaceDetails(place.placeId);

    setState(() {
        businessAddressCtrl.text = place.description;
        selectedLatLng = details;
        predictions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: donor == null
          ? const LoadingIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  children: [
                    const SizedBox(height: HomepageTheme.topPadding),
                    Text('עריכת פרטי תורם', style: DonorEditProfileTheme.headerStyle),
                    const SizedBox(height: 20),

                    LabeledTextField(
                      label: 'שם משתמש:',
                      controller: nameCtrl,
                      labelStyle: DonorEditProfileTheme.labelStyle,
                      decoration: DonorEditProfileTheme.inputDecoration,
                    ),

                    LabeledTextField(
                      label: 'שם העסק:',
                      controller: businessNameCtrl,
                      labelStyle: DonorEditProfileTheme.labelStyle,
                      decoration: DonorEditProfileTheme.inputDecoration,
                    ),

                    LabeledTextField(
                      label: 'פלאפון עסק:',
                      controller: businessPhoneCtrl,
                      labelStyle: DonorEditProfileTheme.labelStyle,
                      decoration: DonorEditProfileTheme.inputDecoration,
                    ),

                    AddressAutocompleteField(
                    label: 'כתובת העסק:',
                    controller: businessAddressCtrl,
                    predictions: predictions,
                    onChanged: _searchAddress,
                    onSelect: _selectPlace,
                  ),

                  LabeledTextField(
                    label: 'שם איש קשר:',
                    controller: contactNameCtrl,
                    labelStyle: DonorEditProfileTheme.labelStyle,
                    decoration: DonorEditProfileTheme.inputDecoration,
                  ),
                  LabeledTextField(
                    label: 'פלאפון איש קשר:',
                    controller: contactPhoneCtrl,
                    labelStyle: DonorEditProfileTheme.labelStyle,
                    decoration: DonorEditProfileTheme.inputDecoration,
                  ),
                  LabeledTextField(
                    label: 'ח״פ/עוסק מורשה:',
                    controller: crnCtrl,
                    labelStyle: DonorEditProfileTheme.labelStyle,
                    decoration: DonorEditProfileTheme.inputDecoration,
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: DonorEditProfileTheme.saveButtonStyle,
                      child: const Text('שמור'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
  Future<void> _saveProfile() async {

    if (donor == null) return;

    try {

        await UserService().updateUserProfile(
        name: nameCtrl.text,
        );

        final updatedAddress = donor!.businessAddress.copyWith(
        name: businessAddressCtrl.text,
        lat: selectedLatLng?.lat ?? donor!.businessAddress.lat,
        lng: selectedLatLng?.lng ?? donor!.businessAddress.lng,
        );

        await _addressService.updateAddress(updatedAddress);

        final updatedDonor = donor!.copyWith(
        businessName: businessNameCtrl.text,
        businessPhone: businessPhoneCtrl.text,
        contactName: contactNameCtrl.text,
        contactPhone: contactPhoneCtrl.text,
        crn: crnCtrl.text,
        businessAddress: updatedAddress,
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

}