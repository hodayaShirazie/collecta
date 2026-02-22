import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../../data/models/driver_model.dart';
import '../theme/homepage_theme.dart';
import '../theme/edit_profile_donor_theme.dart';


const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class DriverEditProfileScreen extends StatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  State<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {
  final orgService = OrganizationService();
  final userService = UserService();

  late Future _profileFuture;

  final phoneCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final destinationCtrl = TextEditingController();
  final stopsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future _loadProfile() async {
    final data = await userService.fetchMyProfile("driver");
    final driver = DriverProfile.fromApi(data);

    phoneCtrl.text = driver.phone;
    areaCtrl.text = driver.area;
    destinationCtrl.text = driver.destination.join(', ');
    stopsCtrl.text = driver.stops.join(', ');

    return driver;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: Future.wait([
          orgService.fetchOrganization(kOrganizationId),
          _profileFuture,
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final org = snapshot.data![0];

          return Container(
            decoration: BoxDecoration(gradient: HomepageTheme.pageGradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: HomepageTheme.decorativeCircle,
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Column(
                        children: [
                          const SizedBox(height: HomepageTheme.topPadding),
                          Image.network(org.logo, height: HomepageTheme.logoHeight),
                          const SizedBox(height: 10),
                          Text('עריכת פרטי נהג', style: DonorEditProfileTheme.headerStyle),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 6,
                            decoration: BoxDecoration(
                              color: HomepageTheme.latetYellow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '!שמחים לראות אותך שוב',
                            style: HomepageTheme.subtitleTextStyle.copyWith(
                              color: HomepageTheme.latetBlue.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            final widthFactor = screenWidth > 900
                                ? 0.6
                                : (screenWidth > 600 ? 0.8 : 0.95);
                            return Center(
                              child: FractionallySizedBox(
                                widthFactor: widthFactor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: DonorEditProfileTheme.primaryBlue, width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 8,
                                        decoration: BoxDecoration(
                                          color: HomepageTheme.latetYellow,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18),
                                          ),
                                        ),
                                        height: 1,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            children: [
                                              _buildLabeledField('פלאפון:', phoneCtrl),
                                              _buildLabeledField('אזור:', areaCtrl),
                                              _buildLabeledField('יעדים (מופרדים בפסיקים):', destinationCtrl),
                                              const SizedBox(height: 18),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: _save,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: DonorEditProfileTheme.primaryBlue,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 50, vertical: 14),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(25),
                                                    ),
                                                    textStyle: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    elevation: 5,
                                                  ),
                                                  child: const Text('שמור'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 30),
                          Image.network(org.departmentLogo, height: HomepageTheme.deptLogoHeight),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    try {
      await userService.updateDriverProfile(
        phone: phoneCtrl.text,
        area: areaCtrl.text,
        destination:
            destinationCtrl.text.split(',').map((e) => e.trim()).toList(),
        stops: stopsCtrl.text.split(',').map((e) => e.trim()).toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("הפרטים נשמרו בהצלחה")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה בשמירה: $e")),
      );
    }
  }

  Widget _buildLabeledField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: DonorEditProfileTheme.labelStyle),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: ctrl,
              textAlign: TextAlign.center,
              decoration: DonorEditProfileTheme.inputDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
