import 'package:flutter/material.dart';

class HomepageTheme {
  static const Color latetBlue = Color(0xFF1E5DAA);
  static const Color latetYellow = Color(0xFFFDCB58);

  // סגנון טקסט בתוך הכפתור
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  // סגנון טקסט ברוך הבא
  static const TextStyle welcomeTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  // עיצוב הכפתור עם ה-Border והצללית הצהובה הקשיחה
  static BoxDecoration buttonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: latetBlue, width: 3),
    boxShadow: const [
      BoxShadow(
        color: latetYellow,
        offset: Offset(0, 5), // נותן את אפקט הדו-מימד למטה
        blurRadius: 0,
      ),
    ],
  );
}