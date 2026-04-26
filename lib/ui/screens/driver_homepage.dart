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
import '../../services/activity_zone_service.dart';
import '../../services/org_manager.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/activity_zone_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart';
import '../widgets/sign_out.dart';
import '../widgets/layout_wrapper.dart';
import '../utils/profile_completion_flow.dart';
import '../utils/validators/phone_validator.dart';
import 'package:collecta/app/routes.dart';
import '../widgets/custom_popup_dialog.dart';

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
  final ActivityZoneService _activityZoneService = ActivityZoneService();

  bool _didCheckMissing = false;

  void _checkMissingFields(DriverProfile driver) {
    if (!DriverHomepage._pendingMissingFieldsCheck) return;
    if (_didCheckMissing) return;
    final missing = driver.missingFields();
    DriverHomepage._pendingMissingFieldsCheck = false;
    if (missing.isEmpty) return;
    _didCheckMissing = true;

    final regularFields = missing.where((f) => f != 'area').toList();
    final hasAreaMissing = missing.contains('area');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (regularFields.isNotEmpty) {
        ProfileCompletionFlow.show(
          context: context,
          fields: regularFields,
          contentBuilder: _buildFieldContent,
          onSave: _saveField,
          onComplete: hasAreaMissing ? () => _showactivityZoneelectionDialog(driver) : null,
        );
      } else if (hasAreaMissing) {
        _showactivityZoneelectionDialog(driver);
      }
    });
  }

  void _showactivityZoneelectionDialog(DriverProfile driver) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _activityZoneelectionDialog(
        driver: driver,
        activityZoneService: _activityZoneService,
        driverService: _driverService,
      ),
    );
  }

  String _getLabel(String field) {
    switch (field) {
      case "name":
        return "שם";
      case "phone":
        return "טלפון";
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

    // Regular driver login (also used for cross-site admin impersonation)
    final orgId = OrgManager.orgId ?? kOrganizationId;
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          orgService.fetchOrganization(orgId),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: HomepageTheme.latetBlue.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: HomepageTheme.latetBlue.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined,
                              color: HomepageTheme.latetBlue.withValues(alpha: 0.6),
                              size: 14),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'צופה בפרופיל של ${driver.user.name}',
                              style: TextStyle(
                                color: HomepageTheme.latetBlue.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                fontFamily: 'Assistant',
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
                            Navigator.pushNamed(context, Routes.driverEditProfile)
                                .then((_) { if (mounted) setState(() {}); });
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

// ─── דיאלוג בחירת אזורי פעילות (נפתח מיד, טוען בפנים) ────────────────────
class _activityZoneelectionDialog extends StatefulWidget {
  final DriverProfile driver;
  final ActivityZoneService activityZoneService;
  final DriverService driverService;

  const _activityZoneelectionDialog({
    required this.driver,
    required this.activityZoneService,
    required this.driverService,
  });

  @override
  State<_activityZoneelectionDialog> createState() => _activityZoneelectionDialogState();
}

class _activityZoneelectionDialogState extends State<_activityZoneelectionDialog> {
  List<ActivityZoneModel>? zones;
  final List<String> selectedIds = [];
  bool isSaving = false;

  final GlobalKey _addBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final result = await widget.activityZoneService
          .getActivityZones(widget.driver.user.organizationId);
      if (mounted) setState(() => zones = result);
    } catch (_) {
      if (mounted) setState(() => zones = []);
    }
  }

  void _showDropdown() {
    final currentDriverId = widget.driver.user.id;
    final remaining = (zones ?? [])
        .where((z) =>
            !selectedIds.contains(z.id) &&
            (z.driverId.isEmpty || z.driverId == currentDriverId))
        .toList();
    if (remaining.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const CustomPopupDialog(
          title: "אין אזורים פנויים",
          message: "כל אזורי הפעילות תפוסים כרגע. פנה למנהל.",
        ),
      );
      return;
    }

    final renderBox =
        _addBtnKey.currentContext!.findRenderObject() as RenderBox;
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
          .map((z) => PopupMenuItem<String>(value: z.id, child: Text(z.name)))
          .toList(),
    ).then((id) {
      if (id != null) setState(() => selectedIds.add(id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDriverId = widget.driver.user.id;
    final availableZones = (zones ?? [])
        .where((z) => z.driverId.isEmpty || z.driverId == currentDriverId)
        .toList();
    final allSelected =
        availableZones.isNotEmpty && selectedIds.length >= availableZones.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "השלמת פרטים",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: zones == null
            ? const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "בחר אזורי פעילות",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  if (zones!.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("לא הוגדרו אזורי פעילות בארגון. פנה למנהל.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else if (availableZones.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("כל אזורי הפעילות תפוסים כרגע. פנה למנהל.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else ...[
                    if (selectedIds.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: selectedIds.map((id) {
                          final zone = zones!.firstWhere((z) => z.id == id,
                              orElse: () => ActivityZoneModel(
                                  id: id,
                                  name: id,
                                  addressId: '',
                                  range: 0,
                                  organizationId: ''));
                          return Chip(
                            label: Text(zone.name,
                                style: const TextStyle(
                                    color: Color(0xFF2C5AA0),
                                    fontWeight: FontWeight.w500)),
                            deleteIcon:
                                const Icon(Icons.close, size: 15),
                            onDeleted: () =>
                                setState(() => selectedIds.remove(id)),
                            backgroundColor: const Color(0xFFE8EDF6),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      key: _addBtnKey,
                      onPressed: allSelected ? null : _showDropdown,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      label: const Text("הוסף אזור"),
                      style: TextButton.styleFrom(
                        foregroundColor: allSelected
                            ? Colors.grey
                            : const Color(0xFF2C5AA0),
                      ),
                    ),
                  ],
                ],
              ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            child: const Text("דלג"),
          ),
          ElevatedButton(
            onPressed: isSaving
                ? null
                : () async {
                    setState(() => isSaving = true);
                    if (selectedIds.isNotEmpty) {
                      final updated =
                          widget.driver.copyWith(activityZone: selectedIds);
                      await widget.driverService.updateDriverProfile(updated);
                    }
                    if (mounted) Navigator.pop(context);
                  },
            child: const Text("שמור"),
          ),
        ],
      ),
    );
  }
}
