// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:google_sign_in/google_sign_in.dart';
// import '../../services/organization_service.dart';
// import '../../services/user_service.dart';
// import '../theme/entering_theme.dart';
// import 'package:cached_network_image/cached_network_image.dart';




// const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';


// class EnteringScreen extends StatefulWidget {
//   const EnteringScreen({super.key});

//   @override
//   State<EnteringScreen> createState() => _EnteringScreenState();
// }

// class _EnteringScreenState extends State<EnteringScreen> {
//   final UserService _userService = UserService();
//   String? _userToken;


//   Future<String?> _signInAndSync(String role) async {
//     try {
//       // await FirebaseAuth.instance.signOut();

//       User? firebaseUser;

//       if (kIsWeb) {
//         final provider = GoogleAuthProvider();
//         final userCredential =
//             await FirebaseAuth.instance.signInWithPopup(provider);


//         firebaseUser = userCredential.user;
//       } else {
//         final googleSignIn = GoogleSignIn();
//         final googleUser = await googleSignIn.signIn();
//         if (googleUser == null) return null;

//         final googleAuth = await googleUser.authentication;

//         final credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth.accessToken,
//           idToken: googleAuth.idToken,
//         );

//         final userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);

//         firebaseUser = userCredential.user;
//       }

//       if (firebaseUser == null) return null;

//       _userToken = await firebaseUser.getIdToken();

//       final result = await _userService.syncUserWithRole(
//         name: firebaseUser.displayName ?? '',
//         mail: firebaseUser.email ?? '',
//         img: firebaseUser.photoURL ?? '',
//         role: role,
//         organizationId: kOrganizationId,
//       );

//       return result; 
//     } catch (e) {
//       print("AUTH ERROR: $e");
//       return "Authentication failed: ${e.toString()}";
//     }
//   }

//   void _navigateToDriver() {
//     Navigator.pushNamed(context, '/driver', arguments: _userToken);
//   }

//   void _navigateToDonor() {
//     Navigator.pushNamed(context, '/donor', arguments: _userToken);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orgService = OrganizationService();

//     return Scaffold(
//       body: FutureBuilder(
//         future: orgService.fetchOrganization(kOrganizationId),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final org = snapshot.data!;

//           return Stack(
//             children: [
//               // Image.network(
//               //   org.backgroundImg,
//               //   fit: BoxFit.cover,
//               //   height: double.infinity,
//               //   width: double.infinity,
//               // ),

//               CachedNetworkImage(
//                 imageUrl: org.backgroundImg,
//                 fit: BoxFit.cover,
//                 height: double.infinity,
//                 width: double.infinity,
//                 placeholder: (context, url) =>
//                     Container(color: Colors.grey[200]),
//                 errorWidget: (context, url, error) =>
//                     const Icon(Icons.error),
//                 fadeInDuration: const Duration(milliseconds: 300),
//               ),


//               Container(color: Colors.white.withValues(alpha: 0.2)),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 60),
//                     // Image.network(org.logo, height: 120),

//                     CachedNetworkImage(
//                       imageUrl: org.logo,
//                       height: 120,
//                       placeholder: (context, url) =>
//                           const SizedBox(
//                             height: 120,
//                             child: Center(child: CircularProgressIndicator()),
//                           ),
//                       errorWidget: (context, url, error) =>
//                           const Icon(Icons.error),
//                     ),




//                     const Spacer(),

//                     /// DONOR
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final result = await _signInAndSync("donor");

//                             if (result == "success") {
//                               _navigateToDonor();
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text(result ?? "Error")),
//                               );
//                             }
//                           },
//                           style: EnteringTheme.actionButtonStyle,
//                           child: const Text("כניסה כתורם"),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 30),

//                     /// DRIVER
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final result = await _signInAndSync("driver");

//                             if (result == "success") {
//                               _navigateToDriver();
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text(result ?? "Error")),
//                               );
//                             }
//                           },
//                           style: EnteringTheme.actionButtonStyle,
//                           child: const Text("כניסה כנהג"),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Image.network(org.departmentLogo, height: 50),


//                     CachedNetworkImage(
//                       imageUrl: org.departmentLogo,
//                       height: 50,
//                       placeholder: (context, url) =>
//                           const SizedBox(
//                             height: 50,
//                             child: Center(child: CircularProgressIndicator()),
//                           ),
//                       errorWidget: (context, url, error) =>
//                           const Icon(Icons.error),
//                     ),





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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/organization_service.dart';
import '../../services/user_service.dart';
import '../theme/entering_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class EnteringScreen extends StatefulWidget {
  const EnteringScreen({super.key});

  @override
  State<EnteringScreen> createState() => _EnteringScreenState();
}

class _EnteringScreenState extends State<EnteringScreen> {
  final UserService _userService = UserService();
  String? _userToken;

  // ✅ חדש – Future שנשמר פעם אחת
  late Future _orgFuture;

  @override
  void initState() {
    super.initState();

    // ✅ נוצר פעם אחת בלבד
    _orgFuture =
        OrganizationService().fetchOrganization(kOrganizationId);
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
        final googleSignIn = GoogleSignIn();
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
        organizationId: kOrganizationId,
      );

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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
                              _navigateToDonor();
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
