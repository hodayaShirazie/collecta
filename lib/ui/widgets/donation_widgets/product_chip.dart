import 'package:flutter/material.dart';
import '../../theme/homepage_theme.dart';
import '../../theme/report_donation_theme.dart';

class ProductChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;
  final String? iconPath;

  const ProductChipWidget({
    super.key,
    required this.label,
    required this.selected,
    this.disabled = false,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (disabled) {
      bgColor = Colors.grey[300]!;
    } else if (selected) {
      bgColor = Colors.blue; 
    } else {
      bgColor = Colors.white;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.06).toInt()),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: iconPath != null
                    ? Image.asset(iconPath!, width: 28, height: 28, color: HomepageTheme.latetBlue)
                    : const Icon(Icons.category, color: HomepageTheme.latetBlue, size: 28),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontFamily: 'Assistant', fontSize: 13),
              )
            ],
          ),
        ),
      ),
    );
  }
}