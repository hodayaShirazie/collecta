import 'package:flutter_dotenv/flutter_dotenv.dart';

class DonationConstants {

  static List<Map<String, dynamic>> get products => [
    {"name": "מאפים", "id": dotenv.env['PRODUCT_BAKERY_ID'], "icon": "assets/images/category_icons/croissant.png"},
    {"name": "עוגות", "id": dotenv.env['PRODUCT_CAKE_ID'], "icon": "assets/images/category_icons/cake.png"},
    {"name": "היגיינה", "id": dotenv.env['PRODUCT_HYGIENE_ID'], "icon": "assets/images/category_icons/hygiene.png"},
    {"name": "מוצרי חלב", "id": dotenv.env['PRODUCT_DAIRY_ID'], "icon": "assets/images/category_icons/milk.png"},
    {"name": "פירות וירקות", "id": dotenv.env['PRODUCT_FRUITS_ID'], "icon": "assets/images/category_icons/carrot.png"},
    {"name": "מוצרי יסוד", "id": dotenv.env['PRODUCT_BASIC_ID'], "icon": "assets/images/category_icons/box.png"},
    {"name": "אחר", "id": dotenv.env['PRODUCT_OTHER_ID'], "icon": "assets/images/category_icons/more.png"},
  ];

  static final List<String> timeSlots = [
    "8:00-10:00",
    "10:00-12:00",
    "12:00-14:00"
  ];
}