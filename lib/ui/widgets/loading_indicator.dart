import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  static const _blue = Color(0xFF1E5DAA);
  static const _bgStart = Color(0xFFEAF2FF);
  static const _circleColor = Color(0xFFFFF9C4);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgStart, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: _circleColor.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Center(
              child: CircularProgressIndicator(color: _blue),
            ),
          ],
        ),
      ),
    );
  }
}
