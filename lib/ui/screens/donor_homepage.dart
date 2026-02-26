// import 'package:collecta/ui/screens/edit_profile_donor.dart';
// import 'package:flutter/material.dart';
// import '../../services/organization_service.dart';
// import '../../services/user_service.dart';
// import '../../data/models/organization_model.dart';
// import '../../data/models/donor_model.dart';
// import '../theme/homepage_theme.dart';
// import '../widgets/homepage_button.dart'; 
// import '../widgets/sign_out.dart'; 

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

//           return SafeArea(
//             child: Stack(
//               children: [
//                 // Coins top-left
//                 Positioned(
//                   top: 15,
//                   left: 20,
//                   child: Row(
//                     children: [
//                       Image.asset(
//                         'assets/images/logo/coins_logo.png',
//                         height: HomepageTheme.coinLogoHeight,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         donor.coins.toString(),
//                         style: HomepageTheme.coinsTextStyle,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Logout top-right
//                 Positioned(
//                   top: 15,
//                   right: 20,
//                   child: LogoutButton(parentContext: context),
//                 ),

//                 // Main content column
//                 Column(
//                   children: [
//                     const SizedBox(height: HomepageTheme.topPadding),

//                     // Organization logo
//                     Image.network(
//                       org.logo ?? '',
//                       height: HomepageTheme.logoHeight,
//                     ),
//                     const SizedBox(height: 20),

//                     // Welcome text
//                     Text(
//                       'היי, ${donor.user.name}',
//                       style: HomepageTheme.welcomeTextStyle,
//                     ),

//                     const Spacer(),

//                     // Action buttons
//                     HomepageButton(
//                       title: 'דיווח תרומה',
//                       icon: Icons.chat_bubble_outline,
//                       onPressed: () {},
//                     ),
//                     const SizedBox(height: HomepageTheme.spacerHeight),
//                     HomepageButton(
//                       title: 'התרומות שלי',
//                       icon: Icons.assignment_outlined,
//                       onPressed: () {},
//                     ),

//                     const Spacer(),

//                     // Department logo bottom
//                     Image.network(
//                       org.departmentLogo ?? '',
//                       height: HomepageTheme.deptLogoHeight,
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// import 'package:collecta/ui/screens/edit_profile_donor.dart';
import 'package:collecta/ui/screens/report_donation.dart';
import 'package:collecta/ui/screens/my_donations.dart';
import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/donor_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart';
import '../widgets/sign_out.dart';
import 'package:collecta/app/routes.dart';

class DonorHomepage extends StatelessWidget {
  const DonorHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final orgService = OrganizationService();

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
          userService.fetchMyProfile("donor"),
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
          final donor = DonorProfile.fromApi(
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

                        // Coins + Logout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: HomepageTheme.coinsBoxDecoration,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/logo/coins_logo.png',
                                    height: HomepageTheme.coinLogoHeight,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    donor.coins.toString(),
                                    style: HomepageTheme.coinsTextStyle,
                                  ),
                                ],
                              ),
                            ),
                            LogoutButton(parentContext: context),
                          ],
                        ),

                        const SizedBox(height: 50),

                        // Welcome
                        Text(
                          'היי, ${donor.user.name}',
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

                        // Buttons
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HomepageButton(
                                title: 'דיווח תרומה',
                                icon: Icons.volunteer_activism_outlined,
                                flipIcon: true,
                                 onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => const ReportDonation(),
                                  //   ),
                                  // );
                                },
                              ),
                              const SizedBox(height: HomepageTheme.betweenButtons),
                              HomepageButton(
                                title: 'התרומות שלי',
                                icon: Icons.assignment_outlined,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyDonations(),
                                    ),
                                  );

                                },
                              ),


                              const SizedBox(height: HomepageTheme.betweenButtons),
                              HomepageButton(
                                title: 'עריכת פרטים אישיים',
                                icon: Icons.edit_outlined,
                                onPressed: () {
                                  Navigator.pushNamed(context, Routes.donorEditProfile);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Department logo
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