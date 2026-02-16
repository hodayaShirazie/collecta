import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart'; 
import '../widgets/sign_out.dart';

class DriverHomepage extends StatelessWidget {
  const DriverHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final orgService = OrganizationService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final org = snapshot.data!;

          return SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  right: 20,
                  child: LogoutButton(parentContext: context), // כאן הקומפוננטה שיצרת
                ),
              
                Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.network(org.logo, height: 110),
                    const SizedBox(height: 20),
                    const Text('היי, חן', style: HomepageTheme.welcomeTextStyle),
                    
                    const Spacer(),

                    // שימוש בכפתורים החדשים
                    HomepageButton(
                      title: 'עריכת פרטים',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => print('עריכת פרטים'),
                    ),
                    const SizedBox(height: 25),
                    HomepageButton(
                      title: 'המסלול היומי',
                      icon: Icons.assignment_outlined,
                      onPressed: () => print('המסלול היומי'),
                    ),

                    const Spacer(),

                    Image.network(org.departmentLogo, height: 60),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}