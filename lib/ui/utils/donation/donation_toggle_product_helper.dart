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
    final name = product["name"];
    final id = product["id"];

    if (selectedProducts.contains(name)) {
      selectedProducts.remove(name);
      refresh();
      return;
    }

    selectedProducts.add(name);

    // if (name == "אחר") {
    //   final result = await showOtherItemDialog(context: context);

    //   if (result != null) {
    //     donatedItems.add(result);
    //   }
    // } else {
    //   final result = await showQuantityDialog(
    //     context: context,
    //     productName: name,
    //     productId: id,
    //   );

    //   if (result != null) {
    //     donatedItems.add(result);
    //   }
    // }
    if (name == "אחר") {
    final result = await showOtherItemDialog(context: context);

    if (result != null) {
      donatedItems.add({
        ...result,
        "id": "",
        "productTypeId": null,
      });
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
    }
  }

    refresh();
  }
}