import 'package:flutter/material.dart';
import '../../theme/report_donation_theme.dart';

class SectionTitleWidget extends StatelessWidget {
  final String text;
  const SectionTitleWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          text,
          style: ReportDonationTheme.labelStyle,
        ),
      ),
    );
  }
}