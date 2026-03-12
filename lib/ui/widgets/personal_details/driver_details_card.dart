import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../widgets/donation_widgets/section_title.dart';
import '../../widgets/donation_widgets/input_field.dart';
import '../../utils/validators/phone_validator.dart';

class DriverDetailsCard extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController area;

  const DriverDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        children: [

          const SectionTitleWidget(text: "פרטי הנהג"),

          InputFieldWidget(
            hint: "שם הנהג",
            controller: name,
          ),

          InputFieldWidget(
            hint: "פלאפון",
            controller: phone,
            validator: validatePhone,
            keyboardType: TextInputType.phone,
          ),

          InputFieldWidget(
            hint: "אזור פעילות",
            controller: area,
          ),

        ],
      ),
    );
  }
}