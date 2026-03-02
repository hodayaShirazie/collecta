
import 'package:flutter/material.dart';

class HomepageTheme {
  // colors
  static const Color latetBlue = Color(0xFF1E5DAA);
  static const Color latetYellow = Color(0xFFFFF9C4);
  static const Color pageBackgroundStart = Color(0xFFEAF2FF);
  static const Color pageBackgroundEnd = Colors.white;

  // text styles
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle welcomeTextStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle coinsTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: latetBlue,
  );

  // Gradient 
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      pageBackgroundStart,
      pageBackgroundEnd,
    ],
  );

 
  static BoxDecoration buttonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: latetYellow.withOpacity(0.35),
        blurRadius: 30,
        offset: Offset(0, 15),
      ),
    ],
  );

  // coins box decoration 
  static BoxDecoration coinsBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
      ),
    ],
  );

  // decorative circle 
  static BoxDecoration decorativeCircle = BoxDecoration(
    color: latetYellow.withOpacity(0.25),
    shape: BoxShape.circle,
  );

  // sizes  
  static const double logoHeight = 90;
  static const double deptLogoHeight = 50;
  static const double coinLogoHeight = 22;

  // spacing
  static const double topPadding = 30;
  static const double betweenButtons = 25;
  static const double spacerHeight = 40;
}
