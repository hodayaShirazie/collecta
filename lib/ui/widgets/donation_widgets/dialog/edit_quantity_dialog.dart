import 'package:flutter/material.dart';
import '../../../theme/homepage_theme.dart';

Future<int?> showEditQuantityDialog({
  required BuildContext context,
  required int initialQuantity,
}) async {
  int currentQuantity = initialQuantity;

  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          "ערוך כמות",
          style: TextStyle(
            color: HomepageTheme.latetBlue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (currentQuantity > 1) {
                      setStateDialog(() => currentQuantity--);
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  currentQuantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setStateDialog(() => currentQuantity++);
                  },
                  icon: const Icon(Icons.add),
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
                Navigator.pop(context, currentQuantity);
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