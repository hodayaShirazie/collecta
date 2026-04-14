import 'package:flutter/material.dart';
import '../../utils/donation/donation_receipt_helper.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: !canUpload && !hasReceipt
              ? "ניתן להעלות קבלה רק לתרומות שנאספו"
              : "",
          child: IconButton(
            icon: Icon(
              !hasReceipt
                  ? Icons.cloud_upload_outlined
                  : Icons.visibility_outlined,
              color: canUpload || hasReceipt ? Colors.blueGrey : Colors.grey,
              size: 28,
            ),
            onPressed: (canUpload || hasReceipt) ? () async {
              if (!hasReceipt) {
                await DonationReceiptHelper.pickAndUploadPDF(context, donationId);
                onUploadSuccess();
              } else {
                await DonationReceiptHelper.viewReceipt(context, receiptUrl);
              }
            } : null,
          ),
        ),
        Text(
          !hasReceipt ? "העלה" : "צפה",
          style: TextStyle(
            fontSize: 12,
            color: canUpload || hasReceipt ? Colors.blueGrey : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}