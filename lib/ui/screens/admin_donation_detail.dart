import 'package:flutter/material.dart';

import '../theme/homepage_theme.dart';
import '../theme/report_donation_theme.dart';
import '../theme/my_donations_theme.dart';

import '../widgets/layout_wrapper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/donation_widgets/card.dart';
import '../widgets/donation_widgets/section_title.dart';
import '../widgets/donation_widgets/input_field.dart';
import '../widgets/donation_widgets/time_slots_card.dart';
import '../widgets/donation_widgets/donation_receipt_button.dart';
import '../widgets/custom_popup_dialog.dart';

import '../utils/donation/donation_constants.dart';

import '../../data/models/donation_model.dart';
import '../../data/models/driver_model.dart';
import '../../services/donation_service.dart';

class AdminDonationDetail extends StatefulWidget {
  final String donationId;
  final List<DriverProfile> drivers;

  const AdminDonationDetail({
    super.key,
    required this.donationId,
    required this.drivers,
  });

  @override
  State<AdminDonationDetail> createState() => _AdminDonationDetailState();
}

class _AdminDonationDetailState extends State<AdminDonationDetail> {
  final DonationService _service = DonationService();
  late ValueNotifier<bool> _isCancellingNotifier;

  DonationModel? donation;
  bool isLoading = true;

  late TextEditingController businessNameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController businessPhoneCtrl;
  late TextEditingController businessIdCtrl;
  late TextEditingController contactNameCtrl;
  late TextEditingController contactPhoneCtrl;

  List<String> selectedTimeSlots = [];
  List<Map<String, dynamic>> donatedItems = [];

  @override
  void initState() {
    super.initState();
    _isCancellingNotifier = ValueNotifier(false);
    businessNameCtrl = TextEditingController();
    addressCtrl = TextEditingController();
    businessPhoneCtrl = TextEditingController();
    businessIdCtrl = TextEditingController();
    contactNameCtrl = TextEditingController();
    contactPhoneCtrl = TextEditingController();
    _loadDonation();
  }

  Future<void> _loadDonation() async {
    try {
      final d = await _service.getDonationById(widget.donationId);
      businessNameCtrl.text = d.businessName;
      addressCtrl.text = d.businessAddress.name;
      businessPhoneCtrl.text = d.businessPhone;
      businessIdCtrl.text = d.crn;
      contactNameCtrl.text = d.contactName;
      contactPhoneCtrl.text = d.contactPhone;

      selectedTimeSlots = d.pickupTimes
          .expand((e) => DonationConstants.expandPickupTimeToSlots(e.from, e.to))
          .toList();

      donatedItems = d.products.map<Map<String, dynamic>>((p) {
        final typeId = p.type.id;
        final typeName = p.type.name;
        final typeDescription = p.type.description ?? '';

        final constantProduct = DonationConstants.products.firstWhere(
          (prod) => prod["id"] == typeId,
          orElse: () => <String, dynamic>{},
        );

        final resolvedName = constantProduct.isNotEmpty
            ? constantProduct["name"] as String
            : typeName;

        final displayName =
            (resolvedName == "אחר" && typeDescription.isNotEmpty)
                ? "אחר: $typeDescription"
                : resolvedName;

        return <String, dynamic>{
          "id": p.id,
          "productTypeId": typeId,
          "name": displayName,
          "icon": constantProduct["icon"] ?? '',
          "quantity": p.quantity.toString(),
          "unit": 'ק"ג/יחידות',
          "display": displayName,
        };
      }).toList();

      setState(() {
        donation = d;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading donation: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _isCancellingNotifier.dispose();
    businessNameCtrl.dispose();
    addressCtrl.dispose();
    businessPhoneCtrl.dispose();
    businessIdCtrl.dispose();
    contactNameCtrl.dispose();
    contactPhoneCtrl.dispose();
    super.dispose();
  }

  String _statusText(String status) {
    switch (status) {
      case "pending":
        return "ממתין";
      case "collected":
        return "נאסף";
      case "cancelled":
        return "בוטל";
      default:
        return status;
    }
  }

  String _driverName(String driverId) {
    if (driverId.isEmpty) return "לא שויך";
    try {
      final driver =
          widget.drivers.firstWhere((d) => d.user.id == driverId);
      return driver.user.name.isNotEmpty
          ? driver.user.name
          : "נהג ללא שם";
    } catch (_) {
      return "לא שויך";
    }
  }

  Future<void> _cancelDonation(String reason) async {
    _isCancellingNotifier.value = true;
    try {
      await _service.cancelDonation(widget.donationId, reason);
      if (!mounted) return;
      Navigator.pop(context); 
    } catch (e) {
      _isCancellingNotifier.value = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("שגיאה: $e")));
    }
  }

  void _showCancelDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.12),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "ביטול תרומה",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E5DAA),
                          fontFamily: 'Assistant',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 2,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Color(0xFF1E5DAA).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "יש להזין סיבת ביטול:",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          fontFamily: 'Assistant',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 1,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "סיבת הביטול...",
                          filled: true,
                          fillColor: const Color(0xFFF8F9FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1E5DAA), width: 1.5),
                          ),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF888888),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                            child: const Text("חזור",
                                style: TextStyle(fontFamily: 'Assistant', fontSize: 14)),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isCancellingNotifier,
                            builder: (context, isCancelling, _) {
                              return ElevatedButton(
                                onPressed: (reasonCtrl.text.trim().isEmpty || isCancelling)
                                    ? null
                                    : () {
                                        Navigator.pop(ctx);
                                        _cancelDonation(reasonCtrl.text.trim());
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E5DAA),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                ),
                                child: isCancelling
                                    ? const SizedBox(
                                        width: 16, height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text("אישור",
                                        style: TextStyle(fontFamily: 'Assistant', fontWeight: FontWeight.w600, fontSize: 14)),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDriverPicker() {
    final d = donation!;
    DriverProfile? selected;
    final DriverProfile? preSelected = d.driverId.isEmpty
        ? null
        : widget.drivers.cast<DriverProfile?>().firstWhere(
            (dr) => dr!.user.id == d.driverId,
            orElse: () => null,
          );

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.12),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "שיוך נהג לתרומה",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E5DAA),
                        fontFamily: 'Assistant',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E5DAA).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    widget.drivers.isEmpty
                        ? const Text(
                            "אין נהגים בארגון",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF555555),
                              fontFamily: 'Assistant',
                            ),
                          )
                        : SizedBox(
                            width: double.maxFinite,
                            child: ListView(
                              shrinkWrap: true,
                              children: widget.drivers.map((driver) {
                                final isCurrentDriver =
                                    driver.user.id == d.driverId;
                                return RadioListTile<DriverProfile>(
                                  title: Text(
                                    driver.user.name.isNotEmpty
                                        ? driver.user.name
                                        : "נהג ללא שם",
                                    style: const TextStyle(
                                        fontFamily: 'Assistant'),
                                  ),
                                  subtitle: isCurrentDriver
                                      ? const Text(
                                          "נהג נוכחי",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontFamily: 'Assistant'),
                                        )
                                      : null,
                                  value: driver,
                                  groupValue: selected ?? preSelected,
                                  onChanged: (val) =>
                                      setDialogState(() => selected = val),
                                );
                              }).toList(),
                            ),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF888888),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          child: const Text("ביטול",
                              style: TextStyle(
                                  fontFamily: 'Assistant', fontSize: 14)),
                        ),
                        if (widget.drivers.isNotEmpty)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5DAA),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                            ),
                            onPressed: () async {
                              final chosenDriver = selected ?? preSelected;
                              if (chosenDriver == null ||
                                  chosenDriver.user.id == d.driverId) {
                                Navigator.pop(ctx);
                                return;
                              }
                              Navigator.pop(ctx);
                              try {
                                await _service.assignDriverToDonation(
                                  donationId: d.id,
                                  driverId: chosenDriver.user.id,
                                );
                                setState(() {
                                  donation =
                                      d.copyWith(driverId: chosenDriver.user.id);
                                });
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomPopupDialog(
                                    title: "שיוך בוצע",
                                    message:
                                        "התרומה שויכה לנהג ${chosenDriver.user.name}",
                                    buttonText: "סגור",
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomPopupDialog(
                                    title: "שגיאה",
                                    message: "שגיאה בשיוך נהג: $e",
                                    buttonText: "סגור",
                                  ),
                                );
                              }
                            },
                            child: const Text("שמור",
                                style: TextStyle(
                                  fontFamily: 'Assistant',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: LoadingIndicator());

    final d = donation!;

    return Scaffold(
      body: LayoutWrapper(
        decoration: BoxDecoration(
          gradient: HomepageTheme.pageGradient,
        ),
        adminStyle: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 350),
            child: Column(
              children: [
                const SizedBox(height: HomepageTheme.topPadding),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: HomepageTheme.latetBlue, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text("פרטי תרומה",
                          textAlign: TextAlign.center,
                          style: ReportDonationTheme.headerStyle),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 35),

                // פרטי העסק (read-only)
                CardWidget(
                  child: Column(
                    children: [
                      const SectionTitleWidget(text: "פרטי העסק"),
                      InputFieldWidget(
                        hint: "שם העסק",
                        controller: businessNameCtrl,
                        readOnly: true,
                      ),
                      InputFieldWidget(
                        hint: "כתובת העסק",
                        controller: addressCtrl,
                        readOnly: true,
                      ),
                      InputFieldWidget(
                        hint: "פלאפון העסק",
                        controller: businessPhoneCtrl,
                        readOnly: true,
                        keyboardType: TextInputType.phone,
                      ),
                      InputFieldWidget(
                        hint: "ח.פ",
                        controller: businessIdCtrl,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),

                CardWidget(
                  child: Column(
                    children: [
                      const SectionTitleWidget(text: "איש קשר"),
                      InputFieldWidget(
                        hint: "שם איש קשר",
                        controller: contactNameCtrl,
                        readOnly: true,
                      ),
                      InputFieldWidget(
                        hint: "פלאפון איש קשר",
                        controller: contactPhoneCtrl,
                        readOnly: true,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),

                TimeSlotsCard(
                  timeSlots: DonationConstants.timeSlots,
                  selectedTimeSlots: selectedTimeSlots,
                  toggleTime: (_) {},
                ),

                if (donatedItems.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "פריטים שנוספו",
                          textAlign: TextAlign.right,
                          style: ReportDonationTheme.labelStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: HomepageTheme.latetBlue,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...donatedItems.map((item) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFD0DCF0), width: 1),
                              ),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["display"] ?? item["name"] ?? "",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${item["quantity"] ?? ""} ${item["unit"] ?? ""}",
                                          style:
                                              const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                CardWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitleWidget(text: "פרטי ניהול"),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Text(
                              "סטטוס: ",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color:
                                    MyDonationsTheme.statusColor(d.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusText(d.status),
                                style:
                                    const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (d.status == "cancelled" && d.cancelingReason.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3F3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFFB3B3), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "סיבת ביטול:",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d.cancelingReason,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ),

                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            "נהג: ${_driverName(d.driverId)}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const Spacer(),
                          if (d.status == "pending")
                            GestureDetector(
                              onTap: _showDriverPicker,
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      size: 14, color: Colors.blueGrey),
                                  SizedBox(width: 3),
                                  Text(
                                    "שנה נהג",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const Divider(height: 20, thickness: 0.5, color: Color(0xFFE8E8E8)),

                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (d.status == "pending")
                            ValueListenableBuilder<bool>(
                              valueListenable: _isCancellingNotifier,
                              builder: (context, isCancelling, _) {
                                return TextButton(
                                  onPressed: isCancelling
                                      ? null
                                      : _showCancelDialog,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "בטל תרומה",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            const SizedBox(),
                          DonationReceiptButton(
                            donationId: d.id,
                            receiptUrl: d.receipt,
                            isAdmin: true,
                            onUploadSuccess: () => Navigator.pop(context),
                            enabled: d.status == "collected",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }
}
