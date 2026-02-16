import 'package:collecta/ui/screens/edit_profile_donor.dart';
import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart'; 

class DonorHomepage extends StatelessWidget {
  const DonorHomepage({super.key});

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
                // ניקוד ומטבעות
                Positioned(
                  top: 15,
                  left: 20,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo/coins_logo.png', 
                        height: 35, 
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '452', 
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.network(org.logo, height: 110),
                    const SizedBox(height: 20),
                    const Text('היי, בני', style: HomepageTheme.welcomeTextStyle),
                    
                    const Spacer(),

                    // שימוש בכפתורים החדשים
                    HomepageButton(
                      title: 'דיווח תרומה',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => print('מעבר לדיווח'),
                    ),
                    const SizedBox(height: 25),
                    HomepageButton(
                      title: 'התרומות שלי',
                      icon: Icons.assignment_outlined,
                      onPressed: () => print('מעבר להיסטוריה'),
                    ),
                    const SizedBox(height: 25),
                    HomepageButton(
                      title: 'עריכת פרטים אישיים',
                      icon: Icons.edit_outlined,
                      // onPressed: () => print('מעבר לעריכה'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DonorEditProfileScreen(),
                          ),
                        );
                      },
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