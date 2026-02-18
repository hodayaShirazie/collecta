// import 'package:flutter/material.dart';
// import '../../services/organization_service.dart';
// import '../theme/homepage_theme.dart';
// import '../widgets/homepage_button.dart'; 
// import '../widgets/sign_out.dart';

// class DriverHomepage extends StatelessWidget {
//   const DriverHomepage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final orgService = OrganizationService();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FutureBuilder(
//         future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final org = snapshot.data!;

//           return SafeArea(
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 15,
//                   right: 20,
//                   child: LogoutButton(parentContext: context), // כאן הקומפוננטה שיצרת
//                 ),
              
//                 Column(
//                   children: [
//                     const SizedBox(height: 50),
//                     Image.network(org.logo, height: 110),
//                     const SizedBox(height: 20),
//                     const Text('היי, חן', style: HomepageTheme.welcomeTextStyle),
                    
//                     const Spacer(),

//                     // שימוש בכפתורים החדשים
//                     HomepageButton(
//                       title: 'עריכת פרטים',
//                       icon: Icons.chat_bubble_outline,
//                       onPressed: () => print('עריכת פרטים'),
//                     ),
//                     const SizedBox(height: 25),
//                     HomepageButton(
//                       title: 'המסלול היומי',
//                       icon: Icons.assignment_outlined,
//                       onPressed: () => print('המסלול היומי'),
//                     ),

//                     const Spacer(),

//                     Image.network(org.departmentLogo, height: 60),
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

import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/driver_model.dart';
import '../theme/homepage_theme.dart';
import '../widgets/homepage_button.dart'; 
import '../widgets/sign_out.dart';

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

          return SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  right: 20,
                  child: LogoutButton(parentContext: context),
                ),

                Column(
                  children: [
                    const SizedBox(height: 50),

                    CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(driver.user.img),
                    ),

                    const SizedBox(height: 12),

                    Text('היי, ${driver.user.name}', style: HomepageTheme.welcomeTextStyle),

                    const SizedBox(height: 6),
                    Text(
                      driver.area.isNotEmpty ? 'אזור: ${driver.area}' : 'לא הוגדר אזור',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      driver.phone.isNotEmpty ? 'טלפון: ${driver.phone}' : 'לא הוגדר טלפון',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const Spacer(),

                    HomepageButton(
                      title: 'המסלול היומי',
                      icon: Icons.route_outlined,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 25),

                    HomepageButton(
                      title: 'עריכת פרטים',
                      icon: Icons.edit_outlined,
                      onPressed: () {},
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
