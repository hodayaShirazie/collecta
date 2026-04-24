import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/impersonation_manager.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdminImpersonating = ImpersonationManager.instance.isImpersonating;

    if (user == null && !isAdminImpersonating) {
      Future.microtask(() {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/entering', (route) => false);
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}
