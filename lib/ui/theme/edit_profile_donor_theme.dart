import 'package:flutter/material.dart';
import 'package:collecta/services/org_theme.dart';
import 'homepage_theme.dart';

class DonorEditProfileTheme {
  static Color get primaryBlue => OrgTheme.primaryColor;
  static Color get lightBlue => OrgTheme.accentColor;
  static const Color inputBorderColor = Color(0xFFB0C4DE);
  static const Color buttonTextColor = Colors.white;
  static Color get labelTextColor => OrgTheme.primaryColor;

  static TextStyle get headerStyle => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
        fontFamily: 'Assistant',
      );

  static TextStyle get labelStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: labelTextColor,
      );

  static InputDecoration get inputDecoration => InputDecoration(
        isDense: true,
        filled: true,
        fillColor: HomepageTheme.latetYellow.withOpacity(0.2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: inputBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: inputBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      );

  static BoxDecoration get containerDecoration => BoxDecoration(
        border: Border.all(color: primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  static ButtonStyle get saveButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: buttonTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        textStyle:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 5,
      );
}
