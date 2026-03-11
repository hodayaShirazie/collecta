

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
    return Align(
      alignment: Alignment.center, 
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5, 
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
            )
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// צד ימין - שם וכמות
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item["name"] ?? "",
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
      ),
    );
  }
}