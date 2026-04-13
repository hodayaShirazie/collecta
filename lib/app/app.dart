import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_links/app_links.dart';
import 'package:collecta/app/routes.dart';
import 'package:collecta/app/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:collecta/ui/screens/edit_donation.dart';
import 'package:collecta/ui/guards/auth_guard.dart';
import '../services/org_manager.dart';

/// Global navigator key used to navigate from outside the widget tree
/// (e.g. when a deep link arrives while the app is already open).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for deep links while the app is already running (mobile only).
    // Cold-start links are handled in main() before runApp.
    if (!kIsWeb) {
      _initLinkStream();
    }
  }

  void _initLinkStream() {
    final appLinks = AppLinks();
    _linkSubscription = appLinks.uriLinkStream.listen((uri) async {
      final orgId = uri.queryParameters['orgId'];
      if (orgId != null && orgId.isNotEmpty) {
        await OrgManager.saveOrgId(orgId);
        // Navigate to entering screen so it reloads with the new org
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Routes.entering,
          (_) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Collecta Firebase App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.entering,
      routes: Routes.routesMap,
      debugShowCheckedModeBanner: false,

      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

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

        final builder = Routes.routesMap[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
