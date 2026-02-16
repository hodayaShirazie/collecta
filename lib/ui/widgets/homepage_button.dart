import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';

class HomepageButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const HomepageButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 65,
          decoration: HomepageTheme.buttonDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: HomepageTheme.latetBlue, size: 28),
              const SizedBox(width: 15),
              Text(
                title,
                style: HomepageTheme.buttonTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}