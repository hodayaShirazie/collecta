// import 'package:flutter/material.dart';
// import '../theme/homepage_theme.dart';

// class HomepageButton extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onPressed;

//   const HomepageButton({
//     super.key,
//     required this.title,
//     required this.icon,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 45),
//       child: GestureDetector(
//         onTap: onPressed,
//         child: Container(
//           height: 65,
//           decoration: HomepageTheme.buttonDecoration,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: HomepageTheme.latetBlue, size: 28),
//               const SizedBox(width: 15),
//               Text(
//                 title,
//                 style: HomepageTheme.buttonTextStyle,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';

class HomepageButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool flipIcon; 

  const HomepageButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.flipIcon = false,
  });

  @override
  State<HomepageButton> createState() => _HomepageButtonState();
}

class _HomepageButtonState extends State<HomepageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.08,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(scale: _scaleAnimation.value, child: child);
            },
            child: Container(
              height: 70,
              decoration: HomepageTheme.buttonDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: widget.flipIcon
                        ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
                        : Matrix4.identity(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HomepageTheme.latetYellow.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon,
                          color: HomepageTheme.latetBlue, size: 24),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.right,
                      style: HomepageTheme.buttonTextStyle,
                    ),
                  ),

                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: HomepageTheme.latetBlue.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
