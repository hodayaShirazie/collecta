import 'package:flutter/material.dart';

class EnteringTheme {
  static const primaryBlue = Color(0xFF005EB8);
  static const lightBgColor = Color(0xFFF2E2CE);

  static ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0), 
    foregroundColor: primaryBlue, 
    elevation: 0,
    side: const BorderSide(color: primaryBlue, width: 3),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40), 
    ),
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: 'Assistant', 
    ),
  );
}