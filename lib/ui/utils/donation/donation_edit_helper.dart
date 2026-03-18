import 'package:flutter/material.dart';
import '../../theme/homepage_theme.dart';
import '../../widgets/donation_widgets/quantity_dialog.dart';
import '../../widgets/donation_widgets/dialog/other_item_dialog.dart';


class DonationEditHelper {

  static Future<void> editDonatedItem({
    required BuildContext context,
    required int index,
    required List<Map<String, dynamic>> donatedItems,
    required VoidCallback refresh,
  }) async {
    Map<String, dynamic> item = donatedItems[index];
    String name = item["name"] ?? "";
    String quantity = item["quantity"]?.toString() ?? "";
    String unit = item["unit"] ?? "";

    if (name.startsWith("אחר")) {
      // פריט "אחר" – פתיחת dialog של תיאור
      // final result = await showOtherItemDialog(context: context);
      final result = await showOtherItemDialog(
        context: context,
        initialText: item["name"] ?? "",
        initialQuantity: int.tryParse(item["quantity"]?.toString() ?? "1") ?? 1,
      );
      if (result != null) {
        // donatedItems[index] = result;
        donatedItems[index] = Map<String, dynamic>.from(result);
        refresh();
      }
    } else {
      // פריט רגיל – פתיחת dialog של כמות
      int currentQuantity = int.tryParse(quantity) ?? 1;
      final result = await showQuantityDialog(
        context: context,
        productName: name,
        productId: item["productTypeId"],
        // productId: item["id"],
        initialQuantity: currentQuantity,
      );

      if (result != null) {
        // donatedItems[index] = result;
        donatedItems[index] = Map<String, dynamic>.from(result);
        refresh();
      }
    }
  }
}