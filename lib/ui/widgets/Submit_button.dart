// import 'package:flutter/material.dart';

// /// כפתור Submit מותאם שמנע לחיצות כפולות ומראה Loading
// class SubmitButton extends StatefulWidget {
//   /// הטקסט שמופיע על הכפתור
//   final String text;

//   /// פונקציה אסינכרונית שמבוצעת כשנלחץ הכפתור
//   final Future<void> Function() onSubmit;

//   /// צבע הרקע של הכפתור
//   final Color backgroundColor;

//   /// צבע הטקסט
//   final Color textColor;

//   /// גובה הכפתור (ברירת מחדל: 50)
//   final double height;

//   const SubmitButton({
//     super.key,
//     required this.text,
//     required this.onSubmit,
//     this.backgroundColor = Colors.blue,
//     this.textColor = Colors.white,
//     this.height = 50,
//   });

//   @override
//   State<SubmitButton> createState() => _SubmitButtonState();
// }

// class _SubmitButtonState extends State<SubmitButton> {
//   bool _isSubmitting = false;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: widget.height,
//       child: ElevatedButton(
//         onPressed: _isSubmitting
//             ? null // הכפתור נעול בזמן שליחה
//             : () async {
//                 setState(() => _isSubmitting = true); // נעילת הכפתור
//                 try {
//                   await widget.onSubmit(); // ביצוע הפונקציה
//                 } catch (e) {
//                   // אפשר להוסיף טיפול בשגיאות אם רוצים
//                 } finally {
//                   if (mounted) {
//                     setState(() => _isSubmitting = false); // שחרור הכפתור
//                   }
//                 }
//               },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: widget.backgroundColor,
//           disabledBackgroundColor: widget.backgroundColor.withOpacity(0.6),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: _isSubmitting
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 widget.text,
//                 style: TextStyle(
//                   color: widget.textColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';

class SubmitButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onSubmit;
  final Color backgroundColor;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onSubmit,
    this.backgroundColor = Colors.blue,
  });

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return; // מונע לחיצות כפולות
    setState(() => _isLoading = true);

    try {
      await widget.onSubmit();
    } catch (e) {
      // אפשר להוסיף טיפול בשגיאות אם רוצים
      rethrow;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}