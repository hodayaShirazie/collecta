// // // lib/app/app.dart
// // import 'package:flutter/material.dart';
// // import 'package:collecta/app/routes.dart';
// // import 'package:collecta/app/theme.dart';
// // import 'package:collecta/ui/screens/entering.dart';

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Collecta Firebase App',
// //       theme: AppTheme.lightTheme,           
// //       darkTheme: AppTheme.darkTheme,        
// //       initialRoute: Routes.entering,        
// //       routes: Routes.routesMap,        
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:collecta/app/routes.dart';
// import 'package:collecta/app/theme.dart';
// import 'package:collecta/ui/screens/entering.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Collecta Firebase App',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       initialRoute: Routes.entering,
//       routes: Routes.routesMap,
//       debugShowCheckedModeBanner: false,

//       locale: const Locale('he'),
//       supportedLocales: const [Locale('he')],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:collecta/app/routes.dart';
import 'package:collecta/app/theme.dart';
import 'package:collecta/ui/screens/entering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:collecta/ui/screens/edit_donation.dart';
import 'package:collecta/ui/guards/auth_guard.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collecta Firebase App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.entering,
      routes: Routes.routesMap, // routes רגילים
      debugShowCheckedModeBanner: false,

      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // -------------------------------
      // כאן נוסיף onGenerateRoute למסלולים דינמיים
      // -------------------------------
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

        // בדיקה אם זה מסלול edit-donation עם ID
        if (uri.pathSegments.length == 3 &&
            uri.pathSegments[0] == 'donor' &&
            uri.pathSegments[1] == 'edit-donation') {
          final donationId = uri.pathSegments[2];
          return MaterialPageRoute(
            builder: (context) => AuthGuard(
              child: EditDonation(donationId: donationId),
            ),
            settings: settings,
          );
        }

        // fallback לשאר המסלולים רגילים
        final builder = Routes.routesMap[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }

        // מסלול לא קיים
        return null;
      },
    );
  }
}