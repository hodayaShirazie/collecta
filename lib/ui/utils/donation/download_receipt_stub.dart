import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadReceiptFile(String url, String fileName) async {
  late final String dirPath;

  if (Platform.isAndroid) {
    final downloadsDir = Directory('/storage/emulated/0/Download');
    dirPath = await downloadsDir.exists()
        ? downloadsDir.path
        : (await getExternalStorageDirectory())!.path;
  } else {
    dirPath = (await getApplicationDocumentsDirectory()).path;
  }

  await FlutterDownloader.enqueue(
    url: url,
    savedDir: dirPath,
    fileName: fileName,
    showNotification: true,
    openFileFromNotification: true,
    saveInPublicStorage: true,
  );
}
