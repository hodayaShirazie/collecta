// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import '../theme/homepage_theme.dart';
// import '../theme/my_donations_theme.dart';

// class MyDonations extends StatefulWidget {
//   const MyDonations({super.key});

//   @override
//   State<MyDonations> createState() => _MyDonationsState();
// }

// class _MyDonationsState extends State<MyDonations> {
//   final TextEditingController searchController = TextEditingController();

//   String selectedStatus = "הכל";
//   DateTime? selectedDate;

//   final List<Map<String, dynamic>> dummyDonations = [
//     {
//       "businessName": "מאפיית כהן",
//       "date": DateTime(2025, 2, 10),
//       "status": "ממתין",
//       "items": ["מאפים 10 ק״ג", "עוגות 5 יחידות"]
//     },
//     {
//       "businessName": "סופר השכונה",
//       "date": DateTime(2025, 2, 5),
//       "status": "נאסף",
//       "items": ["מוצרי חלב 8 ק״ג"]
//     },
//     {
//       "businessName": "ירקן העיר",
//       "date": DateTime(2025, 1, 28),
//       "status": "בוטל",
//       "items": ["פירות וירקות 12 ק״ג"]
//     },
//   ];

//   /// 🔥 פתיחת לוח שנה לכל הפלטפורמות
//   Future<void> _pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       locale: const Locale('he'),
//       initialEntryMode: DatePickerEntryMode.calendar, // חשוב ל-Web
//       initialDatePickerMode: DatePickerMode.day,
//       initialDate: selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//       builder: (context, child) {
//         return Directionality(
//           textDirection: TextDirection.rtl, // RTL בעברית
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('he'),
//       ],
//       home: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Scaffold(
//           body: Container(
//             decoration:
//                 const BoxDecoration(gradient: HomepageTheme.pageGradient),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   const Text(
//                     "התרומות שלי",
//                     style: MyDonationsTheme.headerStyle,
//                   ),
//                   const SizedBox(height: 20),

//                   /// 🔎 חיפוש חופשי
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextField(
//                       controller: searchController,
//                       decoration: MyDonationsTheme.searchDecoration,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// 📅 סינון לפי תאריך
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: GestureDetector(
//                       onTap: _pickDate,
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 14, horizontal: 18),
//                         decoration:
//                             MyDonationsTheme.dateFilterDecoration,
//                         child: Row(
//                           children: [
//                             const Icon(Icons.date_range, size: 20),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 selectedDate == null
//                                     ? "סינון לפי תאריך"
//                                     : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
//                                 style:
//                                     MyDonationsTheme.dateFilterText,
//                               ),
//                             ),
//                             if (selectedDate != null)
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedDate = null;
//                                   });
//                                 },
//                                 child: const Icon(
//                                   Icons.close,
//                                   size: 18,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// 🎛 סינון לפי סטטוס
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: ["הכל", "ממתין", "נאסף", "בוטל"]
//                           .map((status) {
//                         final selected = selectedStatus == status;
//                         return Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 4),
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedStatus = status;
//                                 });
//                               },
//                               child: AnimatedContainer(
//                                 duration:
//                                     const Duration(milliseconds: 200),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: MyDonationsTheme
//                                     .statusChipDecoration(selected),
//                                 child: Text(
//                                   status,
//                                   style:
//                                       MyDonationsTheme.statusChipText,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   /// 📋 רשימה
//                   Expanded(child: buildList()),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildList() {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       itemCount: dummyDonations.length,
//       itemBuilder: (context, index) {
//         final donation = dummyDonations[index];

//         return Container(
//           margin: const EdgeInsets.only(bottom: 15),
//           padding: const EdgeInsets.all(18),
//           decoration: MyDonationsTheme.cardDecoration,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 donation["businessName"],
//                 style: MyDonationsTheme.titleStyle,
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 "${donation["date"].day}/${donation["date"].month}/${donation["date"].year}",
//                 style: MyDonationsTheme.dateStyle,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 donation["status"],
//                 style: MyDonationsTheme
//                     .statusStyle(donation["status"]),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }






import 'package:flutter/material.dart';
import '../theme/homepage_theme.dart';
import '../theme/my_donations_theme.dart';

class MyDonations extends StatefulWidget {
  const MyDonations({super.key});

  @override
  State<MyDonations> createState() => _MyDonationsState();
}

class _MyDonationsState extends State<MyDonations> {
  String selectedStatus = "הכל";
  DateTimeRange? selectedDateRange;

  final List<Map<String, dynamic>> dummyDonations = [
    {
      "businessName": "מאפיית כהן",
      "date": DateTime(2025, 2, 10),
      "status": "ממתין",
    },
    {
      "businessName": "סופר השכונה",
      "date": DateTime(2025, 2, 5),
      "status": "נאסף",
    },
    {
      "businessName": "ירקן העיר",
      "date": DateTime(2025, 1, 28),
      "status": "בוטל",
    },
  ];

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

  List<Map<String, dynamic>> get filteredDonations {
    return dummyDonations.where((donation) {
      final donationDate = donation["date"] as DateTime;

      if (selectedStatus != "הכל" &&
          donation["status"] != selectedStatus) {
        return false;
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
                  "התרומות שלי",
                  style: MyDonationsTheme.headerStyle,
                ),
                const SizedBox(height: 20),

                /// 📅 Date Range Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 18),
                      decoration:
                          MyDonationsTheme.dateFilterDecoration,
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
                              style:
                                  MyDonationsTheme.dateFilterText,
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
                    children: ["הכל", "ממתין", "נאסף", "בוטל"]
                        .map((status) {
                      final selected = selectedStatus == status;

                      return Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStatus = status;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              alignment: Alignment.center,
                              decoration: MyDonationsTheme
                                  .statusChipDecoration(selected),
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
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredDonations.length,
                    itemBuilder: (context, index) {
                      final donation =
                          filteredDonations[index];

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(18),
                        decoration:
                            MyDonationsTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              donation["businessName"],
                              style:
                                  MyDonationsTheme.titleStyle,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${donation["date"].day}/${donation["date"].month}/${donation["date"].year}",
                              style:
                                  MyDonationsTheme.dateStyle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              donation["status"],
                              style:
                                  MyDonationsTheme.statusStyle(
                                      donation["status"]),
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
