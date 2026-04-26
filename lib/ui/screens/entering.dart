import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../theme/entering_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/donor_service.dart';
import '../../app/routes.dart';
import '../widgets/custom_popup_dialog.dart';
import 'donor_homepage.dart';
import 'driver_homepage.dart';

import '../../services/org_manager.dart';
import '../../services/admin_view_manager.dart';
import '../../services/impersonation_manager.dart';
import '../utils/org_utils.dart';


class EnteringScreen extends StatefulWidget {
  const EnteringScreen({super.key});

  @override
  State<EnteringScreen> createState() => _EnteringScreenState();
}

class _EnteringScreenState extends State<EnteringScreen> {
  final UserService _userService = UserService();
  String? _userToken;
  bool _isSigningIn = false;
  bool _isAdminViewMode = false;

  late Future<dynamic> _orgFuture;

  @override
  void initState() {
    super.initState();
    _orgFuture = OrgUtils.loadOrganization();

    debugPrint('[AdminView] hasPendingView=${AdminViewManager.hasPendingView} '
        'driverId=${AdminViewManager.driverId} '
        'hasToken=${AdminViewManager.adminToken != null}');

    if (AdminViewManager.hasPendingView) {
      _isAdminViewMode = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handleAdminView());
    }
  }

  Future<void> _handleAdminView() async {
    debugPrint('[AdminView] _handleAdminView called, navigating to DriverHomepage');
    ImpersonationManager.instance.startWithToken(
      AdminViewManager.driverId!,
      AdminViewManager.adminToken!,
      driverName: AdminViewManager.driverName,
    );
    AdminViewManager.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverHomepage(isAdminImpersonating: true),
      ),
    );
  }

  Future<String?> _signInAndSync(String role) async {
    try {
      User? firebaseUser;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(provider);

        firebaseUser = userCredential.user;
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        firebaseUser = userCredential.user;
      }

      if (firebaseUser == null) return null;

      _userToken = await firebaseUser.getIdToken();

      final result = await _userService.syncUserWithRole(
        name: firebaseUser.displayName ?? '',
        mail: firebaseUser.email ?? '',
        img: firebaseUser.photoURL ?? '',
        role: role,
        organizationId: await OrgUtils.getOrgId() ?? '',
      );

      //TODO למחוק אחכ- הדפסה של הטוקן
      // String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      // print("FULL_TOKEN: $token");

      return result;
    } catch (e) {
      if (e is FirebaseAuthException &&
          (e.code == 'popup-closed-by-user' || e.code == 'canceled')) {
        return null;
      }
      return "Authentication failed: ${e.toString()}";
    }
  }

  void _showErrorDialog(String message) {
    String displayMessage = message;
    if (message.contains('different role')) {
      displayMessage = 'המשתמש רשום עם תפקיד אחר במערכת.\nלא ניתן להתחבר עם תפקיד זה.';
    }
    showDialog(
      context: context,
      builder: (_) => CustomPopupDialog(
        title: 'שגיאת התחברות',
        message: displayMessage,
        buttonText: 'סגור',
      ),
    );
  }

  void _navigateToDriver() {
    Navigator.pushNamed(context, '/driver', arguments: _userToken);
  }

  void _navigateToDonor() {
    Navigator.pushNamed(context, '/donor', arguments: _userToken);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdminViewMode) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: _orgFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No organization found. Please open link."),
            );
          }

          final org = snapshot.data!;

          return Stack(
            children: [
              CachedNetworkImage(
                imageUrl: org.backgroundImg,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                fadeInDuration: const Duration(milliseconds: 300),
              ),

              Container(color: Colors.white.withValues(alpha: 0.2)),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    CachedNetworkImage(
                      imageUrl: org.logo,
                      height: 120,
                      placeholder: (context, url) =>
                          const SizedBox(
                            height: 120,
                            child: Center(
                                child: CircularProgressIndicator()),
                          ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),

                    const Spacer(),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 60),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSigningIn ? null : () async {
                            setState(() => _isSigningIn = true);
                            final result = await _signInAndSync("donor");
                            if (result == "success") {
                              DonorHomepage.markLoginSession();
                              _navigateToDonor();
                            } else {
                              if (mounted) setState(() => _isSigningIn = false);
                              if (result != null) {
                                _showErrorDialog(result);
                              }
                            }
                          },
                          style: EnteringTheme.actionButtonStyle,
                          child: _isSigningIn
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: EnteringTheme.primaryBlue,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text("כניסה כתורם"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 60),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSigningIn ? null : () async {
                            setState(() => _isSigningIn = true);
                            final result = await _signInAndSync("driver");
                            if (result == "success") {
                              DriverHomepage.markLoginSession();
                              _navigateToDriver();
                            } else {
                              if (mounted) setState(() => _isSigningIn = false);
                              if (result != null) {
                                _showErrorDialog(result);
                              }
                            }
                          },
                          style: EnteringTheme.actionButtonStyle,
                          child: _isSigningIn
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: EnteringTheme.primaryBlue,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text("כניסה כנהג"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    CachedNetworkImage(
                      imageUrl: org.departmentLogo,
                      height: 50,
                      placeholder: (context, url) =>
                          const SizedBox(
                            height: 50,
                            child: Center(
                                child: CircularProgressIndicator()),
                          ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
