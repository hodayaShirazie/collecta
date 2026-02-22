import 'package:flutter/material.dart';
import 'homepage_theme.dart';

class ReportDonationTheme {
  // כותרת
  static const TextStyle headerStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: HomepageTheme.latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: HomepageTheme.latetBlue,
    fontFamily: 'Assistant',
  );

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration chipDecoration(bool selected) {
    return BoxDecoration(
      color: selected
          ? HomepageTheme.latetBlue.withOpacity(0.12)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: selected
            ? HomepageTheme.latetBlue
            : HomepageTheme.latetBlue.withOpacity(0.2),
      ),
    );
  }

  static ButtonStyle simpleButton = ElevatedButton.styleFrom(
    backgroundColor: HomepageTheme.latetBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Assistant',
    ),
  );
}
