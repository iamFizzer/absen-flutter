import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openAttachment(String rawUrl) async {
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    Get.snackbar(
      'Lampiran tidak tersedia',
      'Alamat lampiran tidak valid.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) throw StateError('Lampiran tidak dapat dibuka.');
  } catch (_) {
    Get.snackbar(
      'Gagal membuka lampiran',
      'Periksa koneksi Anda lalu coba kembali.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
