import 'package:flutter/material.dart';
import 'package:collecta/ui/guards/auth_guard.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';
// import '../../data/models/donation_model.dart';
import '../../data/models/donation_list_item_model.dart';
import '../../services/donation_service.dart';
import 'edit_donation.dart';
import '../widgets/custom_popup_dialog.dart';

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
      print("🔴 error loading donations: $e");
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
      final donationDate = donation.createdAt;

      if (selectedStatus != "הכל") {
        final statusMap = {
          "ממתין": "pending",
          "נאסף": "confirmed",
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
      case "confirmed":
        return "נאסף";
      case "cancelled":
        return "בוטל";
      default:
        return status;
    }
  }

  Future<void> cancelDonation(String donationId) async {
    try {
      await _service.cancelDonation(donationId);

      await _loadDonations();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "התרומה בוטלה",
          message: "התרומה בוטלה בהצלחה",
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: HomepageTheme.pageGradient),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "התרומות שלי",
                  style: MyDonationsTheme.headerStyle,
                ),
                const SizedBox(height: 20),

                // Date Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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

                // Status Filter
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration:
                                  MyDonationsTheme.statusChipDecoration(selected),
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
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredDonations.isEmpty
                          ? const Center(child: Text("אין תרומות להצגה"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: filteredDonations.length,
                              itemBuilder: (context, index) {
                                final donation = filteredDonations[index];

                                return GestureDetector(
                                  onTap: () {
                                    // print("========== DONATION ==========");
                                    // print(donation.toJson());
                                    // print("==============================");
                                    if (donation.status == "pending") {
                                      Navigator.pushNamed(context, '/donor/edit-donation/${donation.id}');
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const CustomPopupDialog(
                                          title: "עריכה אינה אפשרית",
                                          message: "לא ניתן לערוך תרומה זו.",
                                        ),
                                      );
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.center, 
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      // child: Row(
                                      //   mainAxisAlignment: MainAxisAlignment.start,
                                      //   crossAxisAlignment: CrossAxisAlignment.center,
                                      //   children: [
                                      //     const Icon(Icons.info_outline, size: 28),
                                      //     const SizedBox(width: 12),
                                      //     Text(
                                      //       "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                      //       style: MyDonationsTheme.donationDate,
                                      //     ),
                                      //     const SizedBox(width: 12),
                                      //     Container(
                                      //       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                      //       decoration: BoxDecoration(
                                      //         color: MyDonationsTheme.statusColor(donation.status),
                                      //         borderRadius: BorderRadius.circular(10),
                                      //       ),
                                      //       child: Text(
                                      //         _statusText(donation.status),
                                      //         style: const TextStyle(color: Colors.black),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),

                                      child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.info_outline, size: 28),
                                            const SizedBox(width: 12),
                                            Text(
                                              "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                              style: MyDonationsTheme.donationDate,
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: MyDonationsTheme.statusColor(donation.status),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                _statusText(donation.status),
                                                style: const TextStyle(color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),

                                        if (donation.status == "pending") ...[
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => CustomPopupDialog(
                                                    title: "ביטול תרומה",
                                                    message: "האם אתה בטוח שברצונך לבטל את התרומה?",
                                                    buttonText: "אישור",
                                                    cancelText: "חזור",
                                                    onConfirm: () {
                                                      cancelDonation(donation.id);
                                                    },
                                                  ),
                                                ).then((_) {
                                                  cancelDonation(donation.id);
                                                });
                                              },
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
                                            ),
                                          ),
                                        ],
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
    );
  }
}
