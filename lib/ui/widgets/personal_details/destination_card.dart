import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../widgets/donation_widgets/input_field.dart';
import '../../widgets/donation_widgets/address_field.dart';
import '../../widgets/donation_widgets/section_title.dart';

class DestinationCard extends StatelessWidget {

  final TextEditingController name;
  final TextEditingController day;
  final TextEditingController address;

  final Function(double,double) onLocationSelected;

  const DestinationCard({
    super.key,
    required this.name,
    required this.day,
    required this.address,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        children: [

          const SectionTitleWidget(text: "יעד"),

          InputFieldWidget(
            hint: "שם יעד",
            controller: name,
          ),

          InputFieldWidget(
            hint: "יום",
            controller: day,
          ),

          AddressFieldWidget(
            controller: address,
            onLocationSelected: onLocationSelected,
          ),

        ],
      ),
    );
  }
}