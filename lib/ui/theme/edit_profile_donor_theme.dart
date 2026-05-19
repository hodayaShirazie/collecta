import 'package:flutter/material.dart';
import 'homepage_theme.dart';

class DonorEditProfileTheme {
  static const Color primaryBlue = Color(0xFF1E5DAA);
  static const Color lightBlue = Color(0xFFE6F0FA);
  static const Color inputBorderColor = Color(0xFFB0C4DE);
  static const Color buttonTextColor = Colors.white;
  static const Color labelTextColor = Color(0xFF1E5DAA);

  static const TextStyle headerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: labelTextColor,
  );

  static InputDecoration inputDecoration = InputDecoration(
    isDense: true,
    filled: true,
    fillColor: HomepageTheme.latetYellow.withOpacity(0.2),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      borderSide: const BorderSide(color: primaryBlue, width: 2),
    ),
  );

  static BoxDecoration containerDecoration = BoxDecoration(
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

  static ButtonStyle saveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: buttonTextColor,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 5,
  );
}
