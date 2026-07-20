import 'download_service_stub.dart'
    if (dart.library.html) 'download_service_web.dart';

class DownloadService {
  DownloadService._();

  static void save(List<int> bytes, String filename, String mimeType) {
    saveFile(bytes, filename, mimeType);
  }
}
