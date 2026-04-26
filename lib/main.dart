import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'services/org_manager.dart';
import 'services/admin_view_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/config/.env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Web: OrgManager.init() reads orgId from Uri.base (the browser URL)
  // Mobile: also reads from SharedPreferences (previously saved)
  await OrgManager.init();

  // Web: check if admin opened driver site via cross-site redirect
  AdminViewManager.readFromUrl();
  debugPrint('[AdminView] main: hasPendingView=${AdminViewManager.hasPendingView} '
      'url=${Uri.base}');

  // Mobile only: handle cold-start deep link (app opened via link)
  if (!kIsWeb) {
    await _handleInitialDeepLink();
  }

  runApp(const MyApp());
}

/// Handles the case where the app is cold-started by tapping a deep link.
/// Saves the orgId from the link so OrgManager has it ready before the UI loads.
Future<void> _handleInitialDeepLink() async {
  try {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      final orgId = uri.queryParameters['orgId'];
      if (orgId != null && orgId.isNotEmpty) {
        await OrgManager.saveOrgId(orgId);
      }
    }
  } catch (e) {
    debugPrint('Deep link init error: $e');
  }
}
