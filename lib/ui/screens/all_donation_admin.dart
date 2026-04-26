import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';
import '../../data/models/donation_model.dart';
import '../../data/models/driver_model.dart';
import '../../services/donation_service.dart';
import '../../services/driver_service.dart';
import '../../services/export_service.dart';
import '../../services/org_manager.dart';
import 'admin_donation_detail.dart';

class AllDonationsAdmin extends StatefulWidget {
  const AllDonationsAdmin({super.key});

  @override
  State<AllDonationsAdmin> createState() => _AllDonationsAdminState();
}

class _AllDonationsAdminState extends State<AllDonationsAdmin> {
  final DonationService _service = DonationService();
  final DriverService _driverService = DriverService();

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
      print("🔴 error loading data: $e");
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

  List<DonationModel> get filteredDonations {
    return donations.where((donation) {
      final donationDate = donation.createdAt;

      /// 🔎 Free Search
      if (searchQuery.isNotEmpty) {
        final matchesBusiness =
            donation.businessAddress.name.toLowerCase().contains(searchQuery);

        final matchesProducts = donation.products.any((product) =>
            product.type.name.toLowerCase().contains(searchQuery));

        if (!matchesBusiness && !matchesProducts) {
          return false;
        }
      }

      ///  Status Filter
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

      /// 📅 Date Filter
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

  Future<void> _exportToExcel() async {
    if (filteredDonations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('אין תרומות לייצוא')),
      );
      return;
    }
    setState(() => _isExporting = true);
    try {
      // שליפת פרטים מלאים במקביל — הרשימה מחזירה שדות חלקיים בלבד
      final fullDonations = await Future.wait(
        filteredDonations.map((d) => _service.getDonationById(d.id)),
      );
      await ExportService().exportDonationsToExcel(fullDonations, drivers);
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
                      child: Text("כל התרומות",
                          textAlign: TextAlign.center,
                          style: MyDonationsTheme.headerStyle),
                    ),
                    _isExporting
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.file_download_outlined,
                                color: HomepageTheme.latetBlue),
                            tooltip: 'ייצוא לאקסל',
                            onPressed: _exportToExcel,
                          ),
                  ],
                ),
                const SizedBox(height: 20),

                /// 🔍 Free Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
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
                ),

                const SizedBox(height: 20),

                /// 📅 Date Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
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
                ),

                const SizedBox(height: 20),

                /// 🎛 Status Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                                  const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration:
                                  MyDonationsTheme.statusChipDecoration(
                                      selected),
                              child: Text(
                                status,
                                style:
                                    MyDonationsTheme.statusChipText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredDonations.isEmpty
                          ? const Center(
                              child: Text("אין תרומות להצגה"))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredDonations.length,
                              itemBuilder: (context, index) {
                                final donation = filteredDonations[index];

                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminDonationDetail(
                                          donationId: donation.id,
                                          drivers: drivers,
                                        ),
                                      ),
                                    );
                                    _loadData();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration:
                                        MyDonationsTheme.donationCardDecoration,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                donation.businessAddress.name,
                                                style:
                                                    MyDonationsTheme.donationTitle,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4,
                                                        horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      color: MyDonationsTheme
                                                          .statusColor(
                                                              donation.status),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      _statusText(
                                                          donation.status),
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                                    style: MyDonationsTheme
                                                        .donationDate,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            color: Colors.black38),
                                      ],
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
    );
  }
}
