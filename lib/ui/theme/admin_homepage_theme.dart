import 'package:flutter/material.dart';

class AdminHomepageTheme {
  // Colors
  static const Color latetBlue = Color(0xFF1E5DAA);
  static const Color latetYellow = Color(0xFFFFF9C4);
  static const Color pageBackgroundStart = Color(0xFFEAF2FF);
  static const Color pageBackgroundEnd = Colors.white;

  // Gradient
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      pageBackgroundStart,
      pageBackgroundEnd,
    ],
  );

  // Text styles
  static const TextStyle welcomeTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 20,
    fontStyle: FontStyle.italic,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle statTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.orange,
    fontFamily: 'Assistant',
  );

  static const TextStyle statValueStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  // Button decoration (כמו הנהג)
  static BoxDecoration buttonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: latetBlue, width: 3),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFFFFF9C4),
        offset: Offset(0, 5),
        blurRadius: 0,
      ),
    ],
  );

  // Decorative circle
  static BoxDecoration decorativeCircle = BoxDecoration(
    color: latetYellow.withOpacity(0.25),
    shape: BoxShape.circle,
  );

  static const double topPadding = 30;
  static const double betweenButtons = 25;
}
