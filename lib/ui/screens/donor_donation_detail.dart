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

import '../utils/donation/donation_constants.dart';

import '../../data/models/donation_model.dart';
import '../../services/donation_service.dart';

import 'edit_donation.dart';

class DonorDonationDetail extends StatefulWidget {
  final String donationId;

  const DonorDonationDetail({super.key, required this.donationId});

  @override
  State<DonorDonationDetail> createState() => _DonorDonationDetailState();
}

class _DonorDonationDetailState extends State<DonorDonationDetail> {
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

      selectedTimeSlots = d.pickupTimes.map((e) => "${e.from}-${e.to}").toList();

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

        final displayName = (resolvedName == "אחר" && typeDescription.isNotEmpty)
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

  Future<void> _cancelDonation(String reason) async {
    _isCancellingNotifier.value = true;
    try {
      await _service.cancelDonation(widget.donationId, reason);
      if (!mounted) return;
      Navigator.pop(context, true);
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
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text(
                "ביטול תרומה",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "יש להזין סיבת ביטול:",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "סיבת הביטול...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _isCancellingNotifier,
                      builder: (context, isCancelling, _) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C5AA0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed:
                              (reasonCtrl.text.trim().isEmpty || isCancelling)
                                  ? null
                                  : () {
                                      Navigator.pop(ctx);
                                      _cancelDonation(reasonCtrl.text.trim());
                                    },
                          child: isCancelling
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text("אישור",
                                  style: TextStyle(
                                      fontFamily: 'Assistant', fontSize: 15)),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("חזור",
                          style: TextStyle(
                              fontFamily: 'Assistant', color: Colors.black54)),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
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
        child: Container(
          decoration: const BoxDecoration(
            gradient: HomepageTheme.pageGradient,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: HomepageTheme.topPadding),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: HomepageTheme.latetBlue, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text("פרטי תרומה",
                          textAlign: TextAlign.center,
                          style: ReportDonationTheme.headerStyle),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 35),

                // פרטי העסק
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

                // פרטי איש קשר
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

                // חלונות זמן
                TimeSlotsCard(
                  timeSlots: DonationConstants.timeSlots,
                  selectedTimeSlots: selectedTimeSlots,
                  toggleTime: (_) {},
                ),

                // פריטים שנוספו
                if (donatedItems.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
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
                                          style: const TextStyle(fontSize: 12),
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

                // סטטוס + פעולות
                CardWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitleWidget(text: "פרטי תרומה"),

                      // סטטוס
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
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
                                color: MyDonationsTheme.statusColor(d.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusText(d.status),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // סיבת ביטול
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

                      const SizedBox(height: 8),

                      // כפתורי פעולה
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (d.status == "pending")
                            Row(
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isCancellingNotifier,
                                  builder: (context, isCancelling, _) {
                                    return TextButton(
                                      onPressed: isCancelling
                                          ? null
                                          : _showCancelDialog,
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      child: const Text(
                                        "בטל תרומה",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditDonation(
                                            donationId: widget.donationId),
                                      ),
                                    );
                                    _loadDonation();
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: const Text(
                                    "ערוך תרומה",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: HomepageTheme.latetBlue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(),
                          DonationReceiptButton(
                            donationId: d.id,
                            receiptUrl: d.receipt,
                            isAdmin: false,
                            onUploadSuccess: _loadDonation,
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
      ),
    );
  }
}
