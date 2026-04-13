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
import 'donor_homepage.dart';
import 'driver_homepage.dart';

import '../../services/org_manager.dart';
import '../utils/org_utils.dart';



// const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class EnteringScreen extends StatefulWidget {
  const EnteringScreen({super.key});

  @override
  State<EnteringScreen> createState() => _EnteringScreenState();
}

class _EnteringScreenState extends State<EnteringScreen> {
  final UserService _userService = UserService();
  String? _userToken;

  late Future<dynamic> _orgFuture;

  @override
  void initState() {
    super.initState();
    _orgFuture = OrgUtils.loadOrganization();
  }

  

  Future<String?> _signInAndSync(String role) async {
    try {
      User? firebaseUser;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
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
      print("AUTH ERROR: $e");
      return "Authentication failed: ${e.toString()}";
    }
  }

  void _navigateToDriver() {
    Navigator.pushNamed(context, '/driver', arguments: _userToken);
  }

  void _navigateToDonor() {
    Navigator.pushNamed(context, '/donor', arguments: _userToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _orgFuture, 
        builder: (context, snapshot) {
          // if (!snapshot.hasData) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          // final org = snapshot.data!;
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
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result =
                                await _signInAndSync("donor");


                            if (result == "success") {
                              DonorHomepage.markLoginSession();
                              _navigateToDonor();
                            }
                            // if (result == "success") {
                            //   final donor = await DonorService().getMyDonorProfile();

                            //   if (donor.missingFields().isNotEmpty) {
                            //     Navigator.pushNamed(
                            //       context,
                            //       Routes.completeProfile,
                            //       // "/complete-profile",
                            //       arguments: donor,
                            //     );
                            //   } else {
                            //     _navigateToDonor();
                            //   }
                            // }
                            else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                    content:
                                        Text(result ?? "Error")),
                              );
                            }
                          },
                          style:
                              EnteringTheme.actionButtonStyle,
                          child: const Text("כניסה כתורם"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result =
                                await _signInAndSync("driver");

                            if (result == "success") {
                              DriverHomepage.markLoginSession();
                              _navigateToDriver();
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                    content:
                                        Text(result ?? "Error")),
                              );
                            }
                          },
                          style:
                              EnteringTheme.actionButtonStyle,
                          child: const Text("כניסה כנהג"),
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
