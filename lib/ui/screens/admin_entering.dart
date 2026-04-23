import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/admin_service.dart';
import '../../services/org_manager.dart';
import '../widgets/custom_popup_dialog.dart';

class AdminEnteringScreen extends StatefulWidget {
  const AdminEnteringScreen({super.key});

  @override
  State<AdminEnteringScreen> createState() => _AdminEnteringScreenState();
}

class _AdminEnteringScreenState extends State<AdminEnteringScreen> {
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  // אם המשתמש כבר מחובר ויש orgId שמור — עובר ישירות לדף האדמין
  Future<void> _tryAutoLogin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final orgId = OrgManager.orgId;
    if (orgId != null && orgId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin', (_) => false);
        }
      });
      return;
    }

    // מחובר ל-Firebase אבל אין orgId שמור — מאמת דרך ה-Service
    setState(() => _isSigningIn = true);
    await _verifyAndNavigate();
  }

  Future<void> _signInAsAdmin() async {
    setState(() => _isSigningIn = true);
    try {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      final credential =
          await FirebaseAuth.instance.signInWithPopup(provider);

      if (credential.user == null) {
        setState(() => _isSigningIn = false);
        return;
      }

      await _verifyAndNavigate();
    } catch (e) {
      if (e is FirebaseAuthException &&
          (e.code == 'popup-closed-by-user' || e.code == 'canceled')) {
        setState(() => _isSigningIn = false);
        return;
      }
      if (mounted) {
        setState(() => _isSigningIn = false);
        _showError('שגיאה בהתחברות. נסה שוב.');
      }
    }
  }

  Future<void> _verifyAndNavigate() async {
    try {
      final orgId = await AdminService().verifyAndGetOrgId();
      await OrgManager.saveOrgId(orgId);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (_) => false);
      }
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      AdminService.invalidate();
      if (mounted) {
        setState(() => _isSigningIn = false);
        final msg = e.toString().contains('Not an admin')
            ? 'המשתמש אינו מוגדר כמנהל במערכת.'
            : e.toString().contains('User profile not found')
                ? 'לא נמצא פרופיל משתמש. פנה למנהל המערכת.'
                : e.toString().contains('No organization assigned')
                    ? 'המשתמש אינו משויך לארגון. פנה למנהל המערכת.'
                    : 'שגיאה בהתחברות. נסה שוב.';
        _showError(msg);
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => CustomPopupDialog(
        title: 'שגיאת התחברות',
        message: message,
        buttonText: 'סגור',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C5AA0),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Collecta',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5AA0),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'מערכת ניהול',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSigningIn ? null : _signInAsAdmin,
                    icon: _isSigningIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(_isSigningIn ? 'מתחבר...' : 'כניסה עם Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5AA0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF2C5AA0).withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'כניסה למנהלי מערכת בלבד',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
