import 'package:flutter/material.dart';

import '../../widgets/donation_widgets/quantity_dialog.dart';
import '../../widgets/donation_widgets/dialog/other_item_dialog.dart';

class DonationToggleProductHelper {
  static Future<void> toggleProduct({
    required BuildContext context,
    required Map<String, dynamic> product,
    required List<String> selectedProducts,
    required List<Map<String, dynamic>> donatedItems,
    required VoidCallback refresh,
  }) async {
    final name = product["name"] as String;
    final id = product["id"] as String?;

    if (selectedProducts.contains(name)) {
      selectedProducts.remove(name);
      if (name != "אחר") {
        donatedItems.removeWhere((item) => item["productTypeId"] == id);
      } else {
        final lastIndex = donatedItems.lastIndexWhere(
          (item) => (item["name"] as String?)?.startsWith("אחר") ?? false,
        );
        if (lastIndex >= 0) donatedItems.removeAt(lastIndex);
      }
      refresh();
      return;
    }

    selectedProducts.add(name);

    if (name == "אחר") {
      final result = await showOtherItemDialog(context: context);
      if (result != null) {
        donatedItems.add({
          ...result,
          "id": "",
          "productTypeId": null,
        });
      } else {
        selectedProducts.remove(name);
      }
    } else {
      final result = await showQuantityDialog(
        context: context,
        productName: name,
        productId: id,
      );
      if (result != null) {
        donatedItems.add({
          ...result,
          "id": "",
          "productTypeId": id,
        });
      } else {
        selectedProducts.remove(name);
      }
    }

    refresh();
  }
}