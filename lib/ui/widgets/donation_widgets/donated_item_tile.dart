

import 'package:flutter/material.dart';
import '../../theme/homepage_theme.dart';

class DonatedItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DonatedItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0DCF0), width: 1),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// צד ימין - שם וכמות
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["display"] ?? item["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  "${item["quantity"] ?? ""} ${item["unit"] ?? ""}",
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ],
              ),
            ),
          

            /// צד שמאל - אייקונים
            Row(
              children: [

                GestureDetector(
                  onTap: onEdit,
                  child: Image.asset(
                    "assets/images/category_icons/edit.png",
                    width: 18,
                    height: 18,
                    color: HomepageTheme.latetBlue, // צביעה כחולה
                  ),
                ),

                const SizedBox(width: 20),

                GestureDetector(
                  onTap: onDelete,
                  child: Image.asset(
                    "assets/images/category_icons/delete.png",
                    width: 18,
                    height: 18,
                    color: HomepageTheme.latetBlue,
                  ),
                ),

              ],
            )
          ],
        ),
    );
  }
}