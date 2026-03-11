import 'package:flutter/material.dart';

import '../../../services/places_service.dart';
import '../../../data/models/place_prediction.dart';
import '../../theme/report_donation_theme.dart';

class AddressFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(double lat, double lng) onLocationSelected;

  const AddressFieldWidget({
    super.key,
    required this.controller,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Autocomplete<PlacePrediction>(
          optionsBuilder: (TextEditingValue value) async {
            if (value.text.isEmpty) return const [];

            final service = PlacesService();
            return await service.autocomplete(value.text);
          },

          displayStringForOption: (option) => option.description,

          onSelected: (selection) async {
            controller.text = selection.description;

            final service = PlacesService();
            final coords = await service.getPlaceDetails(selection.placeId);

            print("coords: ${coords.lat}, ${coords.lng}");

            onLocationSelected(coords.lat, coords.lng);
          },

          fieldViewBuilder: (context, fieldController, focusNode, onEditingComplete) {
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              validator: (value) =>
                  value == null || value.isEmpty ? "שדה חובה" : null,
              decoration: ReportDonationTheme.inputDecoration("כתובת העסק"),
              textAlign: TextAlign.right,
              onEditingComplete: onEditingComplete,
            );
          },
        ),
      ),
    );
  }
}