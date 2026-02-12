import 'package:flutter/material.dart';

class DonorEditProfileTheme {
  static const Color latetBlue = Color(0xFF1E5DAA);
  
  // כותרת עמוד
  static const TextStyle headerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: latetBlue,
    fontFamily: 'Assistant',
    fontStyle: FontStyle.italic,
  );

  // כותרות מעל שדות הקלט
  static const TextStyle labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: latetBlue,
  );

  // עיצוב שדות הקלט
  static InputDecoration inputDecoration = InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    ),
  );

  // עיצוב המסגרת המרכזית הכחולה
  static BoxDecoration containerDecoration = BoxDecoration(
    border: Border.all(color: latetBlue, width: 2),
    color: Colors.white,
  );

  // עיצוב כפתור "שמור"
  static ButtonStyle saveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: latetBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
}