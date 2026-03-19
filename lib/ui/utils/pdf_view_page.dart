import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewPage({
    super.key,
    required this.url,
    this.title = "צפייה בקבלה",
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),

        body: SfPdfViewer.network(
          url,

          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('שגיאה בטעינת הקובץ: ${details.description}')),
            );
          },
        ),
      ),
    );
  }
}