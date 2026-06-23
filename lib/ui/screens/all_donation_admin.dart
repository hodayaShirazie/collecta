import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';
import '../../data/models/donation_model.dart';
import '../../data/models/driver_model.dart';
import '../../services/donation_service.dart';
import '../../services/driver_service.dart';
import '../../services/route_optimization_service.dart';
import '../../services/export_service.dart';
import '../../services/org_manager.dart';
import '../widgets/donation_widgets/donation_receipt_button.dart';
import '../widgets/custom_popup_dialog.dart';
import 'admin_donation_detail.dart';

class AllDonationsAdmin extends StatefulWidget {
  const AllDonationsAdmin({super.key});

  @override
  State<AllDonationsAdmin> createState() => _AllDonationsAdminState();
}

class _AllDonationsAdminState extends State<AllDonationsAdmin> {
  final DonationService _service = DonationService();
  final DriverService _driverService = DriverService();
  final RouteOptimizationService _routeService = RouteOptimizationService();

  String selectedStatus = "הכל";
  DateTimeRange? selectedDateRange;
  String searchQuery = "";

  List<DonationModel> donations = [];
  List<DriverProfile> drivers = [];
  bool isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final orgId = OrgManager.orgId ?? '';
      final results = await Future.wait([
        _service.getDonationsByOrganization(orgId),
        _driverService.fetchDriversByOrganization(orgId),
      ]);
      setState(() {
        donations = results[0] as List<DonationModel>;
        drivers = results[1] as List<DriverProfile>;
        isLoading = false;
      });
    } catch (e) {
      print(" error loading data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale('he'),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1E5DAA),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF1A2B4A),
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: Colors.white,
                headerBackgroundColor: Colors.white,
                headerForegroundColor: const Color(0xFF1E5DAA),
                rangePickerBackgroundColor: Colors.white,
                rangePickerHeaderBackgroundColor: Colors.white,
                rangePickerHeaderForegroundColor: const Color(0xFF1E5DAA),
                rangeSelectionBackgroundColor: const Color(0xFFEDF2FB),
                headerHeadlineStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Assistant'),
                headerHelpStyle: const TextStyle(fontSize: 13, fontFamily: 'Assistant'),
                todayForegroundColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected) ? Colors.white : const Color(0xFF1E5DAA)),
                dayForegroundColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected) ? Colors.white : const Color(0xFF1A2B4A)),
                dayBackgroundColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected) ? const Color(0xFF1E5DAA) : null),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                rangePickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Assistant'),
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.9)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  List<DonationModel> get filteredDonations {
    return donations.where((donation) {
      final donationDate = donation.createdAt;

      if (searchQuery.isNotEmpty) {
        final matchesBusiness =
            donation.businessAddress.name.toLowerCase().contains(searchQuery);

        final matchesProducts = donation.products.any((product) =>
            product.type.name.toLowerCase().contains(searchQuery));

        if (!matchesBusiness && !matchesProducts) {
          return false;
        }
      }

      if (selectedStatus != "הכל") {
        final statusMap = {
          "ממתין": "pending",
          "נאסף": "collected",
          "בוטל": "cancelled",
        };

        if (donation.status != statusMap[selectedStatus]) {
          return false;
        }
      }

      if (selectedDateRange != null) {
        if (donationDate.isBefore(
                selectedDateRange!.start.subtract(const Duration(days: 1))) ||
            donationDate.isAfter(
                selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
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
    if (driverId.isEmpty) return "ללא נהג";
    try {
      final driver = drivers.firstWhere((d) => d.user.id == driverId);
      return driver.user.name.isNotEmpty ? driver.user.name : "נהג ללא שם";
    } catch (_) {
      return "לא ידוע";
    }
  }

  Future<void> _exportToExcel() async {
    if (filteredDonations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('אין תרומות לייצוא')),
      );
      return;
    }
    setState(() => _isExporting = true);
    try {
      await ExportService().exportDonationsToExcel(filteredDonations, drivers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בייצוא: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showDriverPickerForDonation(DonationModel donation, int donationIndex) {
    DriverProfile? selected;
    final DriverProfile? preSelected = donation.driverId.isEmpty
        ? null
        : drivers.cast<DriverProfile?>().firstWhere(
            (dr) => dr!.user.id == donation.driverId,
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
                      drivers.isEmpty
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
                              child: RadioGroup<DriverProfile>(
                                groupValue: selected ?? preSelected,
                                onChanged: (val) =>
                                    setDialogState(() => selected = val),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: drivers.map((driver) {
                                    final isCurrentDriver =
                                        driver.user.id == donation.driverId;
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
                                    );
                                  }).toList(),
                                ),
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
                          if (drivers.isNotEmpty)
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
                                    chosenDriver.user.id == donation.driverId) {
                                  Navigator.pop(ctx);
                                  return;
                                }
                                Navigator.pop(ctx);
                                try {
                                  final oldDriverId = donation.driverId;
                                  await _service.assignDriverToDonation(
                                    donationId: donation.id,
                                    driverId: chosenDriver.user.id,
                                  );
                                  if (oldDriverId.isNotEmpty) {
                                    _routeService
                                        .removeDriverStop(oldDriverId, donation)
                                        .catchError((e) => debugPrint('removeDriverStop: $e'));
                                  }
                                  setState(() {
                                    donations[donationIndex] =
                                        donation.copyWith(driverId: chosenDriver.user.id);
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: HomepageTheme.pageGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -100, right: -80,
                  child: Container(width: 420, height: 420, decoration: HomepageTheme.decorativeCircle),
                ),
                Positioned(
                  bottom: -80, left: -70,
                  child: Container(width: 340, height: 340, decoration: HomepageTheme.decorativeCircle),
                ),
                Positioned(
                  top: 180, left: -60,
                  child: Container(width: 240, height: 240, decoration: HomepageTheme.decorativeCircle),
                ),
                SizedBox.expand(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 350),
                        child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: HomepageTheme.latetBlue, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text("כל התרומות",
                          textAlign: TextAlign.center,
                          style: MyDonationsTheme.headerStyle),
                    ),
                    _isExporting
                        ? SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: HomepageTheme.latetBlue),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.file_download_outlined,
                                color: HomepageTheme.latetBlue),
                            tooltip: 'ייצוא לאקסל',
                            onPressed: _exportToExcel,
                          ),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "חיפוש חופשי...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    decoration: MyDonationsTheme.dateFilterDecoration,
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedDateRange == null
                                ? "סינון מתאריך עד תאריך"
                                : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month}/${selectedDateRange!.start.year} - "
                                    "${selectedDateRange!.end.day}/${selectedDateRange!.end.month}/${selectedDateRange!.end.year}",
                            style: MyDonationsTheme.dateFilterText,
                            textDirection: selectedDateRange != null
                                ? TextDirection.ltr
                                : null,
                          ),
                        ),
                        if (selectedDateRange != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDateRange = null;
                              });
                            },
                            child: const Icon(Icons.close),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: ["הכל", "ממתין", "נאסף", "בוטל"].map((status) {
                      final selected = selectedStatus == status;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStatus = status;
                              });
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration:
                                  MyDonationsTheme.statusChipDecoration(
                                      selected),
                              child: Text(
                                status,
                                style: MyDonationsTheme.statusChipText,
                              ),
                            ),
                          ),
                        ),
                      );
                  }).toList(),
                ),

                SizedBox(height: 20),

                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: HomepageTheme.latetBlue))
                      : filteredDonations.isEmpty
                          ? const Center(child: Text("אין תרומות להצגה"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 4),
                              itemCount: filteredDonations.length,
                              itemBuilder: (context, index) {
                                final donation = filteredDonations[index];
                                final realIndex = donations.indexOf(donation);
                                final accentColor =
                                    MyDonationsTheme.statusTextColor(
                                        donation.status);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                              width: 4, color: accentColor),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Main info (tap to open detail)
                                                GestureDetector(
                                                  onTap: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AdminDonationDetail(
                                                          donationId:
                                                              donation.id,
                                                          drivers: drivers,
                                                        ),
                                                      ),
                                                    );
                                                    _loadData();
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            14, 14, 14, 10),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                donation
                                                                    .businessAddress
                                                                    .name,
                                                                style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                  fontFamily:
                                                                      'Assistant',
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 7),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            3,
                                                                        horizontal:
                                                                            12),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: MyDonationsTheme
                                                                          .statusColor(
                                                                              donation.status),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    child: Text(
                                                                      _statusText(
                                                                          donation
                                                                              .status),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color:
                                                                            accentColor,
                                                                        fontFamily:
                                                                            'Assistant',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Icon(
                                                                    Icons
                                                                        .calendar_today_outlined,
                                                                    size: 12,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade500,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade500,
                                                                      fontFamily:
                                                                          'Assistant',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                            Icons.chevron_right,
                                                            color: Colors
                                                                .grey.shade400,
                                                            size: 20),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // Divider
                                                Divider(
                                                    height: 1,
                                                    color:
                                                        Colors.grey.shade100),

                                                // Driver + actions row
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          14, 8, 8, 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .local_shipping_outlined,
                                                        size: 14,
                                                        color: Colors
                                                            .grey.shade400,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _driverName(
                                                            donation.driverId),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontFamily:
                                                              'Assistant',
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      // Change driver button (pending only)
                                                      if (donation.status ==
                                                          "pending")
                                                        GestureDetector(
                                                          behavior:
                                                              HitTestBehavior
                                                                  .opaque,
                                                          onTap: () =>
                                                              _showDriverPickerForDonation(
                                                                  donation,
                                                                  realIndex),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        4),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .edit_outlined,
                                                                  size: 14,
                                                                  color: HomepageTheme
                                                                      .latetBlue,
                                                                ),
                                                                const SizedBox(
                                                                    width: 3),
                                                                Text(
                                                                  "שנה נהג",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: HomepageTheme
                                                                        .latetBlue,
                                                                    fontFamily:
                                                                        'Assistant',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      // Receipt button
                                                      GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .opaque,
                                                        onTap: () {},
                                                        child:
                                                            DonationReceiptButton(
                                                          donationId:
                                                              donation.id,
                                                          receiptUrl:
                                                              donation.receipt,
                                                          isAdmin: true,
                                                          enabled: donation
                                                                  .status ==
                                                              "collected",
                                                          onUploadSuccess:
                                                              _loadData,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
                ),
              ),
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
