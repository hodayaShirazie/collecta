import 'package:flutter/material.dart';
import 'package:collecta/services/org_theme.dart';

class AdminHomepageTheme {
  // Colors
  static Color get latetBlue => OrgTheme.primaryColor;
  static Color get latetYellow => OrgTheme.accentColor;
  static Color get pageBackgroundStart => OrgTheme.bgStartColor;
  static Color get pageBackgroundEnd => Colors.white;

  // Gradient
  static LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [pageBackgroundStart, pageBackgroundEnd],
      );

  // Text styles
  static TextStyle get welcomeTextStyle => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: latetBlue,
        fontFamily: 'Assistant',
      );

  static TextStyle get subtitleTextStyle => TextStyle(
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

  static TextStyle get statValueStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: latetBlue,
        fontFamily: 'Assistant',
      );

  static TextStyle get buttonTextStyle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: latetBlue,
        fontFamily: 'Assistant',
      );

  static BoxDecoration get buttonDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: latetBlue, width: 3),
        boxShadow: [
          BoxShadow(
            color: latetYellow,
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      );

  // Decorative circle
  static BoxDecoration get decorativeCircle => BoxDecoration(
        color: latetYellow.withOpacity(0.25),
        shape: BoxShape.circle,
      );

  static const double topPadding = 30;
  static const double betweenButtons = 25;
}
