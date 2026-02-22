import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/driver_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart';
import '../widgets/sign_out.dart';
import 'package:collecta/app/routes.dart';


class DriverHomepage extends StatelessWidget {
  const DriverHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final orgService = OrganizationService();

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
          userService.fetchMyProfile("driver"),
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
          final driver = DriverProfile.fromApi(
            snapshot.data![1] as Map<String, dynamic>,
          );

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

                        // Logout top-right
                        Align(
                          alignment: Alignment.topRight,
                          child: LogoutButton(parentContext: context),
                        ),

                        const SizedBox(height: 50),

                        // Welcome text
                        Text(
                          'היי, ${driver.user.name}',
                          style: HomepageTheme.welcomeTextStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '!שמחים לראות אותך שוב',
                          style: HomepageTheme.subtitleTextStyle.copyWith(
                            color: HomepageTheme.latetBlue.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Action buttons
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HomepageButton(
                                title: 'המסלול היומי',
                                icon: Icons.route_outlined,
                                flipIcon: true, 
                                onPressed: () {

                                },
                              ),
                              const SizedBox(height: HomepageTheme.betweenButtons),
                              HomepageButton(
                                title: 'עריכת פרטים',
                                icon: Icons.edit_outlined,
                                onPressed: () {
                                  // Navigator.pushNamed(context, Routes.driverEditProfile);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Department logo bottom
                        Image.network(
                          org.departmentLogo ?? '',
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
        },
      ),
    );
  }
}
