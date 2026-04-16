import 'package:flutter/material.dart';

import '../../services/driver_service.dart';
import '../../services/user_service.dart';
import '../../services/destination_service.dart';
import '../../services/address_service.dart';
import '../../services/activity_zone_service.dart';

import '../../data/models/driver_model.dart';
import '../../data/models/lat_lng_model.dart';
import '../../data/models/activity_zone_model.dart';

import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';

import '../widgets/personal_details/driver_details_card.dart';
import '../widgets/personal_details/destination_card.dart';
import '../widgets/donation_widgets/card.dart';
import '../widgets/donation_widgets/section_title.dart';

import '../theme/homepage_theme.dart';
import '../theme/edit_profile_donor_theme.dart';
import '../theme/report_donation_theme.dart';

import '../widgets/custom_popup_dialog.dart';

import 'package:collecta/app/routes.dart';

const String _kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

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
  final ActivityZoneService _activityZoneService = ActivityZoneService();

  final _formKey = GlobalKey<FormState>();

  DriverProfile? driver;
  List<ActivityZoneModel> _allZones = [];
  List<String> _selectedAreaIds = [];

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final Map<String, TextEditingController> nameCtrls = {};
  final Map<String, TextEditingController> dayCtrls = {};
  final Map<String, TextEditingController> addressCtrls = {};

  final Map<String, LatLngModel?> selectedLatLng = {};

  bool isSaving = false;

  final GlobalKey _addAreaButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {

    try {

      final results = await Future.wait([
        _driverService.getMyDriverProfile(),
        _activityZoneService.getActivityZones(_kOrganizationId),
      ]);

      driver = results[0] as DriverProfile;
      _allZones = results[1] as List<ActivityZoneModel>;
      _selectedAreaIds = List<String>.from(driver!.areas);

      nameCtrl.text = driver!.user.name;
      phoneCtrl.text = driver!.phone;

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
        areas: _selectedAreaIds,
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
      Navigator.pushReplacementNamed(context, Routes.driver);

    } catch (e) {

      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("שגיאה: $e")),
        );
      }

    }

  }

  void _showAddAreaDropdown() {
    final remaining = _allZones
        .where((z) => !_selectedAreaIds.contains(z.id))
        .toList();

    if (remaining.isEmpty) return;

    final renderBox =
        _addAreaButtonKey.currentContext!.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
            renderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: remaining
          .map((zone) => PopupMenuItem<String>(
                value: zone.id,
                child: Text(zone.name),
              ))
          .toList(),
    ).then((selectedId) {
      if (selectedId != null) {
        setState(() {
          _selectedAreaIds.add(selectedId);
        });
      }
    });
  }

  Widget _buildAreasSection() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const SectionTitleWidget(text: "אזורי פעילות"),

          if (_selectedAreaIds.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "לא נבחרו אזורים",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _selectedAreaIds.map((id) {
                final zone = _allZones.firstWhere(
                  (z) => z.id == id,
                  orElse: () => ActivityZoneModel(
                    id: id,
                    name: id,
                    addressId: '',
                    range: 0,
                    organizationId: '',
                  ),
                );
                return Chip(
                  label: Text(zone.name),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _selectedAreaIds.remove(id);
                    });
                  },
                  backgroundColor: const Color(0xFFE8EDF6),
                  labelStyle: const TextStyle(
                    color: Color(0xFF2C5AA0),
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 8),

          Builder(builder: (ctx) {
            final allSelected = _allZones.isNotEmpty &&
                _selectedAreaIds.length >= _allZones.length;
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: _addAreaButtonKey,
                onPressed: allSelected ? null : _showAddAreaDropdown,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                label: const Text("הוסף אזור"),
                style: TextButton.styleFrom(
                  foregroundColor:
                      allSelected ? Colors.grey : const Color(0xFF2C5AA0),
                ),
              ),
            );
          }),

        ],
      ),
    );
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
                      ),

                      _buildAreasSection(),

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
