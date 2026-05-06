import 'package:flutter/material.dart';

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
      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 600;
      final dialogWidth = isMobile ? screenWidth * 0.70 : 100.0;

      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.12),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: isMobile
                  ? const EdgeInsets.fromLTRB(14, 16, 14, 12)
                  : const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productName.startsWith("אחר") ? "פרט פריט לתרומה" : "הכנס כמות ב-יחידות/קג",
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E5DAA),
                      fontFamily: 'Assistant',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 5 : 8),
                  Container(
                    height: 2,
                    width: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E5DAA).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 16),
                  StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => quantity > 1 ? setStateDialog(() => quantity--) : null,
                            icon: const Icon(Icons.remove, color: Color(0xFF1E5DAA)),
                            iconSize: isMobile ? 20 : 24,
                          ),
                          Text(
                            quantity.toString(),
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setStateDialog(() => quantity++),
                            icon: const Icon(Icons.add, color: Color(0xFF1E5DAA)),
                            iconSize: isMobile ? 20 : 24,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 12 : 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, {
                      "name": productName,
                      "productTypeId": productId,
                      "quantity": quantity.toString(),
                      "unit": "קג/יחידות",
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5DAA),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 24,
                        vertical: isMobile ? 6 : 8,
                      ),
                    ),
                    child: Text(
                      "אשר",
                      style: TextStyle(
                        fontFamily: 'Assistant',
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
