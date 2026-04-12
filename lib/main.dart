// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'config/firebase_options.dart';
// import 'app/app.dart';  
// import 'package:flutter_dotenv/flutter_dotenv.dart';  

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: "assets/config/.env");
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:app_links/app_links.dart';
import 'services/org_manager.dart';

final AppLinks _appLinks = AppLinks();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/config/.env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🟢 קולט לינק לפני שהאפליקציה עולה
  await initDeepLinks();

  runApp(const MyApp());
}

Future<void> initDeepLinks() async {
  try {
    // 🔵 אם האפליקציה נפתחה דרך קישור
    final uri = await _appLinks.getInitialLink();

    if (uri != null) {
      final orgId = uri.queryParameters['orgId'];

      if (orgId != null) {
        await OrgManager.saveOrgId(orgId);
      }
    }

    // 🔵 אם מתקבל קישור כשהאפליקציה כבר פתוחה
    _appLinks.uriLinkStream.listen((uri) async {
      if (uri != null) {
        final orgId = uri.queryParameters['orgId'];

        if (orgId != null) {
          await OrgManager.saveOrgId(orgId);
        }
      }
    });
  } catch (e) {
    print("Deep link error: $e");
  }
}