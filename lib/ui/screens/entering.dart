// import 'package:flutter/material.dart';
// import 'package:collecta/app/routes.dart';

// class EnteringScreen extends StatelessWidget {
//   const EnteringScreen({super.key});

//   void _navigateToDriver(BuildContext context) {
//     // כאן אפשר להוסיף ניווט לדף נהג
//     // Navigator.pushNamed(context, '/driver');
//   }

//   void _navigateToDonor(BuildContext context) {
//     // כאן אפשר להוסיף ניווט לדף תורם
//     // Navigator.pushNamed(context, '/donor');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // לוגו עליון
//                 Image.asset(
//                   'assets/images/logo/latet_logo.png', // הנתיב הנכון ללוגו שלך
//                   height: 80,
//                 ),
//                 const SizedBox(height: 40),

//                 // לוגו אמצעי
//                 // Image.asset(
//                 //   'assets/images/logo/logo_middle.png',
//                 //   height: 120,
//                 // ),
//                 const SizedBox(height: 60),

//                 // כפתור כניסה כנהג
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _navigateToDriver(context),
//                     icon: const Icon(Icons.local_shipping),
//                     label: const Text('כניסה כנהג'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       textStyle: const TextStyle(fontSize: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // כפתור כניסה כתרום
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _navigateToDonor(context),
//                     icon: const Icon(Icons.favorite),
//                     label: const Text('כניסה כתורם'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       textStyle: const TextStyle(fontSize: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.pink, // צבע מותאם לכפתור
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, Routes.debug);
//                     },
//                     child: const Text('בדיקת חיבור ל-Database'),
//                   ),
//                 ),

//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:collecta/app/routes.dart';
import '../theme/entering_theme.dart';

class EnteringScreen extends StatelessWidget {
  const EnteringScreen({super.key});

  void _navigateToDriver(BuildContext context) {
    // Navigator.pushNamed(context, '/driver');
  }

  void _navigateToDonor(BuildContext context) {
    // Navigator.pushNamed(context, '/donor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // תמונת רקע - המצאתי URL שדומה לוויז'ואל של ידיים מחזיקות עולם
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo/latetBackgroundImg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // שכבת הצללה בהירה כדי שהטקסט יבלוט (אופציונלי)
          Container(color: Colors.white.withOpacity(0.2)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // לוגו LATET מרכזי
                Center(
                  child: Image.asset(
                    'assets/images/logo/latet_logo.png',
                    height: 120,
                  ),
                ),
                
                const Spacer(), // דוחף את הכפתורים למטה

                // כפתור כניסה כנהג
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToDriver(context),
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

                // כפתור כניסה כתורם
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToDonor(context),
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

                // לוגו תחתון "ביטחון תזונתי"
                Image.asset(
                  'assets/images/logo/latet_food_security_logo.png', // וודא שיש לך את הלוגו הקטן
                  height: 50,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}