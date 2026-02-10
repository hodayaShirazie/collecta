
// import 'package:flutter/material.dart';
// import '../../services/organization_service.dart';
// import '../theme/entering_theme.dart';

// class EnteringScreen extends StatelessWidget {
//   const EnteringScreen({super.key});

//   void _navigateToDriver(BuildContext context) {}
//   void _navigateToDonor(BuildContext context) {}



//   @override
//   Widget build(BuildContext context) {
//     final orgService = OrganizationService();

//     return Scaffold(
//       body: FutureBuilder(
//         future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'), // ID דינמי או קבוע
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
//                     Image.network(
//                       org.logo,
//                       height: 120,
//                     ),
//                     const Spacer(),
//                     // כפתור כניסה כנהג
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () => _navigateToDriver(context),
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
//                     // כפתור כניסה כתורם
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () => _navigateToDonor(context),
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
//                     // לוגו תחתון
//                     Image.network(
//                       org.departmentLogo,
//                       height: 50,
//                     ),
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





// /////////////////////// NEW VERSION ///////////////////////
// ///
// ///
// ///


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../services/organization_service.dart';
// import '../theme/entering_theme.dart';

// class EnteringScreen extends StatelessWidget {
//   const EnteringScreen({super.key});

//   void _navigateToDriver(BuildContext context) {
//     // כאן תכניסי את הניווט שלך למסך הנהג
//     Navigator.pushNamed(context, '/driver');
//   }

//   void _navigateToDonor(BuildContext context) {
//     // כאן תכניסי את הניווט שלך למסך התורם
//     Navigator.pushNamed(context, '/donor');
//   }

//   // 🔹 פונקציית התחברות Google + Firebase
//   Future<UserCredential?> _signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return null; // המשתמש ביטל

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       return await FirebaseAuth.instance.signInWithCredential(credential);
//     } catch (e) {
//       print("Error signing in with Google: $e");
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orgService = OrganizationService();

//     // 🔹 בדיקה אם המשתמש כבר מחובר
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _navigateToDonor(context); // או Driver לפי הצורך
//       });
//     }

//     return Scaffold(
//       body: FutureBuilder(
//         future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'), // ID דינמי או קבוע
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
//                     Image.network(
//                       org.logo,
//                       height: 120,
//                     ),
//                     const Spacer(),
//                     // כפתור כניסה כנהג
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final userCredential = await _signInWithGoogle();
//                             if (userCredential != null) {
//                               _navigateToDriver(context);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Google Sign-In failed')),
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
//                     // כפתור כניסה כתורם
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final userCredential = await _signInWithGoogle();
//                             if (userCredential != null) {
//                               _navigateToDonor(context);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Google Sign-In failed')),
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
//                     // לוגו תחתון
//                     Image.network(
//                       org.departmentLogo,
//                       height: 50,
//                     ),
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
import '../theme/entering_theme.dart';

class EnteringScreen extends StatelessWidget {
  const EnteringScreen({super.key});

  // פונקציות ניווט למסכים אחרים
  void _navigateToDriver(BuildContext context) {
    Navigator.pushNamed(context, '/driver');
  }

  void _navigateToDonor(BuildContext context) {
    Navigator.pushNamed(context, '/donor');
  }

  // 🔹 פונקציית Google Sign-In + Firebase
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // המשתמש ביטל

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgService = OrganizationService();

    return Scaffold(
      body: FutureBuilder(
        future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'), // ID של הארגון
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final org = snapshot.data!;

          return Stack(
            children: [
              // רקע
              Image.network(
                org.backgroundImg,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              Container(color: Colors.white.withOpacity(0.2)),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // לוגו מרכזי
                    Image.network(org.logo, height: 120),
                    const Spacer(),

                    // כפתור כניסה כתורם
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final userCredential = await _signInWithGoogle();
                            if (userCredential != null) {
                              _navigateToDonor(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google Sign-In failed'),
                                ),
                              );
                            }
                          },
                          style: EnteringTheme.actionButtonStyle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.favorite_rounded, size: 35),
                              SizedBox(width: 10),
                              Text('כניסה כתורם'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // כפתור כניסה כנהג
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final userCredential = await _signInWithGoogle();
                            if (userCredential != null) {
                              _navigateToDriver(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google Sign-In failed'),
                                ),
                              );
                            }
                          },
                          style: EnteringTheme.actionButtonStyle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.local_shipping, size: 35),
                              SizedBox(width: 10),
                              Text('כניסה כנהג'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),


                    // לוגו תחתון
                    Image.network(org.departmentLogo, height: 50),
                    const SizedBox(height: 20),
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
