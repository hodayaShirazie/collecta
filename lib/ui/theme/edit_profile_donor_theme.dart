// import 'package:flutter/material.dart';

// class DonorEditProfileTheme {
//   static const Color latetBlue = Color(0xFF1E5DAA);
  
//   // כותרת עמוד
//   static const TextStyle headerStyle = TextStyle(
//     fontSize: 28,
//     fontWeight: FontWeight.bold,
//     color: latetBlue,
//     fontFamily: 'Assistant',
//     fontStyle: FontStyle.italic,
//   );

//   // כותרות מעל שדות הקלט
//   static const TextStyle labelStyle = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.bold,
//     color: latetBlue,
//   );

//   // עיצוב שדות הקלט
//   static InputDecoration inputDecoration = InputDecoration(
//     isDense: true,
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(15),
//       borderSide: const BorderSide(color: Colors.black, width: 1),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(15),
//       borderSide: const BorderSide(color: Colors.black, width: 1),
//     ),
//   );

//   // עיצוב המסגרת המרכזית הכחולה
//   static BoxDecoration containerDecoration = BoxDecoration(
//     border: Border.all(color: latetBlue, width: 2),
//     color: Colors.white,
//   );

//   // עיצוב כפתור "שמור"
//   static ButtonStyle saveButtonStyle = ElevatedButton.styleFrom(
//     backgroundColor: latetBlue,
//     foregroundColor: Colors.white,
//     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(20),
//     ),
//     textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   );
// }



import 'package:flutter/material.dart';

class DonorEditProfileTheme {
  // צבעים עיקריים
  static const Color primaryBlue = Color(0xFF1E5DAA);
  static const Color lightBlue = Color(0xFFE6F0FA);
  static const Color inputBorderColor = Color(0xFFB0C4DE);
  static const Color buttonTextColor = Colors.white;
  static const Color labelTextColor = Color(0xFF1E5DAA);

  // כותרת עמוד
  static const TextStyle headerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    fontFamily: 'Assistant',
    fontStyle: FontStyle.italic,
  );

  // כותרות מעל שדות הקלט
  static const TextStyle labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: labelTextColor,
  );

  // עיצוב שדות הקלט
  static InputDecoration inputDecoration = InputDecoration(
    isDense: true,
    filled: true,
    fillColor: lightBlue,
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

  // עיצוב המסגרת המרכזית של הטופס
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

  // עיצוב כפתור "שמור"
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
