// // lib/app/app.dart
// import 'package:flutter/material.dart';
// import 'package:collecta/app/routes.dart';
// import 'package:collecta/app/theme.dart';
// import 'package:collecta/ui/screens/entering.dart';

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
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:collecta/app/routes.dart';
import 'package:collecta/app/theme.dart';
import 'package:collecta/ui/screens/entering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collecta Firebase App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.entering,
      routes: Routes.routesMap,
      debugShowCheckedModeBanner: false,

      // ✅ הוספה של localization כדי שתאריך יעבוד בכל מקום
      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
