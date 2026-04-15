import 'package:flutter/material.dart';
import '../../services/activity_zone_service.dart';
import '../../services/places_service.dart';
import '../../services/address_service.dart';
import '../../data/models/activity_zone_model.dart';
import '../../data/models/place_prediction.dart';
import '../widgets/custom_popup_dialog.dart';

class ActivityZonesAdmin extends StatefulWidget {
  final String organizationId;

  const ActivityZonesAdmin({super.key, required this.organizationId});

  @override
  State<ActivityZonesAdmin> createState() => _ActivityZonesAdminState();
}

class _ActivityZonesAdminState extends State<ActivityZonesAdmin> {
  final ActivityZoneService _service = ActivityZoneService();
  final TextEditingController _searchController = TextEditingController();

  List<ActivityZoneModel> _zones = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final result = await _service.getActivityZones(widget.organizationId);
      setState(() {
        _zones = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<ActivityZoneModel> get _filteredZones {
    if (_searchQuery.isEmpty) return _zones;
    return _zones.where((z) {
      final addressName = z.address?.name ?? '';
      return z.name.contains(_searchQuery) ||
          addressName.contains(_searchQuery);
    }).toList();
  }

  void _openAddDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ActivityZoneDialog(
        organizationId: widget.organizationId,
      ),
    );
    if (result == true) _loadZones();
  }

  void _openEditDialog(ActivityZoneModel zone) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ActivityZoneDialog(
        organizationId: widget.organizationId,
        existing: zone,
      ),
    );
    if (result == true) _loadZones();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8EDF6),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddDialog,
          backgroundColor: const Color(0xFF2C5AA0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'אזורי פעילות',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5AA0),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: const InputDecoration(
                                hintText: 'חיפוש אזור פעילות...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // List
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredZones.isEmpty
                              ? const Center(
                                  child: Text('אין אזורי פעילות להצגה'))
                              : ListView.separated(
                                  itemCount: _filteredZones.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 15),
                                  itemBuilder: (context, index) {
                                    final zone = _filteredZones[index];
                                    return _ZoneTile(
                                      zone: zone,
                                      onEdit: () => _openEditDialog(zone),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────
// Zone list tile
// ────────────────────────────────────────────
class _ZoneTile extends StatelessWidget {
  final ActivityZoneModel zone;
  final VoidCallback onEdit;

  const _ZoneTile({required this.zone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8EDF6),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 28,
                color: Color(0xFF2C5AA0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Assistant',
                      color: Color(0xFF1E2A38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (zone.address != null)
                    Text(
                      zone.address!.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    'טווח: ${zone.range.toStringAsFixed(0)} מ\'',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C5AA0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────
// Add / Edit dialog
// ────────────────────────────────────────────
class _ActivityZoneDialog extends StatefulWidget {
  final String organizationId;
  final ActivityZoneModel? existing;

  const _ActivityZoneDialog({
    required this.organizationId,
    this.existing,
  });

  @override
  State<_ActivityZoneDialog> createState() => _ActivityZoneDialogState();
}

class _ActivityZoneDialogState extends State<_ActivityZoneDialog> {
  final ActivityZoneService _zoneService = ActivityZoneService();
  final PlacesService _placesService = PlacesService();
  final AddressService _addressService = AddressService();

  final _nameCtrl = TextEditingController();
  final _rangeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  List<PlacePrediction> _predictions = [];
  String? _selectedAddressId;

  bool _isSaving = false;
  String? _errorText;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final z = widget.existing!;
      _nameCtrl.text = z.name;
      _rangeCtrl.text = z.range.toStringAsFixed(0);
      _addressCtrl.text = z.address?.name ?? '';
      _selectedAddressId = z.addressId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rangeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAddressChanged(String value) async {
    // Reset selection when user types again
    _selectedAddressId = null;

    if (value.length < 2) {
      setState(() => _predictions = []);
      return;
    }
    try {
      final results = await _placesService.autocomplete(value);
      setState(() => _predictions = results);
    } catch (_) {
      setState(() => _predictions = []);
    }
  }

  Future<void> _onPredictionSelected(PlacePrediction prediction) async {
    setState(() {
      _addressCtrl.text = prediction.description;
      _predictions = [];
    });

    try {
      final latLng =
          await _placesService.getPlaceDetails(prediction.placeId);
      final addressId = await _addressService.createAddress(
        name: prediction.description,
        lat: latLng.lat,
        lng: latLng.lng,
      );
      setState(() {
        _selectedAddressId = addressId;
      });
    } catch (e) {
      setState(() => _errorText = 'שגיאה בטעינת הכתובת: $e');
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final rangeText = _rangeCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = 'נא להזין שם לאזור הפעילות');
      return;
    }

    if (rangeText.isEmpty) {
      setState(() => _errorText = 'נא להזין טווח');
      return;
    }

    final range = double.tryParse(rangeText);
    if (range == null || range <= 0) {
      setState(() => _errorText = 'טווח לא תקין');
      return;
    }

    if (_selectedAddressId == null) {
      setState(() => _errorText = 'נא לבחור כתובת מהרשימה');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      if (_isEdit) {
        await _zoneService.updateActivityZone(
          id: widget.existing!.id,
          name: name,
          addressId: _selectedAddressId!,
          range: range,
        );
      } else {
        await _zoneService.createActivityZone(
          name: name,
          addressId: _selectedAddressId!,
          range: range,
          organizationId: widget.organizationId,
        );
      }
      if (!mounted) return;
      final wasEdit = _isEdit;
      Navigator.of(context).pop(true);
      await showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: CustomPopupDialog(
            title: wasEdit ? 'עודכן בהצלחה' : 'נוסף בהצלחה',
            message: wasEdit
                ? 'אזור הפעילות עודכן בהצלחה!'
                : 'אזור הפעילות נוסף בהצלחה!',
            buttonText: 'אישור',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorText = 'שגיאה בשמירה: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEdit ? 'עריכת אזור פעילות' : 'הוספת אזור פעילות',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5AA0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Name field
              _buildLabel('שם / כינוי'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'לדוגמה: מרכז תל אביב',
              ),
              const SizedBox(height: 16),

              // Address field with autocomplete
              _buildLabel('כתובת'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _addressCtrl,
                hint: 'חפש כתובת...',
                onChanged: _onAddressChanged,
              ),
              if (_predictions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: _predictions
                        .map(
                          (p) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on_outlined,
                                color: Color(0xFF2C5AA0), size: 18),
                            title: Text(p.description,
                                style: const TextStyle(fontSize: 14)),
                            onTap: () => _onPredictionSelected(p),
                          ),
                        )
                        .toList(),
                  ),
                ),

              // Show confirmation that address was selected (without exposing coordinates)
              if (_selectedAddressId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'הכתובת נבחרה בהצלחה',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Range field
              _buildLabel('טווח (מטרים)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _rangeCtrl,
                hint: 'לדוגמה: 500',
                keyboardType: TextInputType.number,
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF2C5AA0)),
                      ),
                      child: const Text('ביטול',
                          style: TextStyle(color: Color(0xFF2C5AA0))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5AA0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _isEdit ? 'שמור' : 'הוסף',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E2A38),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
