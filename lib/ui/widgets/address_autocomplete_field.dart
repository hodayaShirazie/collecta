import 'package:flutter/material.dart';
import '../../data/models/place_prediction.dart';
import 'labeled_text_field.dart';

class AddressAutocompleteField extends StatelessWidget {

  final String label;
  final TextEditingController controller;
  final List<PlacePrediction> predictions;
  final Function(String) onChanged;
  final Function(PlacePrediction) onSelect;

  const AddressAutocompleteField({
    super.key,
    required this.label,
    required this.controller,
    required this.predictions,
    required this.onChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        LabeledTextField(
          label: label,
          controller: controller,
          onChanged: onChanged,
        ),

        if (predictions.isNotEmpty)
          ...predictions.map(
            (p) => ListTile(
              title: Text(p.description),
              onTap: () => onSelect(p),
            ),
          ),

      ],
    );
  }
}