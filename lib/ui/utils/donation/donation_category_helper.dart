class DonationCategoryHelper {
  static bool isCategoryDisabled({
    required Map<String, dynamic> product,
    required List<Map<String, dynamic>> donatedItems,
  }) {
    final name = product["name"] as String;

    // אם המוצר כבר ב-donatedItems אבל לא "אחר", נחסום
    // אם זה מוצר חדש (לא קיים ב-donatedItems) – אפשר לבחור
    return donatedItems.any((item) => item["name"] == name && name != "אחר");
  }
}