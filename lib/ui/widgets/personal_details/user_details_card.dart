import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/input_field.dart';
import '../../widgets/donation_widgets/section_title.dart';
import '../../widgets/donation_widgets/card.dart';

class DonorDetailsCard extends StatelessWidget {
  final TextEditingController donorName;

  const DonorDetailsCard({
    required this.donorName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        children: [
          const SectionTitleWidget(text: "פרטי התורם"),
          InputFieldWidget(
            hint: "שם בעל העסק",
            controller: donorName,
          ),
        ],
      ),
    );
  }
}