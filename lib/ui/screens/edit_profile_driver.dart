import 'package:flutter/material.dart';

import '../../services/driver_service.dart';
import '../../services/user_service.dart';
import '../../services/destination_service.dart';
import '../../services/address_service.dart';

import '../../data/models/driver_model.dart';
import '../../data/models/lat_lng_model.dart';

import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';

import '../widgets/personal_details/driver_details_card.dart';
import '../widgets/personal_details/destination_card.dart';

import '../theme/homepage_theme.dart';
import '../theme/edit_profile_donor_theme.dart';
import '../theme/report_donation_theme.dart';

import '../widgets/custom_popup_dialog.dart';

import 'package:collecta/app/routes.dart';
import '../../services/impersonation_manager.dart';

class DriverEditProfileScreen extends StatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  State<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {

  final DriverService _driverService = DriverService();
  final UserService _userService = UserService();
  final DestinationService _destinationService = DestinationService();
  final AddressService _addressService = AddressService();

  final _formKey = GlobalKey<FormState>();

  DriverProfile? driver;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final areaCtrl = TextEditingController();

  final Map<String, TextEditingController> nameCtrls = {};
  final Map<String, TextEditingController> dayCtrls = {};
  final Map<String, TextEditingController> addressCtrls = {};

  final Map<String, LatLngModel?> selectedLatLng = {};

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {

    try {

      driver = await _driverService.getMyDriverProfile();

      nameCtrl.text = driver!.user.name;
      phoneCtrl.text = driver!.phone;
      areaCtrl.text = driver!.area;

      for (var d in driver!.destinations) {

        nameCtrls[d.id] = TextEditingController(text: d.name);
        dayCtrls[d.id] = TextEditingController(text: d.day);
        addressCtrls[d.id] = TextEditingController(text: d.address.name);

        selectedLatLng[d.id] = null;

      }

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("שגיאה בטעינת הפרופיל")),
      );

    }

  }

  Future<void> _saveProfile() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (driver == null) return;

    setState(() => isSaving = true);

    try {

      await _userService.updateUserProfile(
        name: nameCtrl.text,
      );

      final updatedDriver = driver!.copyWith(
        phone: phoneCtrl.text,
        area: areaCtrl.text,
      );

      await _driverService.updateDriverProfile(updatedDriver);

      for (var destination in driver!.destinations) {

        final id = destination.id;

        final updatedAddress = destination.address.copyWith(
          name: addressCtrls[id]!.text,
          lat: selectedLatLng[id]?.lat ?? destination.address.lat,
          lng: selectedLatLng[id]?.lng ?? destination.address.lng,
        );

        await _addressService.updateAddress(updatedAddress);

        final updatedDestination = destination.copyWith(
          name: nameCtrls[id]!.text,
          day: dayCtrls[id]!.text,
          address: updatedAddress,
        );

        await _destinationService.updateDestination(updatedDestination);

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
      // When an admin is impersonating, go back to the driver homepage
      // instead of navigating to the regular driver route.
      if (ImpersonationManager.instance.isImpersonating) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, Routes.driver);
      }

    } catch (e) {

      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("שגיאה: $e")),
        );
      }

    }

  }

  @override
  Widget build(BuildContext context) {

    if (driver == null) {
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

                const Text(
                  "עריכת פרטי נהג",
                  style: DonorEditProfileTheme.headerStyle,
                ),

                const SizedBox(height: 35),

                Form(

                  key: _formKey,

                  child: Column(

                    children: [

                      DriverDetailsCard(
                        name: nameCtrl,
                        phone: phoneCtrl,
                        area: areaCtrl,
                      ),

                      const SizedBox(height: 15),

                      ...driver!.destinations.map((destination) {

                        final id = destination.id;

                        return DestinationCard(
                          name: nameCtrls[id]!,
                          day: dayCtrls[id]!,
                          address: addressCtrls[id]!,
                          onLocationSelected: (lat, lng) {

                            selectedLatLng[id] =
                                LatLngModel(lat: lat, lng: lng);

                          },
                        );

                      }).toList(),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveProfile,
                          style: ReportDonationTheme.simpleButton,
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

    );

  }

}