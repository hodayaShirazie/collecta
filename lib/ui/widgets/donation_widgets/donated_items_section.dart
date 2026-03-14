import 'package:flutter/material.dart';

import '../../theme/homepage_theme.dart';
import '../../theme/report_donation_theme.dart';
import 'donated_item_tile.dart';

class DonatedItemsSection extends StatelessWidget {
  final List<Map<String, dynamic>> donatedItems;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const DonatedItemsSection({
    super.key,
    required this.donatedItems,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (donatedItems.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "פריטים שנוספו",
            textAlign: TextAlign.right,
            style: ReportDonationTheme.labelStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: HomepageTheme.latetBlue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: donatedItems.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;

              return DonatedItemTile(
                item: item,
                onEdit: () => onEdit(index),
                onDelete: () => onDelete(index),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}