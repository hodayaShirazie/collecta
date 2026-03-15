// class DonationCategoryHelper {
//   static bool isCategoryDisabled({
//     required Map<String, dynamic> product,
//     required List<Map<String, dynamic>> donatedItems,
//   }) {

//     if (product['name'] == 'אחר') return false;

//     return donatedItems.any((item) => item['name'] == product['name'] && item['name'] != 'אחר');
//   }
// }


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