import 'package:flutter/material.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;

  const LayoutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: child,
          ),
        ),
      ),
    );
  }
}
