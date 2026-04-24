import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/impersonation_manager.dart';

class AuthHeaders {
  static Future<Map<String, String>> build() async {
    final mgr = ImpersonationManager.instance;
    final crossSiteToken = mgr.adminToken;

    String token;
    if (crossSiteToken != null) {
      // Cross-site admin view: admin's token was passed via URL query param.
      // The Firebase session on this (driver) site is not set, so we use
      // the stored token directly.
      token = crossSiteToken;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      token = await user.getIdToken() ?? '';
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // When an admin is impersonating a driver, add the special header.
    // The server verifies the admin role and then applies all logic
    // as if the request came from the impersonated driver.
    final impersonatedId = mgr.impersonatedDriverId;
    if (impersonatedId != null) {
      headers['X-Impersonate-User'] = impersonatedId;
    }

    return headers;
  }
}
