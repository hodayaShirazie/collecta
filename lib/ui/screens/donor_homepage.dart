// import 'package:collecta/ui/screens/report_donation.dart';
// import 'package:collecta/ui/screens/my_donations.dart';
// import 'package:flutter/material.dart';
// import '../../services/organization_service.dart';
// import '../../services/user_service.dart';
// import '../../data/models/organization_model.dart';
// import '../../data/models/donor_model.dart';
// import '../theme/homepage_theme.dart';
// import '../widgets/homepage_button.dart';
// import '../widgets/sign_out.dart';
// import '../widgets/layout_wrapper.dart';
// import 'package:collecta/app/routes.dart';

// class DonorHomepage extends StatelessWidget {
//   const DonorHomepage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userService = UserService();
//     final orgService = OrganizationService();

//     return Scaffold(
//       body: FutureBuilder<List<dynamic>>(
//         future: Future.wait([
//           orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
//           userService.fetchMyProfile("donor"),
//         ]),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("שגיאה: ${snapshot.error}"));
//           }

//           if (!snapshot.hasData) {
//             return const Center(child: Text("אין נתונים"));
//           }

//           final org = snapshot.data![0] as OrganizationModel;
//           final donor = DonorProfile.fromApi(
//             snapshot.data![1] as Map<String, dynamic>,
//           );

//           return LayoutWrapper(
//             child: Container(
//             decoration: BoxDecoration(gradient: HomepageTheme.pageGradient),
//             child: SafeArea(
//               child: Stack(
//                 children: [

//                   Positioned(
//                     top: -120,
//                     right: -80,
//                     child: Container(
//                       width: 300,
//                       height: 300,
//                       decoration: HomepageTheme.decorativeCircle,
//                     ),
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 25),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: HomepageTheme.topPadding),

//                         // Coins + Logout
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 8),
//                               decoration: HomepageTheme.coinsBoxDecoration,
//                               child: Row(
//                                 children: [
//                                   Image.asset(
//                                     'assets/images/logo/coins_logo.png',
//                                     height: HomepageTheme.coinLogoHeight,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     donor.coins.toString(),
//                                     style: HomepageTheme.coinsTextStyle,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             LogoutButton(parentContext: context),
//                           ],
//                         ),

//                         const SizedBox(height: 50),

//                         // Welcome
//                         Text(
//                           'היי, ${donor.user.name}',
//                           style: HomepageTheme.welcomeTextStyle,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'שמחים לראות אותך שוב!',
//                           style: HomepageTheme.subtitleTextStyle.copyWith(
//                             color: HomepageTheme.latetBlue.withOpacity(0.7),
//                           ),
//                         ),

//                         const SizedBox(height: 40),

//                         // Buttons
//                         Expanded(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               HomepageButton(
//                                 title: 'דיווח תרומה',
//                                 icon: Icons.volunteer_activism_outlined,
//                                 flipIcon: true,
//                                  onPressed: () {
//                                   Navigator.pushNamed(context, Routes.reportDonation);
//                                 },
//                               ),
//                               const SizedBox(height: HomepageTheme.betweenButtons),
//                               HomepageButton(
//                                 title: 'התרומות שלי',
//                                 icon: Icons.assignment_outlined,
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, Routes.myDonations);
//                                 },
//                               ),


//                               const SizedBox(height: HomepageTheme.betweenButtons),
//                               HomepageButton(
//                                 title: 'עריכת פרטים אישיים',
//                                 icon: Icons.edit_outlined,
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, Routes.donorEditProfile);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Department logo
//                         Image.network(
//                           org.departmentLogo ?? '',
//                           height: HomepageTheme.deptLogoHeight,
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ===================================================

import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../../services/donor_service.dart';
import '../../services/address_service.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/donor_model.dart';
import '../../data/models/address_model.dart';
import '../widgets/homepage_button.dart';
import '../widgets/sign_out.dart';
import '../widgets/layout_wrapper.dart';
import 'package:collecta/app/routes.dart';
import '../theme/homepage_theme.dart';
import '../widgets/donation_widgets/address_field.dart';
import '../utils/validators/business_id_validator.dart';
import '../utils/validators/phone_validator.dart';
import '../utils/profile_completion_flow.dart';

class DonorHomepage extends StatefulWidget {
  const DonorHomepage({super.key});

  static bool _pendingMissingFieldsCheck = false;

  static void markLoginSession() {
    _pendingMissingFieldsCheck = true;
  }

  @override
  State<DonorHomepage> createState() => _DonorHomepageState();
}

class _DonorHomepageState extends State<DonorHomepage> {
  final DonorService _donorService = DonorService();
  final UserService _userService = UserService();

  String? selectedAddressId;
  double? selectedLat;
  double? selectedLng;

  bool _didCheckMissing = false;

  void _checkMissingFields(DonorProfile donor) {
    if (!DonorHomepage._pendingMissingFieldsCheck) return;
    if (_didCheckMissing) return;
    final missing = donor.missingFields();
    DonorHomepage._pendingMissingFieldsCheck = false;
    if (missing.isEmpty) return;
    _didCheckMissing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileCompletionFlow.show(
        context: context,
        fields: missing,
        contentBuilder: _buildFieldContent,
        onSave: _saveField,
      );
    });
  }

  Widget _buildFieldContent(String field, TextEditingController controller) {
    if (field == "address") {
      return AddressFieldWidget(
        controller: controller,
        onLocationSelected: (lat, lng) {
          selectedLat = lat;
          selectedLng = lng;
        },
      );
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: _getLabel(field)),
      validator: (value) {
        switch (field) {
          case "crn":
            return validateBusinessId(value);
          case "businessPhone":
          case "contactPhone":
            return validatePhone(value);
          default:
            return (value == null || value.trim().isEmpty) ? "שדה חובה" : null;
        }
      },
    );
  }

  String _getLabel(String field) {
    switch (field) {
      case "businessName":
        return "שם העסק";
      case "businessPhone":
        return "טלפון העסק";
      case "address":
        return "כתובת";
      case "contactName":
        return "איש קשר";
      case "contactPhone":
        return "טלפון איש קשר";
      case "crn":
        return "ח.פ";
      case "name":
        return "שם";
      default:
        return field;
    }
  }

  Future<void> _saveField(String field, String value) async {
    final donor = await _donorService.getMyDonorProfile();
    DonorProfile updated = donor;

    switch (field) {
      case "address":
        AddressModel address;

        if (selectedAddressId == null || selectedAddressId!.isEmpty) {
          final id = await AddressService().createAddress(
            name: value,
            lat: selectedLat ?? 0,
            lng: selectedLng ?? 0,
          );
          address = AddressModel(
            id: id,
            name: value,
            lat: selectedLat ?? 0,
            lng: selectedLng ?? 0,
          );
        } else {
          address = AddressModel(
            id: selectedAddressId!,
            name: value,
            lat: selectedLat ?? 0,
            lng: selectedLng ?? 0,
          );
          await AddressService().updateAddress(address);
        }

        updated = donor.copyWith(businessAddress: address);
        selectedAddressId = null;
        selectedLat = null;
        selectedLng = null;
        break;

      case "businessName":
        updated = donor.copyWith(businessName: value);
        break;
      case "businessPhone":
        updated = donor.copyWith(businessPhone: value);
        break;
      case "contactName":
        updated = donor.copyWith(contactName: value);
        break;
      case "contactPhone":
        updated = donor.copyWith(contactPhone: value);
        break;
      case "crn":
        updated = donor.copyWith(crn: value);
        break;
      case "name":
        await _userService.updateUserProfile(name: value);
        return;
    }

    await _donorService.updateDonorProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    
    final userService = UserService();
    final orgService = OrganizationService();

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
          _donorService.getMyDonorProfile(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("שגיאה: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("אין נתונים"));
          }

          final org = snapshot.data![0] as OrganizationModel;
          final donor = snapshot.data![1] as DonorProfile;

          print("Business Address ID: '${donor.businessAddress.id}'");
          print("Business Address Name: '${donor.businessAddress.name}'");
          print("Missing fields: ${donor.missingFields()}");

          _checkMissingFields(donor);

          return LayoutWrapper(
            child: Container(
              decoration: BoxDecoration(gradient: HomepageTheme.pageGradient),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: -120,
                      right: -80,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: HomepageTheme.decorativeCircle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          const SizedBox(height: HomepageTheme.topPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: HomepageTheme.coinsBoxDecoration,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/logo/coins_logo.png',
                                      height: HomepageTheme.coinLogoHeight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(donor.coins.toString(), style: HomepageTheme.coinsTextStyle),
                                  ],
                                ),
                              ),
                              LogoutButton(parentContext: context),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Text('היי, ${donor.user.name}', style: HomepageTheme.welcomeTextStyle),
                          const SizedBox(height: 8),
                          Text(
                            'שמחים לראות אותך שוב!',
                            style: HomepageTheme.subtitleTextStyle.copyWith(
                              color: HomepageTheme.latetBlue.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HomepageButton(
                                  title: 'דיווח תרומה',
                                  icon: Icons.volunteer_activism_outlined,
                                  flipIcon: true,
                                  onPressed: () => Navigator.pushNamed(context, Routes.reportDonation),
                                ),
                                const SizedBox(height: HomepageTheme.betweenButtons),
                                HomepageButton(
                                  title: 'התרומות שלי',
                                  icon: Icons.assignment_outlined,
                                  onPressed: () => Navigator.pushNamed(context, Routes.myDonations),
                                ),
                                const SizedBox(height: HomepageTheme.betweenButtons),
                                HomepageButton(
                                  title: 'עריכת פרטים אישיים',
                                  icon: Icons.edit_outlined,
                                  onPressed: () => Navigator.pushNamed(context, Routes.donorEditProfile),
                                ),
                              ],
                            ),
                          ),
                          Image.network(org.departmentLogo ?? '', height: HomepageTheme.deptLogoHeight),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}