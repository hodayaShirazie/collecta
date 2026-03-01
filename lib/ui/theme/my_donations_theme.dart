
import 'package:flutter/material.dart';
import 'homepage_theme.dart';

class MyDonationsTheme {
  static const TextStyle headerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: HomepageTheme.latetBlue,
    fontFamily: 'Assistant',
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'Assistant',
  );

  static TextStyle dateStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey[600],
    fontFamily: 'Assistant',
  );

  static TextStyle statusStyle(String status) {
    Color color;

    switch (status) {
      case "נאסף":
        color = Colors.green;
        break;
      case "בוטל":
        color = Colors.redAccent;
        break;
      default:
        color = HomepageTheme.latetBlue;
    }

    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: color,
      fontFamily: 'Assistant',
    );
  }

  static BoxDecoration statusChipDecoration(bool selected) {
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

  static const TextStyle statusChipText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: HomepageTheme.latetBlue,
    fontFamily: 'Assistant',
  );

  static InputDecoration searchDecoration = InputDecoration(
    hintText: "חיפוש לפי שם עסק...",
    prefixIcon: Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide.none,
    ),
  );

  /// 🟢 כרטיס תרומה
  static BoxDecoration donationCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );


  static Color statusColor(String status) {
    switch (status) {
      case "pending":
        return const Color(0xFFFFF9C4); 
      case "collected":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  static const TextStyle donationTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'Assistant',
  );


  static TextStyle donationDate = TextStyle(
    fontSize: 13,
    color: Colors.grey[600],
    fontFamily: 'Assistant',
  );


  static const TextStyle dateFilterText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Assistant',
  );


  static BoxDecoration dateFilterDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 4),
      )
    ],
  );
}
