import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';

class AdminService {
  AdminService._();
  static const endpoints = {
    'employees': '/employees/',
    'offices': '/offices/',
    'shifts': '/master/shifts/',
    'holidays': '/master/holidays/',
    'attendance_recap': '/attendance/monthly-recap/',
  };

  static Future<List<Map<String, dynamic>>> list(
    String type, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await ApiClient.dio.get(
      endpoints[type]!,
      queryParameters: queryParameters,
    );
    final raw = response.data is Map
        ? response.data['results'] ?? response.data['data']
        : response.data;
    return (raw as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> create(String type, Map<String, dynamic> data) async {
    await ApiClient.dio.post(endpoints[type]!, data: data);
  }

  static Future<void> update(
    String type,
    int id,
    Map<String, dynamic> data,
  ) async {
    await ApiClient.dio.patch('${endpoints[type]}$id/', data: data);
  }

  static Future<void> delete(String type, int id) async {
    await ApiClient.dio.delete('${endpoints[type]}$id/');
  }

  static Future<void> uploadEmployeeFace(int employeeId, XFile image) async {
    final bytes = await image.readAsBytes();
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: image.name),
    });
    await ApiClient.dio.post('/employees/$employeeId/face/', data: formData);
  }

  static String errorMessage(Object error) {
    if (error is DioException && error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map) {
        return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      }
    }
    return 'Operasi gagal. Periksa data dan koneksi server.';
  }
}
