import 'package:flutter/material.dart';
import 'package:collecta/ui/screens/entering.dart';
import 'package:collecta/ui/screens/debug_firestore_screen.dart';
import 'package:collecta/ui/screens/donor_homepage.dart';
import 'package:collecta/ui/screens/driver_homepage.dart';
import 'package:collecta/ui/guards/auth_guard.dart';
import 'package:collecta/ui/screens/edit_profile_donor.dart';
import 'package:collecta/ui/screens/edit_profile_driver.dart';



class Routes {
  static const entering = '/entering';
  static const debug = '/debug';
  static const donor = '/donor';
  static const driver = '/driver';
  static const donorEditProfile = '/donor/edit-profile';
  static const driverEditProfile = '/driver/edit-profile';





  static Map<String, WidgetBuilder> routesMap = {
    entering: (context) => const EnteringScreen(),
    debug: (context) => const DebugFirestoreScreen(),
    donor: (context) => const AuthGuard(child: DonorHomepage()),
    driver: (context) => const AuthGuard(child: DriverHomepage()),
    donorEditProfile: (context) => const AuthGuard(child: DonorEditProfileScreen()),
    driverEditProfile: (context) => const AuthGuard(child: DriverEditProfileScreen()),

  };

}
