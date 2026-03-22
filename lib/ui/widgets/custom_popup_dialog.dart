// import 'package:flutter/material.dart';

// class CustomPopupDialog extends StatelessWidget {
//   final String title;
//   final String message;
//   final String buttonText;

//   const CustomPopupDialog({
//     super.key,
//     required this.title,
//     required this.message,
//     this.buttonText = "סגור",
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 24,
//         vertical: 20,
//       ),
//       title: Text(
//         title,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       content: Text(
//         message,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontSize: 16,
//         ),
//       ),
//       actionsAlignment: MainAxisAlignment.center,
//       actions: [
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24,
//               vertical: 10,
//             ),
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text(buttonText),
//         ),
//       ],
//     );
//   }
// }
// =======================================

import 'package:flutter/material.dart';

// class CustomPopupDialog extends StatelessWidget {
//   final String title;
//   final String message;
//   final String buttonText;
//   final String? cancelText;
//   final VoidCallback? onConfirm;

//   const CustomPopupDialog({
//     super.key,
//     required this.title,
//     required this.message,
//     this.buttonText = "סגור",
//     this.cancelText,
//     this.onConfirm,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 24,
//         vertical: 20,
//       ),
//       title: Text(
//         title,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       content: Text(
//         message,
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 16),
//       ),
//       actionsAlignment: MainAxisAlignment.center,
//       actions: [
//         if (cancelText != null)
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text(cancelText!),
//           ),

//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24,
//               vertical: 10,
//             ),
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//             if (onConfirm != null) {
//               onConfirm!();
//             }
//           },
//           child: Text(buttonText),
//         ),
//       ],
//     );
//   }
// }


class CustomPopupDialog extends StatelessWidget {
  final String title;
  final Widget? content; // 🔥 במקום message
  final String? message; // נשאיר גם לטקסט רגיל
  final String buttonText;
  final String? cancelText;
  final VoidCallback? onConfirm;

  final VoidCallback? onCancel;


  const CustomPopupDialog({
    super.key,
    required this.title,
    this.content,
    this.message,
    this.buttonText = "סגור",
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      // 🔥 פה הקסם
      content: content ??
          Text(
            message ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),

      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(cancelText!),
          ),

        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) onConfirm!();
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}