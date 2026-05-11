import 'package:flutter/material.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;

  const LayoutWrapper({super.key, required this.child, this.decoration});

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: child,
            ),
          );
        },
      ),
    );

    if (decoration != null) {
      return DecoratedBox(
        decoration: decoration!,
        child: content,
      );
    }
    return content;
  }
}
