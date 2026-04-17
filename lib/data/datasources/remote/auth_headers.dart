import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/impersonation_manager.dart';

class AuthHeaders {
  static Future<Map<String, String>> build() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // When an admin is impersonating a driver, add the special header.
    // The server verifies the admin role and then applies all logic
    // as if the request came from the impersonated driver.
    final impersonatedId = ImpersonationManager.instance.impersonatedDriverId;
    if (impersonatedId != null) {
      headers['X-Impersonate-User'] = impersonatedId;
    }

    return headers;
  }
}
