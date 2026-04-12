import 'package:flutter/material.dart';

import '../../../services/places_service.dart';
import '../../../data/models/place_prediction.dart';
import '../../theme/report_donation_theme.dart';

class AddressFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function(double lat, double lng) onLocationSelected;
  final VoidCallback? onLocationCleared;
  final bool initialIsConfirmed;

  const AddressFieldWidget({
    super.key,
    required this.controller,
    required this.onLocationSelected,
    this.onLocationCleared,
    this.initialIsConfirmed = false,
  });

  @override
  State<AddressFieldWidget> createState() => _AddressFieldWidgetState();
}

class _AddressFieldWidgetState extends State<AddressFieldWidget> {
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _isConfirmed = widget.initialIsConfirmed;
  }

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
            widget.controller.text = selection.description;
            setState(() => _isConfirmed = true);

            final service = PlacesService();
            final coords = await service.getPlaceDetails(selection.placeId);

            widget.onLocationSelected(coords.lat, coords.lng);
          },

          fieldViewBuilder: (context, fieldController, focusNode, onEditingComplete) {
            if (widget.controller.text.isNotEmpty && fieldController.text.isEmpty) {
              fieldController.text = widget.controller.text;
            }
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              validator: (value) {
                if (value == null || value.isEmpty) return "שדה חובה";
                if (!_isConfirmed) return "יש לבחור כתובת מהרשימה";
                return null;
              },
              decoration: ReportDonationTheme.inputDecoration("כתובת העסק"),
              textAlign: TextAlign.right,
              onChanged: (value) {
                widget.controller.text = value;
                if (_isConfirmed) {
                  setState(() => _isConfirmed = false);
                  widget.onLocationCleared?.call();
                }
              },
              onEditingComplete: onEditingComplete,
            );
          },
        ),
      ),
    );
  }
}
