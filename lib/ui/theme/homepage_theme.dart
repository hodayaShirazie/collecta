import 'package:flutter/material.dart';
import 'package:collecta/services/org_theme.dart';

class HomepageTheme {
  // colors
  static Color get latetBlue => OrgTheme.primaryColor;
  static Color get latetYellow => OrgTheme.accentColor;
  static Color get pageBackgroundStart => OrgTheme.bgStartColor;
  static Color get pageBackgroundEnd => Colors.white;

  // text styles
  static TextStyle get buttonTextStyle => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: latetBlue,
        fontFamily: 'Assistant',
      );

  static TextStyle get welcomeTextStyle => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: latetBlue,
        fontFamily: 'Assistant',
      );

  static TextStyle get coinsTextStyle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: latetBlue,
        fontFamily: 'Assistant',
      );

  static TextStyle get subtitleTextStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: latetBlue,
      );

  // Gradient
  static LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [pageBackgroundStart, pageBackgroundEnd],
      );

  static BoxDecoration get buttonDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: latetYellow.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      );

  // coins box decoration
  static BoxDecoration get coinsBoxDecoration => BoxDecoration(
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
  static BoxDecoration get decorativeCircle => BoxDecoration(
        color: latetYellow.withOpacity(0.25),
        shape: BoxShape.circle,
      );

  // faint decorative circle (for admin extra circles)
  static BoxDecoration get decorativeCircleFaint => BoxDecoration(
        color: latetYellow.withOpacity(0.14),
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
