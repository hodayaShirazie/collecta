// import 'package:flutter/material.dart';
// import '../../services/organization_service.dart';
// import '../../services/user_service.dart';
// import '../../data/models/organization_model.dart';
// import '../../data/models/driver_model.dart';
// import '../theme/homepage_theme.dart';
// import '../widgets/homepage_button.dart';
// import '../widgets/sign_out.dart';
// import 'package:collecta/app/routes.dart';
// import '../widgets/layout_wrapper.dart';


// class DriverHomepage extends StatelessWidget {
//   const DriverHomepage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userService = UserService();
//     final orgService = OrganizationService();

//     return Scaffold(
//       body: FutureBuilder<List<dynamic>>(
//         future: Future.wait([
//           orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
//           userService.fetchMyProfile("driver"),
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
//           final driver = DriverProfile.fromApi(
//             snapshot.data![1] as Map<String, dynamic>,
//           );

//           // return Container(
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

//                         // Logout top-right
//                         Align(
//                           alignment: Alignment.topRight,
//                           child: LogoutButton(parentContext: context),
//                         ),

//                         const SizedBox(height: 50),

//                         // Welcome text
//                         Text(
//                           'היי, ${driver.user.name}',
//                           style: HomepageTheme.welcomeTextStyle,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '!שמחים לראות אותך שוב',
//                           style: HomepageTheme.subtitleTextStyle.copyWith(
//                             color: HomepageTheme.latetBlue.withOpacity(0.7),
//                           ),
//                         ),

//                         const SizedBox(height: 40),

//                         // Action buttons
//                         Expanded(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               HomepageButton(
//                                 title: 'המסלול היומי',
//                                 icon: Icons.route_outlined,
//                                 flipIcon: true,
//                                 onPressed: () {

//                                 },
//                               ),
//                               const SizedBox(height: HomepageTheme.betweenButtons),
//                               HomepageButton(
//                                 title: 'עריכת פרטים',
//                                 icon: Icons.edit_outlined,
//                                 onPressed: () {
//                                   // Navigator.pushNamed(context, Routes.driverEditProfile);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Department logo bottom
//                         Image.network(
//                           org.departmentLogo ?? '',
//                           height: HomepageTheme.deptLogoHeight,
//                         ),
//                         const SizedBox(height: 20),
//                      ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/driver_service.dart';
import '../../services/user_service.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/driver_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart';
import '../widgets/sign_out.dart';
import '../widgets/layout_wrapper.dart';
import '../utils/profile_completion_flow.dart';
import '../utils/validators/phone_validator.dart';
import 'package:collecta/app/routes.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class DriverHomepage extends StatefulWidget {
  final DriverProfile? driver; // for admin view
  final bool isAdminImpersonating;

  const DriverHomepage({
    super.key,
    this.driver,
    this.isAdminImpersonating = false,
  });

  static bool _pendingMissingFieldsCheck = false;

  static void markLoginSession() {
    _pendingMissingFieldsCheck = true;
  }

  @override
  State<DriverHomepage> createState() => _DriverHomepageState();
}

class _DriverHomepageState extends State<DriverHomepage> {
  final DriverService _driverService = DriverService();
  final UserService _userService = UserService();

  bool _didCheckMissing = false;

  void _checkMissingFields(DriverProfile driver) {
    if (!DriverHomepage._pendingMissingFieldsCheck) return;
    if (_didCheckMissing) return;
    final missing = driver.missingFields();
    DriverHomepage._pendingMissingFieldsCheck = false;
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

  String _getLabel(String field) {
    switch (field) {
      case "name":
        return "שם";
      case "phone":
        return "טלפון";
      case "area":
        return "אזור";
      default:
        return field;
    }
  }

  Widget _buildFieldContent(String field, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: _getLabel(field)),
      validator: (value) {
        if (field == "phone") return validatePhone(value);
        return (value == null || value.trim().isEmpty) ? "שדה חובה" : null;
      },
    );
  }

  Future<void> _saveField(String field, String value) async {
    if (field == "name") {
      await _userService.updateUserProfile(name: value);
      return;
    }
    final driver = await _driverService.getMyDriverProfile();
    final updated = driver.copyWith(
      phone: field == "phone" ? value : null,
      area: field == "area" ? value : null,
    );
    await _driverService.updateDriverProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    final orgService = OrganizationService();
    final userService = UserService();

    // Admin view — driver passed directly, no missing-fields dialog
    if (widget.driver != null) {
      return Scaffold(
        body: FutureBuilder<OrganizationModel>(
          future: orgService.fetchOrganization(widget.driver!.user.organizationId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("שגיאה: ${snapshot.error}"));
            }
            return LayoutWrapper(
              child: _buildLayout(context, widget.driver!, organization: snapshot.data!),
            );
          },
        ),
      );
    }

    // Regular driver login
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          orgService.fetchOrganization(kOrganizationId),
          userService.fetchMyProfile("driver"),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("שגיאה: ${snapshot.error}"));
          }

          final org = snapshot.data![0] as OrganizationModel;
          final fetchedDriver =
              DriverProfile.fromApi(snapshot.data![1] as Map<String, dynamic>);

          _checkMissingFields(fetchedDriver);

          return LayoutWrapper(
            child: _buildLayout(context, fetchedDriver, organization: org),
          );
        },
      ),
    );
  }

  Widget _buildLayout(
    BuildContext context,
    DriverProfile driver, {
    OrganizationModel? organization,
  }) {
    return Container(
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
                  Align(
                    alignment: Alignment.topRight,
                    child: widget.isAdminImpersonating
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            tooltip: "חזרה לניהול",
                            onPressed: () => Navigator.pop(context),
                          )
                        : LogoutButton(parentContext: context),
                  ),
                  if (widget.isAdminImpersonating) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'מצב מנהל — צופה בנהג: ${driver.user.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'היי, ${driver.user.name}',
                    style: HomepageTheme.welcomeTextStyle,
                  ),
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
                          title: 'המסלול היומי',
                          icon: Icons.route_outlined,
                          flipIcon: true,
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.dailyRoutDriver);
                          },
                        ),
                        const SizedBox(height: HomepageTheme.betweenButtons),
                        HomepageButton(
                          title: 'עריכת פרטים',
                          icon: Icons.edit_outlined,
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.driverEditProfile);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (organization != null)
                    Image.network(
                      organization.departmentLogo ?? '',
                      height: HomepageTheme.deptLogoHeight,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
