import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class LogoutButton extends StatelessWidget {
  final BuildContext parentContext;

  const LogoutButton({super.key, required this.parentContext});

  Future<void> _signOut() async {
    try {
      if (!kIsWeb) {
        // התנתקות ממובייל
        final googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
      
      // התנתקות מ-Firebase
      await FirebaseAuth.instance.signOut();

      // נווט חזרה לדף הכניסה ומחק את ההיסטוריה
      Navigator.of(parentContext)
          .pushNamedAndRemoveUntil('/entering', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: "התנתקות",
      onPressed: _signOut,
    );
  }
}
