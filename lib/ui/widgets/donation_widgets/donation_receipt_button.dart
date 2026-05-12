import 'package:flutter/material.dart';
import '../../utils/donation/donation_receipt_helper.dart';
import '../centered_toast.dart';

class DonationReceiptButton extends StatelessWidget {
  final String donationId;
  final String receiptUrl;
  final VoidCallback onUploadSuccess;
  final bool isAdmin;
  final bool enabled;

  const DonationReceiptButton({
    super.key,
    required this.donationId,
    required this.receiptUrl,
    required this.onUploadSuccess,
    this.isAdmin = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasReceipt = receiptUrl.isNotEmpty;

    // Donor with no receipt: faded indicator (non-interactive)
    if (!isAdmin && !hasReceipt) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          Icons.receipt_long_outlined,
          size: 22,
          color: Colors.grey.shade300,
        ),
      );
    }

    // Both admin and donor: has receipt → view/download popup
    if (hasReceipt) {
      return PopupMenuButton<String>(
        icon: Icon(Icons.receipt_long_outlined, color: Colors.grey.shade600, size: 22),
        tooltip: "",
        padding: EdgeInsets.zero,
        onSelected: (value) async {
          if (value == 'view') {
            await DonationReceiptHelper.viewReceipt(context, receiptUrl);
          } else {
            await DonationReceiptHelper.downloadReceipt(context, receiptUrl);
            if (context.mounted) {
              CenteredToast.show(context, 'הורדה הסתיימה');
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, color: Colors.blueGrey, size: 20),
                SizedBox(width: 10),
                Text('צפה בקבלה'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.file_download_outlined, color: Colors.blueGrey, size: 20),
                SizedBox(width: 10),
                Text('הורד קבלה'),
              ],
            ),
          ),
        ],
      );
    }

    // Admin with no receipt: upload button
    final bool canUpload = enabled;
    return Tooltip(
      message: !canUpload ? "ניתן להעלות קבלה רק לתרומות שנאספו" : "",
      child: InkWell(
        onTap: canUpload
            ? () async {
                await DonationReceiptHelper.pickAndUploadPDF(context, donationId);
                onUploadSuccess();
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: canUpload ? Colors.blueGrey : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                "העלה קבלה",
                style: TextStyle(
                  fontSize: 13,
                  color: canUpload ? Colors.blueGrey : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
