import 'package:firebase_auth/firebase_auth.dart';

class AuthHeaders {
  static Future<Map<String, String>> build() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
