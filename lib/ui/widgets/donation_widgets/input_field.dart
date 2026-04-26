import 'package:flutter/material.dart';
import '../../theme/report_donation_theme.dart';

class InputFieldWidget extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool readOnly;

  const InputFieldWidget({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: readOnly
              ? null
              : (validator ??
                  (value) =>
                      value == null || value.isEmpty ? "שדה חובה" : null),
          decoration: ReportDonationTheme.inputDecoration(hint),
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}