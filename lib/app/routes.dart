import 'package:flutter/material.dart';
import 'package:collecta/ui/screens/entering.dart';
import 'package:collecta/ui/screens/debug_firestore_screen.dart';
import 'package:collecta/ui/screens/donor_homepage.dart';
import 'package:collecta/ui/screens/driver_homepage.dart';
import 'package:collecta/ui/guards/auth_guard.dart';



class Routes {
  static const entering = '/entering';
  static const debug = '/debug';
  static const donor = '/donor';
  static const driver = '/driver';



  static Map<String, WidgetBuilder> routesMap = {
    entering: (context) => const EnteringScreen(),
    debug: (context) => const DebugFirestoreScreen(),
    donor: (context) => const AuthGuard(child: DonorHomepage()),
    driver: (context) => const AuthGuard(child: DriverHomepage()),
  };

}
