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
    if (receiptUrl.isEmpty && !isAdmin) {
      return const SizedBox.shrink();
    }

    final bool hasReceipt = receiptUrl.isNotEmpty;
    final bool canUpload = enabled && !hasReceipt;

    if (!hasReceipt) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: !canUpload ? "ניתן להעלות קבלה רק לתרומות שנאספו" : "",
            child: IconButton(
              icon: Icon(
                Icons.cloud_upload_outlined,
                color: canUpload ? Colors.blueGrey : Colors.grey,
                size: 28,
              ),
              onPressed: canUpload ? () async {
                await DonationReceiptHelper.pickAndUploadPDF(context, donationId);
                onUploadSuccess();
              } : null,
            ),
          ),
          Text(
            "העלה",
            style: TextStyle(
              fontSize: 12,
              color: canUpload ? Colors.blueGrey : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.description_outlined, color: Colors.blueGrey, size: 26),
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
}