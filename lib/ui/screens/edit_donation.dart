// import 'package:flutter/material.dart';
// import '../theme/my_donations_theme.dart';
// import '../../data/models/donation_model.dart';
// import '../../services/donation_service.dart';

// class EditDonation extends StatefulWidget {
//   final DonationModel donation;
//   const EditDonation({super.key, required this.donation});

//   @override
//   State<EditDonation> createState() => _EditDonationState();
// }

// class _EditDonationState extends State<EditDonation> {
//   final DonationService _service = DonationService();

//   late String status;
//   late DateTime date;
//   late List<ProductModel> products;

//   @override
//   void initState() {
//     super.initState();
//     status = widget.donation.status;
//     date = widget.donation.createdAt;
//     products = List.from(widget.donation.products);
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: date,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//       locale: const Locale('he'),
//     );

//     if (picked != null) {
//       setState(() {
//         date = picked;
//       });
//     }
//   }

//   void _saveChanges() async {
//     // כאן את יכולה לקרוא לשירות לעדכון התרומה ב-API
//     widget.donation.status = status;
//     widget.donation.createdAt = date;
//     widget.donation.products = products;

//     await _service.updateDonation(widget.donation); // ודאי שיש פונקציה מתאימה בשירות

//     Navigator.pop(context); // חזרה לדף הקודם
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("עריכת תרומה")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // תאריך
//             GestureDetector(
//               onTap: _pickDate,
//               child: Row(
//                 children: [
//                   const Icon(Icons.date_range),
//                   const SizedBox(width: 10),
//                   Text("${date.day}/${date.month}/${date.year}"),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // סטטוס
//             DropdownButton<String>(
//               value: status,
//               items: ["pending", "confirmed", "cancelled"].map((s) {
//                 return DropdownMenuItem(
//                   value: s,
//                   child: Text(MyDonationsTheme.statusText(s)),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   status = value!;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),

//             // רשימת מוצרים
//             const Text("מוצרים:"),
//             ...products.map((p) {
//               return Row(
//                 children: [
//                   Expanded(child: Text(p.type.name)),
//                   SizedBox(
//                     width: 50,
//                     child: TextFormField(
//                       initialValue: p.quantity.toString(),
//                       keyboardType: TextInputType.number,
//                       onChanged: (val) {
//                         p.quantity = int.tryParse(val) ?? p.quantity;
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),

//             const SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _saveChanges,
//                 child: const Text("שמור שינויים"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }