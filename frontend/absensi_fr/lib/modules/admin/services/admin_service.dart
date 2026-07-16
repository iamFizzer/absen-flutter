import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class AdminService {
  AdminService._();
  static const endpoints = {
    'employees': '/employees/',
    'offices': '/offices/',
    'shifts': '/master/shifts/',
    'holidays': '/master/holidays/',
  };

  static Future<List<Map<String, dynamic>>> list(String type) async {
    final response = await ApiClient.dio.get(endpoints[type]!);
    final raw = response.data is Map ? response.data['results'] : response.data;
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
