import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/input_field.dart';
import '../../widgets/donation_widgets/section_title.dart';
import '../../widgets/donation_widgets/address_field.dart';
import '../../theme/homepage_theme.dart';
import '../../theme/report_donation_theme.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../utils/validators/phone_validator.dart';
import '../../utils/validators/business_id_validator.dart';

class BusinessDetailsCard extends StatelessWidget {
  final TextEditingController businessName;
  final TextEditingController address;
  final TextEditingController businessPhone;
  final TextEditingController businessId;
  final Function(double, double) onLocationSelected;

  const BusinessDetailsCard({
    required this.businessName,
    required this.address,
    required this.businessPhone,
    required this.businessId,
    required this.onLocationSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        children: [
          const SectionTitleWidget(text: "פרטי העסק"),
          InputFieldWidget(hint: "שם העסק", controller: businessName),
          AddressFieldWidget(
            controller: address,
            onLocationSelected: onLocationSelected,
          ),
          InputFieldWidget(
            hint: "פלאפון העסק",
            controller: businessPhone,
            validator: validatePhone,
            keyboardType: TextInputType.phone,
          ),
          InputFieldWidget(
            hint: "ח\"פ / עוסק מורשה",
            controller: businessId,
            validator: validateBusinessId,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}