import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoint.dart';
import '../models/attendance_today_model.dart';
import '../models/attendance_history_model.dart';

class AttendanceService {
  AttendanceService._();

  static Future<AttendanceTodayModel?> today() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoint.attendanceToday);

      final data = response.data;

      if (data["success"] == true) {
        return AttendanceTodayModel.fromJson(data["data"]);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> submit({
    required String action,
    required double latitude,
    required double longitude,
    required XFile selfie,
  }) async {
    try {
      final selfieBytes = await selfie.readAsBytes();
      if (selfieBytes.isEmpty) {
        return {
          "success": false,
          "message": "Foto kamera kosong. Silakan ambil selfie ulang.",
        };
      }

      final originalName = selfie.name.trim();
      final filename =
          originalName.toLowerCase().endsWith(".jpg") ||
              originalName.toLowerCase().endsWith(".jpeg")
          ? originalName
          : "selfie_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final formData = FormData.fromMap({
        "action": action,
        // Database menyimpan koordinat dengan presisi 7 angka desimal.
        // Mengirim double mentah dapat menghasilkan 14-16 digit dan ditolak
        // oleh DecimalField pada backend.
        "latitude": latitude.toStringAsFixed(7),
        "longitude": longitude.toStringAsFixed(7),
        "selfie": MultipartFile.fromBytes(
          selfieBytes,
          filename: filename,
          contentType: DioMediaType("image", "jpeg"),
        ),
      });

      final response = await ApiClient.dio.post(
        ApiEndpoint.attendanceSubmit,
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      return {
        "success": false,
        "message": isTimeout
            ? "Server terlalu lama memproses verifikasi wajah. Silakan coba lagi."
            : _errorMessage(data, e.message),
      };
    } catch (e) {
      return {"success": false, "message": "Gagal menyiapkan foto presensi."};
    }
  }

  static Future<List<AttendanceHistoryModel>> history() async {
    final response = await ApiClient.dio.get(ApiEndpoint.attendanceHistory);
    final data = response.data['data'] as List;
    return data
        .map(
          (item) =>
              AttendanceHistoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static String _errorMessage(dynamic data, String? fallback) {
    if (data is Map) {
      final message = data["message"] ?? data["detail"];
      if (message != null) return message.toString();

      final firstError = data.values.isEmpty ? null : data.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError != null) return firstError.toString();
    }
    return fallback ?? "Gagal mengirim presensi.";
  }
}
