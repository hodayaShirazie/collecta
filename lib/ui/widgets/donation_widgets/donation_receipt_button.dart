import 'package:flutter/material.dart';
import '../../utils/donation/donation_receipt_helper.dart';

class DonationReceiptButton extends StatelessWidget {
  final String donationId;
  final String receiptUrl;
  final VoidCallback onUploadSuccess;
  final bool isAdmin; 

  const DonationReceiptButton({
    super.key,
    required this.donationId,
    required this.receiptUrl,
    required this.onUploadSuccess,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    if (receiptUrl.isEmpty && !isAdmin) {
      return const SizedBox.shrink();
    }

    final bool hasReceipt = receiptUrl.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            !hasReceipt 
                ? Icons.cloud_upload_outlined 
                : Icons.visibility_outlined,
            color: !hasReceipt ? Colors.blueGrey : Colors.blueGrey,
            size: 28,
          ),
          onPressed: () async {
            if (!hasReceipt) {
              await DonationReceiptHelper.pickAndUploadPDF(context, donationId);
              onUploadSuccess();
            } else {
              await DonationReceiptHelper.viewReceipt(context, receiptUrl);
            }
          },
        ),
        Text(
          !hasReceipt ? "העלה" : "צפה",
          style: TextStyle(
            fontSize: 12,
            color: !hasReceipt ? Colors.blueGrey : Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}