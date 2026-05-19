class DonationCategoryHelper {
  static bool isCategoryDisabled({
    required Map<String, dynamic> product,
    required List<Map<String, dynamic>> donatedItems,
  }) {
    final name = product["name"] as String;
    return donatedItems.any((item) => item["name"] == name && name != "אחר");
  }
}