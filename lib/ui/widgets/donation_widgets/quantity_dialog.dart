import 'package:flutter/material.dart';
import '../../theme/homepage_theme.dart';

Future<Map<String, dynamic>?> showQuantityDialog({
  required BuildContext context,
  required String productName,
  String? productId,
  int initialQuantity = 1,
}) async {
  int quantity = initialQuantity;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          productName.startsWith("אחר") ? "פרט פריט לתרומה" : "הכנס כמות ב-יחידות/קג",
          style: TextStyle(color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () => quantity > 1 ? setStateDialog(() => quantity--) : null,
                    icon: const Icon(Icons.remove)),
                Text(quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => setStateDialog(() => quantity++), icon: const Icon(Icons.add)),
              ],
            );
          },
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, {"name": productName, "productTypeId": productId, "quantity": quantity.toString(), "unit": "קג/יחידות"}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: HomepageTheme.latetBlue, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("אשר", style: TextStyle(color: HomepageTheme.latetBlue, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    },
  );
}