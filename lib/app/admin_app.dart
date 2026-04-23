import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:collecta/app/theme.dart';
import 'package:collecta/ui/screens/admin_homepage.dart';
import 'package:collecta/ui/screens/all_donation_admin.dart';
import 'package:collecta/ui/screens/all_driver_admin.dart';
import 'package:collecta/ui/screens/activity_zones_admin.dart';
import 'package:collecta/ui/screens/admin_entering.dart';
import 'package:collecta/ui/guards/admin_guard.dart';
import 'package:collecta/services/org_manager.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collecta Admin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/entering',
      routes: {
        '/entering': (context) => const AdminEnteringScreen(),
        '/admin': (context) => const AdminGuard(child: AdminHomepage()),
        '/admin/all-donations': (context) =>
            const AdminGuard(child: AllDonationsAdmin()),
        '/admin/all-drivers': (context) => AdminGuard(
              child: AllDriverAdmin(organizationId: OrgManager.orgId ?? ''),
            ),
        '/admin/activity-zones': (context) => AdminGuard(
              child: ActivityZonesAdmin(organizationId: OrgManager.orgId ?? ''),
            ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const AdminEnteringScreen(),
        settings: settings,
      ),
    );
  }
}
