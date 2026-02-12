
// TODO check that user doesnt already exists

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../services/organization_service.dart';
// import '../theme/entering_theme.dart';

// class EnteringScreen extends StatelessWidget {
//   const EnteringScreen({super.key});

//   // פונקציות ניווט למסכים אחרים
//   void _navigateToDriver(BuildContext context) {
//     Navigator.pushNamed(context, '/driver');
//   }

//   void _navigateToDonor(BuildContext context) {
//     Navigator.pushNamed(context, '/donor');
//   }

//   // 🔹 פונקציית Google Sign-In + Firebase
//   Future<UserCredential?> _signInWithGoogle() async {
//     try {
//       final googleSignIn = GoogleSignIn();

//       await googleSignIn.signOut();
//       await FirebaseAuth.instance.signOut();

//       // עכשיו מתחילים התחברות חדשה
//       final GoogleSignInAccount? googleUser =
//           await googleSignIn.signIn();

//       if (googleUser == null) return null;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential =
//           await FirebaseAuth.instance.signInWithCredential(credential);


//       print("Firebase user: ${userCredential.user?.email}");

//       return userCredential;
//     } catch (e) {
//       print("Error signing in with Google: $e");
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orgService = OrganizationService();

//     return Scaffold(
//       body: FutureBuilder(
//         future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'), // ID של הארגון
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final org = snapshot.data!;

//           return Stack(
//             children: [
//               // רקע
//               Image.network(
//                 org.backgroundImg,
//                 fit: BoxFit.cover,
//                 height: double.infinity,
//                 width: double.infinity,
//               ),
//               Container(color: Colors.white.withOpacity(0.2)),

//               SafeArea(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 60),
//                     // לוגו מרכזי
//                     Image.network(org.logo, height: 120),
//                     const Spacer(),

//                     // כפתור כניסה כתורם
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final userCredential = await _signInWithGoogle();
//                             print("Firebase user: ${FirebaseAuth.instance.currentUser?.email}");

//                             if (userCredential != null) {
//                               _navigateToDonor(context);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Google Sign-In failed'),
//                                 ),
//                               );
//                             }
//                           },
//                           style: EnteringTheme.actionButtonStyle,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Icon(Icons.favorite_rounded, size: 35),
//                               SizedBox(width: 10),
//                               Text('כניסה כתורם'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // כפתור כניסה כנהג
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final userCredential = await _signInWithGoogle();
//                             print("Firebase user: ${FirebaseAuth.instance.currentUser?.email}");

//                             if (userCredential != null) {
//                               _navigateToDriver(context);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Google Sign-In failed'),
//                                 ),
//                               );
//                             }
//                           },
//                           style: EnteringTheme.actionButtonStyle,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Icon(Icons.local_shipping, size: 35),
//                               SizedBox(width: 10),
//                               Text('כניסה כנהג'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 25),


//                     // לוגו תחתון
//                     Image.network(org.departmentLogo, height: 50),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../theme/entering_theme.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';


class EnteringScreen extends StatefulWidget {
  const EnteringScreen({super.key});

  @override
  State<EnteringScreen> createState() => _EnteringScreenState();
}

class _EnteringScreenState extends State<EnteringScreen> {
  final UserService _userService = UserService();
  String? _userToken;

  Future<String?> _signInAndSync(String role) async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      _userToken = await firebaseUser.getIdToken();

      final result = await _userService.syncUserWithRole(
        name: firebaseUser.displayName ?? '',
        mail: firebaseUser.email ?? '',
        img: firebaseUser.photoURL ?? '',
        role: role,
        organizationId: kOrganizationId,
      );

      return result; // success / error message
    } catch (e) {
      return "Authentication failed";
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
    final orgService = OrganizationService();

    return Scaffold(
      body: FutureBuilder(
        future: orgService.fetchOrganization(kOrganizationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final org = snapshot.data!;

          return Stack(
            children: [
              Image.network(
                org.backgroundImg,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              Container(color: Colors.white.withValues(alpha: 0.2)),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Image.network(org.logo, height: 120),
                    const Spacer(),

                    /// DONOR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await _signInAndSync("donor");

                            if (result == "success") {
                              _navigateToDonor();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result ?? "Error")),
                              );
                            }
                          },
                          style: EnteringTheme.actionButtonStyle,
                          child: const Text("כניסה כתורם"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// DRIVER
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await _signInAndSync("driver");

                            if (result == "success") {
                              _navigateToDriver();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result ?? "Error")),
                              );
                            }
                          },
                          style: EnteringTheme.actionButtonStyle,
                          child: const Text("כניסה כנהג"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Image.network(org.departmentLogo, height: 50),
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
