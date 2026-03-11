import 'package:flutter/material.dart';
import '../../services/driver_service.dart';
import '../../services/user_service.dart';
import '../../services/destination_service.dart';
import '../../services/address_service.dart';
import '../../services/places_service.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/lat_lng_model.dart';
import '../../data/models/place_prediction.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/address_autocomplete_field.dart';
import '../widgets/loading_indicator.dart';
import 'package:collecta/app/routes.dart';


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
  final PlacesService _placesService = PlacesService();

  DriverProfile? driver;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final areaCtrl = TextEditingController();

  final Map<String, TextEditingController> nameCtrls = {};
  final Map<String, TextEditingController> dayCtrls = {};
  final Map<String, TextEditingController> addressCtrls = {};

  final Map<String, LatLngModel?> selectedLatLng = {};
  final Map<String, List<PlacePrediction>> predictions = {};

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

        predictions[d.id] = [];
        selectedLatLng[d.id] = null;

      }

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("שגיאה בטעינת הפרופיל")),
      );

    }

  }

  Future<void> _searchAddress(String destId, String input) async {

    if (input.isEmpty) {
      setState(() => predictions[destId] = []);
      return;
    }

    final results = await _placesService.autocomplete(input);

    setState(() {
      predictions[destId] = results;
    });

  }

  Future<void> _selectPlace(String destId, PlacePrediction place) async {

    final details = await _placesService.getPlaceDetails(place.placeId);

    setState(() {

      addressCtrls[destId]!.text = place.description;

      selectedLatLng[destId] = details;

      predictions[destId] = [];

    });

  }

  Future<void> _saveProfile() async {

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("הפרטים עודכנו")),
      );
      Navigator.pushReplacementNamed(context, Routes.driver);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה: $e")),
      );

    }

    setState(() => isSaving = false);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: driver == null
          ? const LoadingIndicator()
          : SingleChildScrollView(

              child: Padding(

                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

                child: Column(

                  children: [

                    const SizedBox(height: 50),

                    const Text(
                      "עריכת פרטי נהג",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),
                    LabeledTextField(
                      label: "שם משתמש",
                      controller: nameCtrl,
                    ),

                    LabeledTextField(
                      label: "פלאפון",
                      controller: phoneCtrl,
                    ),

                    LabeledTextField(
                      label: "אזור",
                      controller: areaCtrl,
                    ),
                    const SizedBox(height: 30),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "יעדים",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Column(
                      children: driver!.destinations.map((destination) {

                        final id = destination.id;

                        return Card(

                          margin: const EdgeInsets.only(bottom: 16),

                          child: Padding(

                            padding: const EdgeInsets.all(12),

                            child: Column(

                              children: [

                                LabeledTextField(
                                  label: "שם יעד",
                                  controller: nameCtrls[id]!,
                                ),
                                LabeledTextField(
                                  label: "יום",
                                  controller: dayCtrls[id]!,
                                ),

                                AddressAutocompleteField(
                                  label: "כתובת",
                                  controller: addressCtrls[id]!,
                                  predictions: predictions[id]!,
                                  onChanged: (v) => _searchAddress(id, v),
                                  onSelect: (p) => _selectPlace(id, p),
                                ),
                              ],

                            ),

                          ),

                        );

                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveProfile,
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("שמור שינויים"),
                      ),
                    ),

                    const SizedBox(height: 40),

                  ],

                ),

              ),

            ),

    );

  }
}