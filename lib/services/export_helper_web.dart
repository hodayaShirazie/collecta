import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> saveAndShareExcel(List<int> bytes, String fileName) async {
  final uint8List = Uint8List.fromList(bytes);
  final blob = web.Blob(
    <JSAny>[uint8List.toJS].toJS,
    web.BlobPropertyBag(
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
