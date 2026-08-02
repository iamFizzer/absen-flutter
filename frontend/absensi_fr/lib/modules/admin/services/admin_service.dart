import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/download/download_service.dart';

class AdminService {
  AdminService._();
  static const endpoints = {
    'employees': '/employees/',
    'offices': '/offices/',
    'shifts': '/master/shifts/',
    'holidays': '/master/holidays/',
    'attendance_recap': '/attendance/monthly-recap/',
  };

  static const businessIntelligenceEndpoint =
      '/dashboard/business-intelligence/';

  static const holidayApprovalsEndpoint = '/attendance/holiday-approvals/';

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

  static Future<void> changeEmployeePassword(
    int employeeId,
    String password,
    String confirmation,
  ) async {
    await ApiClient.dio.post(
      '/employees/$employeeId/change-password/',
      data: {'password': password, 'password_confirmation': confirmation},
    );
  }

  static Future<List<Map<String, dynamic>>> holidayApprovals() async {
    final response = await ApiClient.dio.get(holidayApprovalsEndpoint);
    final raw = response.data is Map ? response.data['data'] : response.data;
    return (raw as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<String> decideHolidayAttendance(
    int attendanceId,
    String decision, {
    String note = '',
  }) async {
    final response = await ApiClient.dio.post(
      '$holidayApprovalsEndpoint$attendanceId/decision/',
      data: {'decision': decision, 'note': note},
    );
    return response.data['message']?.toString() ??
        'Status approval berhasil diperbarui.';
  }

  static Future<void> exportEmployees(String format) async {
    await _download('/employees/export/', 'data-pegawai.$format', format);
  }

  static Future<void> exportRecap(
    String format,
    DateTime start,
    DateTime end,
  ) async {
    final startText = dateText(start);
    final endText = dateText(end);
    await _download(
      '/attendance/recap/export/',
      'rekap-presensi-$startText-$endText.$format',
      format,
      queryParameters: {'start_date': startText, 'end_date': endText},
    );
  }

  static Future<Map<String, dynamic>> businessIntelligence({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await ApiClient.dio.get(
      businessIntelligenceEndpoint,
      queryParameters: {
        if (startDate != null) 'start_date': dateText(startDate),
        if (endDate != null) 'end_date': dateText(endDate),
      },
    );
    final data = response.data;
    if (data is Map && data['success'] == true) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    throw Exception('Gagal memuat dashboard BI.');
  }

  static Future<void> _download(
    String endpoint,
    String filename,
    String format, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await ApiClient.dio.get<List<int>>(
      endpoint,
      queryParameters: {...?queryParameters, 'format': format},
      options: Options(responseType: ResponseType.bytes),
    );
    DownloadService.save(
      response.data!,
      filename,
      format == 'pdf'
          ? 'application/pdf'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  static String dateText(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

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
