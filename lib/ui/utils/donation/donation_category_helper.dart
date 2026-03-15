class DonationCategoryHelper {
  static bool isCategoryDisabled({
    required Map<String, dynamic> product,
    required List<Map<String, dynamic>> donatedItems,
  }) {

    if (product['name'] == 'אחר') return false;

    return donatedItems.any((item) => item['name'] == product['name'] && item['name'] != 'אחר');
  }
}