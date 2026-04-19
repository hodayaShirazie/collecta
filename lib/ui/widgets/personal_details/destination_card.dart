import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../widgets/donation_widgets/input_field.dart';
import '../../widgets/donation_widgets/address_field.dart';

class DestinationCard extends StatelessWidget {

  /// The weekday label displayed as a read-only header (e.g. "ראשון").
  final String dayLabel;

  final TextEditingController name;
  final TextEditingController address;

  final Function(double, double) onLocationSelected;

  const DestinationCard({
    super.key,
    required this.dayLabel,
    required this.name,
    required this.address,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Day header — read only
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF2C5AA0),
                ),
                const SizedBox(width: 8),
                Text(
                  'יום $dayLabel',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C5AA0),
                  ),
                ),
              ],
            ),
          ),

          InputFieldWidget(
            hint: "שם יעד",
            controller: name,
            validator: (_) => null, // optional field
          ),

          AddressFieldWidget(
            controller: address,
            onLocationSelected: onLocationSelected,
            isRequired: false,
          ),

        ],
      ),
    );
  }
}
