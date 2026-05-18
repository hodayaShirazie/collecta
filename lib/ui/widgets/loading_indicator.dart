import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: HomepageTheme.decorativeCircle,
              ),
            ),
            const Center(
              child: CircularProgressIndicator(color: HomepageTheme.latetBlue),
            ),
          ],
        ),
      ),
    );
  }
}
