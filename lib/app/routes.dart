import 'package:collecta/ui/screens/all_driver_admin.dart';
import 'package:flutter/material.dart';
import 'package:collecta/ui/screens/entering.dart';
import 'package:collecta/ui/screens/debug_firestore_screen.dart';
import 'package:collecta/ui/screens/donor_homepage.dart';
import 'package:collecta/ui/screens/driver_homepage.dart';
import 'package:collecta/ui/guards/auth_guard.dart';
import 'package:collecta/ui/screens/edit_profile_donor.dart';
import 'package:collecta/ui/screens/admin_homepage.dart';
import 'package:collecta/ui/screens/edit_profile_driver.dart';
import 'package:collecta/ui/screens/report_donation.dart';
import 'package:collecta/ui/screens/my_donations.dart';
import 'package:collecta/ui/screens/all_donation_admin.dart';
import 'package:collecta/ui/screens/all_driver_admin.dart';
import 'package:collecta/ui/screens/edit_donation.dart';
import 'package:collecta/ui/screens/donor_profile_completion.dart';
import 'package:collecta/data/models/donor_model.dart';
import 'package:collecta/ui/screens/daily_route_driver.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';


class Routes {
  static const entering = '/entering';
  static const debug = '/debug';
  static const donor = '/donor';
  static const driver = '/driver';
  static const donorEditProfile = '/donor/edit-profile';
  static const admin = '/admin';  
  static const driverEditProfile = '/driver/edit-profile';
  static const reportDonation = '/donor/report-donation';
  static const myDonations = '/donor/my-donations';
  static const allDriverAdmin = '/admin/all-drivers';
  static const allDonationAdmin = '/admin/all-donations';
  static const editDonation = '/donor/edit-donation';
  static const completeProfile = '/complete-profile';
  static const dailyRoutDriver = '/driver/daily-route';


  static Map<String, WidgetBuilder> routesMap = {
    entering: (context) => const EnteringScreen(),
    debug: (context) => const DebugFirestoreScreen(),
    donor: (context) => const AuthGuard(child: DonorHomepage()),
    driver: (context) => const AuthGuard(child: DriverHomepage()),
    donorEditProfile: (context) => const AuthGuard(child: DonorEditProfileScreen()),
    admin: (context) => const AuthGuard(child: AdminHomepage()),
    driverEditProfile: (context) => const AuthGuard(child: DriverEditProfileScreen()),
    reportDonation: (context) => const AuthGuard(child: ReportDonation()),
    myDonations: (context) => const AuthGuard(child: MyDonations()),
    // allDriverAdmin: (context) => const AuthGuard(child: AllDriverAdmin()),
    allDonationAdmin: (context) => const AuthGuard(child: AllDonationsAdmin()),
      completeProfile: (context) {
    final donor = ModalRoute.of(context)!.settings.arguments as DonorProfile;
    return AuthGuard(child: DonorProfileCompletionScreen(donor: donor));    },    dailyRoutDriver: (context) => const AuthGuard(child: DailyRouteDriverPage()),
    

  };

}
