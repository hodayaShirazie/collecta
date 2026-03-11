import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/input_field.dart';
import '../../widgets/donation_widgets/section_title.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../utils/validators/phone_validator.dart';

class ContactDetailsCard extends StatelessWidget {
  final TextEditingController contactName;
  final TextEditingController contactPhone;

  const ContactDetailsCard({
    required this.contactName,
    required this.contactPhone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        children: [
          const SectionTitleWidget(text: "איש קשר"),
          InputFieldWidget(hint: "שם איש קשר", controller: contactName),
          InputFieldWidget(
            hint: "פלאפון איש קשר",
            controller: contactPhone,
            validator: validatePhone,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}