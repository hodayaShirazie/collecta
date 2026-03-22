import 'package:flutter/material.dart';
import '../../../theme/homepage_theme.dart';

Future<Map<String, dynamic>?> showOtherItemDialog({
  required BuildContext context,
  String initialText = "",
  int initialQuantity = 1,
}) async {
  final TextEditingController otherController = TextEditingController(
    text: initialText.replaceFirst("אחר: ", ""),
  );
  int quantity = initialQuantity;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          "פרט פריט לתרומה",
          style: TextStyle(
            color: HomepageTheme.latetBlue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setStateDialog(() => quantity--);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setStateDialog(() => quantity++);
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: otherController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "תיאור הפריט",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: HomepageTheme.latetBlue,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: HomepageTheme.latetBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            );
          },
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (otherController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    "name": "אחר: ${otherController.text}",
                    "productTypeId": null,
                    "quantity": quantity.toString(),
                    "unit": 'ק"ג/יחידות',
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: HomepageTheme.latetBlue,
                  width: 1.5,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "אשר",
                style: TextStyle(
                  color: HomepageTheme.latetBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}