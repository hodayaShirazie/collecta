import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';
import '../../data/models/donation_list_item_model.dart';
import '../../services/donation_service.dart';
import '../widgets/donation_widgets/donation_receipt_button.dart';
import 'donor_donation_detail.dart';

class MyDonations extends StatefulWidget {
  const MyDonations({super.key});

  @override
  State<MyDonations> createState() => _MyDonationsState();
}

class _MyDonationsState extends State<MyDonations> {
  final DonationService _service = DonationService();

  String selectedStatus = "הכל";
  DateTimeRange? selectedDateRange;

  List<DonationListItemModel> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      final result = await _service.getMyDonations();
      setState(() {
        donations = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("error loading donations: $e");
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                child: child!,
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

  List<DonationListItemModel> get filteredDonations {
    return donations.where((donation) {
      if (selectedStatus != "הכל") {
        final statusMap = {
          "ממתין": "pending",
          "נאסף": "collected",
          "בוטל": "cancelled",
        };
        if (donation.status != statusMap[selectedStatus]) return false;
      }

      if (selectedDateRange != null) {
        final start = DateTime(
            selectedDateRange!.start.year,
            selectedDateRange!.start.month,
            selectedDateRange!.start.day);
        final end = DateTime(
            selectedDateRange!.end.year,
            selectedDateRange!.end.month,
            selectedDateRange!.end.day,
            23, 59, 59);
        if (donation.createdAt.isBefore(start) ||
            donation.createdAt.isAfter(end)) return false;
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: HomepageTheme.pageGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: HomepageTheme.decorativeCircle,
                  ),
                ),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                        child: Text("התרומות שלי",
                            textAlign: TextAlign.center,
                            style: MyDonationsTheme.headerStyle),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
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
                                onTap: () =>
                                    setState(() => selectedDateRange = null),
                                child: const Icon(Icons.close),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: ["הכל", "ממתין", "נאסף", "בוטל"].map((status) {
                        final selected = selectedStatus == status;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedStatus = status),
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(vertical: 8),
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
                  ),

                  const SizedBox(height: 20),

                  // Donations List
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (filteredDonations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("אין תרומות להצגה"),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 25),
                      itemCount: filteredDonations.length,
                      itemBuilder: (context, index) {
                        final donation = filteredDonations[index];
                        final accentColor = MyDonationsTheme.statusTextColor(donation.status);

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DonorDonationDetail(
                                    donationId: donation.id),
                              ),
                            );
                            _loadDonations();
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.92,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(width: 4, color: accentColor),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 14),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today_outlined,
                                                        size: 13,
                                                        color: Colors.grey.shade500,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey.shade600,
                                                          fontFamily: 'Assistant',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 3, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      color: MyDonationsTheme
                                                          .statusColor(donation.status),
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      _statusText(donation.status),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: accentColor,
                                                        fontFamily: 'Assistant',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  DonationReceiptButton(
                                                    donationId: donation.id,
                                                    receiptUrl: donation.receipt,
                                                    onUploadSuccess: _loadDonations,
                                                    isAdmin: false,
                                                  ),
                                                  Icon(Icons.chevron_right,
                                                      color: Colors.grey.shade400,
                                                      size: 20),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
                ),
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
