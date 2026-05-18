import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final bool showDecorativeCircle;
  final bool adminStyle;
  final double? maxContentWidth;

  const LayoutWrapper({
    super.key,
    required this.child,
    this.decoration,
    this.showDecorativeCircle = false,
    this.adminStyle = false,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveChild = maxContentWidth != null
        ? Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth!),
              child: child,
            ),
          )
        : child;

    final scrollable = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: effectiveChild,
          ),
        );
      },
    );

    final List<Widget> circles;
    if (adminStyle) {
      circles = [
        Positioned(
          top: -100, right: -80,
          child: Container(width: 420, height: 420, decoration: HomepageTheme.decorativeCircle),
        ),
        Positioned(
          bottom: -80, left: -70,
          child: Container(width: 340, height: 340, decoration: HomepageTheme.decorativeCircle),
        ),
        Positioned(
          top: 180, left: -60,
          child: Container(width: 240, height: 240, decoration: HomepageTheme.decorativeCircle),
        ),
      ];
    } else if (showDecorativeCircle) {
      circles = [
        Positioned(
          top: -120, right: -80,
          child: Container(width: 300, height: 300, decoration: HomepageTheme.decorativeCircle),
        ),
      ];
    } else {
      circles = [];
    }

    final content = SafeArea(
      child: circles.isEmpty
          ? scrollable
          : Stack(children: [...circles, Positioned.fill(child: scrollable)]),
    );

    if (decoration != null) {
      return DecoratedBox(decoration: decoration!, child: content);
    }
    return content;
  }
}
