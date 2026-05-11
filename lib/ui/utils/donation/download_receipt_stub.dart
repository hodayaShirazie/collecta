import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

Future<void> downloadReceiptFile(String url, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/$fileName';
  final response = await http.get(Uri.parse(url));
  await File(filePath).writeAsBytes(response.bodyBytes);
  await Share.shareXFiles(
    [XFile(filePath, mimeType: 'application/pdf')],
    subject: fileName,
  );
}
