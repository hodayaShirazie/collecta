import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> downloadReceiptFile(String url, String fileName) async {
  final response = await web.window.fetch(url.toJS).toDart;
  final blob = await response.blob().toDart;
  final blobUrl = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = blobUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(blobUrl);
}
