import 'package:flutter/material.dart';
import 'package:collecta/services/org_theme.dart';

class EnteringTheme {
  static Color get primaryBlue => OrgTheme.primaryColor;
  static const lightBgColor = Color(0xFFF2E2CE);

  static ButtonStyle get actionButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0),
        foregroundColor: primaryBlue,
        elevation: 0,
        side: BorderSide(color: primaryBlue, width: 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        minimumSize: const Size(0, 58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Assistant',
        ),
      );
}
