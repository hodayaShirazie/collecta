import 'package:flutter/material.dart';

import '../../../services/places_service.dart';
import '../../../data/models/place_prediction.dart';
import '../../../data/models/lat_lng_model.dart';
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
  bool _isGeocoding = false;
  String? _geocodeError;

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
            if (value.text.length < 3) return const [];

            final service = PlacesService();
            final results = await service.autocomplete(value.text);

            // אם גוגל לא מצא כלום — מציעים למשתמש להשתמש בטקסט שהוא הקליד
            if (results.isEmpty) {
              return [
                PlacePrediction(
                  description: value.text.trim(),
                  placeId: '',
                  isManual: true,
                ),
              ];
            }

            return results;
          },

          displayStringForOption: (option) => option.description,

          onSelected: (selection) async {
            widget.controller.text = selection.description;
            setState(() {
              _isGeocoding = true;
              _geocodeError = null;
              _isConfirmed = false;
            });

            try {
              final service = PlacesService();
              final LatLngModel coords;

              if (selection.isManual) {
                coords = await service.geocodeByText(selection.description);
              } else {
                coords = await service.getPlaceDetails(selection.placeId);
              }

              setState(() {
                _isConfirmed = true;
                _isGeocoding = false;
              });
              widget.onLocationSelected(coords.lat, coords.lng);
            } catch (_) {
              setState(() {
                _isGeocoding = false;
                _geocodeError = "לא ניתן לאמת את הכתובת, נסה לנסח מחדש";
              });
            }
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
                if (_isGeocoding) return "ממתין לאימות כתובת...";
                if (_geocodeError != null) return _geocodeError;
                if (!_isConfirmed) return "יש לבחור כתובת מהרשימה או ללחוץ על האפשרות המוצעת";
                return null;
              },
              decoration: ReportDonationTheme.inputDecoration("כתובת העסק").copyWith(
                errorMaxLines: 2,
                suffixIcon: _isGeocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
              textAlign: TextAlign.right,
              onChanged: (value) {
                widget.controller.text = value;
                if (_isConfirmed || _geocodeError != null) {
                  setState(() {
                    _isConfirmed = false;
                    _geocodeError = null;
                  });
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
