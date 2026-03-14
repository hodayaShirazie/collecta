import 'package:flutter/material.dart';
import '../../theme/homepage_theme.dart';
import '../../widgets/donation_widgets/quantity_dialog.dart';
import '../../widgets/donation_widgets/dialog/other_item_dialog.dart';


class DonationEditHelper {
  /// פונקציה לעריכת פריט תרומה
  static Future<void> editDonatedItem({
    required BuildContext context,
    required int index,
    required List<Map<String, dynamic>> donatedItems,
    required VoidCallback refresh,
  }) async {
    Map<String, dynamic> item = donatedItems[index];
    String name = item["name"] ?? "";
    String quantity = item["quantity"] ?? "";
    String unit = item["unit"] ?? "";

    if (name.startsWith("אחר")) {
      // פריט "אחר" – פתיחת dialog של תיאור
      final result = await showOtherItemDialog(context: context);
      if (result != null) {
        donatedItems[index] = result;
        refresh();
      }
    } else {
      // פריט רגיל – פתיחת dialog של כמות
      int currentQuantity = int.tryParse(quantity) ?? 1;
      final result = await showQuantityDialog(
        context: context,
        productName: name,
        productId: item["productTypeId"],
        initialQuantity: currentQuantity,
      );

      if (result != null) {
        donatedItems[index] = result;
        refresh();
      }
    }
  }
}