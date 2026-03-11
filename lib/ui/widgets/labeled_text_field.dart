import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {

  final String label;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? labelStyle;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.decoration,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Text(
            label,
            style: labelStyle ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 4),

          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              decoration: decoration ??
                  const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
            ),
          ),

        ],
      ),
    );
  }
}