import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void saveFile(List<int> bytes, String filename, String mimeType) {
  final parts = <JSAny>[Uint8List.fromList(bytes).toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..click();
  web.URL.revokeObjectURL(url);
}
