// import 'package:flutter/material.dart';

// class HomepageTheme {
//   static const Color latetBlue = Color(0xFF1E5DAA);
//   static const Color latetYellow = Color(0xFFFDCB58);

//   // סגנון טקסט בתוך הכפתור
//   static const TextStyle buttonTextStyle = TextStyle(
//     fontSize: 22,
//     fontWeight: FontWeight.bold,
//     color: latetBlue,
//     fontFamily: 'Assistant',
//   );

//   // סגנון טקסט ברוך הבא
//   static const TextStyle welcomeTextStyle = TextStyle(
//     fontSize: 32,
//     fontWeight: FontWeight.bold,
//     color: latetBlue,
//     fontFamily: 'Assistant',
//   );

//   // עיצוב הכפתור עם ה-Border והצללית הצהובה הקשיחה
//   static BoxDecoration buttonDecoration = BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(40),
//     border: Border.all(color: latetBlue, width: 3),
//     boxShadow: const [
//       BoxShadow(
//         color: latetYellow,
//         offset: Offset(0, 5), // נותן את אפקט הדו-מימד למטה
//         blurRadius: 0,
//       ),
//     ],
//   );
// }



import 'package:flutter/material.dart';

class HomepageTheme {
  // צבעים
  static const Color latetBlue = Color(0xFF1E5DAA);
  static const Color latetYellow = Color(0xFFFDCB58);

  // טקסט
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle welcomeTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle coinsTextStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: latetBlue,
  );

  // כפתורים
  static ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: latetBlue,
    textStyle: buttonTextStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40),
      side: const BorderSide(color: latetBlue, width: 3),
    ),
    shadowColor: latetYellow,
    elevation: 5,
  );

  // קופסאות עם צל
  static BoxDecoration buttonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: latetBlue, width: 3),
    boxShadow: const [
      BoxShadow(
        color: latetYellow,
        offset: Offset(0, 5),
        blurRadius: 0,
      ),
    ],
  );

  // מרווחים סטנדרטיים
  static const double topPadding = 50;
  static const double logoHeight = 110;
  static const double deptLogoHeight = 60;
  static const double coinLogoHeight = 35;
  static const double spacerHeight = 25;
}

