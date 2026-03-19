// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../../services/donation_service.dart'; 
// import '../../widgets/custom_popup_dialog.dart';
// import 'package:url_launcher/url_launcher.dart';


// class DonationReceiptHelper {
//   static Future<void> pickAndUploadPDF(BuildContext context, String donationId) async {
//     debugPrint("🔍 Helper: Started pickAndUploadPDF for donationId: $donationId");
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//       withData: true,
//     );

//     if (result == null || result.files.isEmpty) return;

//     final file = result.files.first;

//     if (file.size > 3 * 1024 * 1024) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('הקובץ גדול מדי (מקסימום 3MB)')),
//       );
//       return;
//     }

//     final fileBytes = file.bytes!;
//     final fileName = 'receipt_$donationId.pdf';

//     try {
//       final url = await DonationService().uploadDonationReceipt(
//         donationId: donationId,
//         fileBytes: fileBytes,
//         fileName: fileName,
//       );

//       CustomPopupDialog(
//         title: "העלאה הושלמה",
//         message: "הקבלה הועלתה בהצלחה למערכת",
//         buttonText: "סגור",
//       );
      
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('שגיאה בהעלאה: $e')),
//       );
//     }
//   }


//   static Future<void> viewReceipt(BuildContext context, String urlString) async {
//     if (urlString.isEmpty) return;

//     final Uri url = Uri.parse(urlString);
    
//     try {
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         throw 'Could not launch $urlString';
//       }
//     } catch (e) {
//       _showPopup(context, "שגיאה", "לא ניתן לפתוח את הקובץ: $e");
//     }
//   }

//   /// פונקציית עזר להצגת הדיאלוג המותאם שלך
//   static void _showPopup(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => CustomPopupDialog(
//         title: title,
//         message: message,
//         buttonText: "סגור",
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/donation_service.dart'; 
import '../../widgets/custom_popup_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationReceiptHelper {
  static Future<void> pickAndUploadPDF(BuildContext context, String donationId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    if (file.size > 3 * 1024 * 1024) {
      _showPopup(context, "קובץ גדול מדי", "הקובץ גדול מדי (מקסימום 3MB)");
      return;
    }

    final fileBytes = file.bytes!;
    final fileName = 'receipt_$donationId.pdf';

    try {
      await DonationService().uploadDonationReceipt(
        donationId: donationId,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      // כאן התיקון!
      _showPopup(context, "העלאה הושלמה", "הקבלה הועלתה בהצלחה למערכת");
      
    } catch (e) {
      _showPopup(context, "שגיאה", "שגיאה בהעלאה: $e");
    }
  }

  static Future<void> viewReceipt(BuildContext context, String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      _showPopup(context, "שגיאה", "לא ניתן לפתוח את הקובץ: $e");
    }
  }

  static void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => CustomPopupDialog(
        title: title,
        message: message,
        buttonText: "סגור",
      ),
    );
  }
}