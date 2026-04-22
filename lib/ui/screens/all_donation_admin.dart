import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';
import '../../data/models/donation_model.dart';
import '../../data/models/driver_model.dart';
import '../../services/donation_service.dart';
import '../../services/driver_service.dart';
import '../../services/org_manager.dart';
import '../widgets/donation_widgets/donation_receipt_button.dart';
import '../widgets/custom_popup_dialog.dart';

class AllDonationsAdmin extends StatefulWidget {
  const AllDonationsAdmin({super.key});

  @override
  State<AllDonationsAdmin> createState() => _AllDonationsAdminState();
}

class _AllDonationsAdminState extends State<AllDonationsAdmin> {
  final DonationService _service = DonationService();
  final DriverService _driverService = DriverService();
  late ValueNotifier<bool> _isCancellingNotifier;

  String selectedStatus = "הכל";
  DateTimeRange? selectedDateRange;
  String searchQuery = "";

  List<DonationModel> donations = [];
  List<DriverProfile> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _isCancellingNotifier = ValueNotifier(false);
    _loadData();
  }

  @override
  void dispose() {
    _isCancellingNotifier.dispose();
    super.dispose();
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

  String _driverName(String driverId) {
    if (driverId.isEmpty) return "לא שויך";
    try {
      final driver = drivers.firstWhere((d) => d.user.id == driverId);
      return driver.user.name.isNotEmpty ? driver.user.name : "נהג ללא שם";
    } catch (_) {
      return "לא שויך";
    }
  }

  Future<void> cancelDonation(String donationId) async {
    _isCancellingNotifier.value = true;

    try {
      await _service.cancelDonation(donationId);

      setState(() {
        final index = donations.indexWhere((d) => d.id == donationId);
        if (index != -1) {
          donations[index] = donations[index].copyWith(status: 'cancelled');
        }
      });

      if (!mounted) return;

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => const CustomPopupDialog(
          title: "התרומה בוטלה",
          message: "התרומה בוטלה בהצלחה",
        ),
      );
    } catch (e) {
      _isCancellingNotifier.value = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה: $e")),
      );
    }
  }

  void _showDriverPicker(DonationModel donation) {
    DriverProfile? selected;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("שיוך נהג לתרומה"),
              content: drivers.isEmpty
                  ? const Text("אין נהגים בארגון")
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: drivers.map((driver) {
                          final isCurrentDriver =
                              driver.user.id == donation.driverId;
                          return RadioListTile<DriverProfile>(
                            title: Text(driver.user.name.isNotEmpty
                                ? driver.user.name
                                : "נהג ללא שם"),
                            subtitle: isCurrentDriver
                                ? const Text("נהג נוכחי",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green))
                                : null,
                            value: driver,
                            groupValue: selected ??
                                drivers.firstWhere(
                                  (d) => d.user.id == donation.driverId,
                                  orElse: () => driver,
                                ),
                            onChanged: (val) {
                              setDialogState(() => selected = val);
                            },
                          );
                        }).toList(),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("ביטול"),
                ),
                if (drivers.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      final chosenDriver = selected ??
                          drivers.firstWhere(
                            (d) => d.user.id == donation.driverId,
                            orElse: () => drivers.first,
                          );

                      if (chosenDriver.user.id == donation.driverId) {
                        Navigator.pop(ctx);
                        return;
                      }

                      Navigator.pop(ctx);

                      try {
                        await _service.assignDriverToDonation(
                          donationId: donation.id,
                          driverId: chosenDriver.user.id,
                        );

                        setState(() {
                          final index =
                              donations.indexWhere((d) => d.id == donation.id);
                          if (index != -1) {
                            donations[index] = donations[index]
                                .copyWith(driverId: chosenDriver.user.id);
                          }
                        });

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "הנהג שויך בהצלחה: ${chosenDriver.user.name}"),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("שגיאה בשיוך נהג: $e")),
                        );
                      }
                    },
                    child: const Text("שמור"),
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
                                final donation = filteredDonations[index];

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
                                      Row(
                                        children: [
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
                                        ],
                                      ),

                                      // Driver row
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.local_shipping_outlined,
                                              size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            "נהג: ${_driverName(donation.driverId)}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (donation.status == "pending")
                                            GestureDetector(
                                              onTap: () => _showDriverPicker(donation),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.edit_outlined,
                                                      size: 14,
                                                      color: Colors.blueGrey),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    "שנה נהג",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blueGrey,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),

                                      if (donation.status == "pending") ...[
                                        const SizedBox(height: 4),
                                        ValueListenableBuilder<bool>(
                                          valueListenable: _isCancellingNotifier,
                                          builder: (context, isCancelling, _) {
                                            return TextButton(
                                              onPressed: isCancelling ? null : () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => ValueListenableBuilder<bool>(
                                                    valueListenable: _isCancellingNotifier,
                                                    builder: (context, isCancellingInDialog, _) {
                                                      return CustomPopupDialog(
                                                        title: "ביטול תרומה",
                                                        message: "האם אתה בטוח שברצונך לבטל את התרומה?",
                                                        buttonText: "אישור",
                                                        cancelText: "חזור",
                                                        isLoading: isCancellingInDialog,
                                                        onConfirm: () => cancelDonation(donation.id),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                                        ),
                                      ],
                                      const SizedBox(height: 12),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
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
                                            onUploadSuccess: _loadData,
                                            enabled: donation.status == "collected",
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
