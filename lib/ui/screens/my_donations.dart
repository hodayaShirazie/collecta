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
          child: child!,
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
        backgroundColor: HomepageTheme.pageBackgroundStart,
        body: Container(
          decoration:
              const BoxDecoration(color: HomepageTheme.pageBackgroundStart),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: HomepageTheme.latetBlue, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
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
                                    const EdgeInsets.symmetric(vertical: 8),
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: filteredDonations.length,
                      itemBuilder: (context, index) {
                        final donation = filteredDonations[index];

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
                              width: MediaQuery.of(context).size.width * 0.9,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 24),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                        style: MyDonationsTheme.donationDate,
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: MyDonationsTheme.statusColor(
                                              donation.status),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _statusText(donation.status),
                                          style: const TextStyle(
                                              color: Colors.black),
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
                                      const Icon(Icons.chevron_right,
                                          color: Colors.black38),
                                    ],
                                  ),
                                ],
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
    );
  }
}
