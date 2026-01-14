import 'package:flutter/material.dart';
import 'package:collecta/app/routes.dart';

class EnteringScreen extends StatelessWidget {
  const EnteringScreen({super.key});

  void _navigateToDriver(BuildContext context) {
    // כאן אפשר להוסיף ניווט לדף נהג
    // Navigator.pushNamed(context, '/driver');
  }

  void _navigateToDonor(BuildContext context) {
    // כאן אפשר להוסיף ניווט לדף תורם
    // Navigator.pushNamed(context, '/donor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // לוגו עליון
                Image.asset(
                  'assets/images/logo/latet_logo.png', // הנתיב הנכון ללוגו שלך
                  height: 80,
                ),
                const SizedBox(height: 40),

                // לוגו אמצעי
                // Image.asset(
                //   'assets/images/logo/logo_middle.png',
                //   height: 120,
                // ),
                const SizedBox(height: 60),

                // כפתור כניסה כנהג
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDriver(context),
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('כניסה כנהג'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // כפתור כניסה כתרום
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDonor(context),
                    icon: const Icon(Icons.favorite),
                    label: const Text('כניסה כתורם'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.pink, // צבע מותאם לכפתור
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.debug);
                    },
                    child: const Text('בדיקת חיבור ל-Database'),
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
