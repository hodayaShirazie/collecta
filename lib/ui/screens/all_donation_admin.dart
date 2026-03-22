import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';
import '../../data/models/donation_model.dart';
import '../../services/donation_service.dart';
import '../utils/donation/donation_receipt_helper.dart';
import '../widgets/donation_widgets/donation_receipt_button.dart';

const String organizationId = 'xFKMWqidL2uZ5wnksdYX';

class AllDonationsAdmin extends StatefulWidget {
  const AllDonationsAdmin({super.key});

  @override
  State<AllDonationsAdmin> createState() => _AllDonationsAdminState();
}

class _AllDonationsAdminState extends State<AllDonationsAdmin> {
  final DonationService _service = DonationService();

  String selectedStatus = "הכל";
  DateTimeRange? selectedDateRange;
  String searchQuery = "";

  List<DonationModel> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
        final result = await _service.getDonationsByOrganization(organizationId); // 🔍 For testing, we can use the same endpoint since it returns all donations for admins
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
          "נאסף": "confirmed",
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
      case "confirmed":
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
        body: Container(
          decoration:
              const BoxDecoration(gradient: HomepageTheme.pageGradient),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  " התרומות שלי ",
                  style: MyDonationsTheme.headerStyle,
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
                                
                                final donation =
                                    filteredDonations[index];
 
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: MyDonationsTheme.donationCardDecoration,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              donation.businessAddress.name,
                                              style: MyDonationsTheme.donationTitle,
                                            ),
                                          ),
                                          Text(
                                            "${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}",
                                            style: MyDonationsTheme.donationDate,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: MyDonationsTheme.statusColor(donation.status),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _statusText(donation.status),
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 12),


                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // רשימת המוצרים תופסת את כל המקום הפנוי
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: donation.products.map((product) {
                                                final isOther = product.type.name == "אחר";
                                                return Text(
                                                  isOther
                                                      ? "אחר - ${product.quantity} (${product.type.description})"
                                                      : "${product.type.name} - ${product.quantity}",
                                                  style: MyDonationsTheme.dateStyle,
                                                );
                                              }).toList(),
                                            ),
                                          ),

                                          DonationReceiptButton(
                                            donationId: donation.id,
                                            receiptUrl: donation.receipt,
                                            isAdmin: true, 
                                            onUploadSuccess: _loadDonations, 
                                          ),
                                        ],
                                      ),
                                    ],
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
