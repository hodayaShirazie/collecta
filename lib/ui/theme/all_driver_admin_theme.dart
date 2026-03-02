import 'package:flutter/material.dart';
import 'homepage_theme.dart';

class AllDriverAdminTheme {
  static const TextStyle headerStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: HomepageTheme.latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle nameStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
    fontFamily: 'Assistant',
  );


  static const TextStyle phoneStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'Roboto', 
    letterSpacing: 1,
  );

  static InputDecoration searchDecoration = InputDecoration(
    hintText: "חיפוש נהג:",
    prefixIcon: Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(28)),
      borderSide: BorderSide.none,
    ),
  );

  static BoxDecoration driverButtonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
    ],
  );
}
