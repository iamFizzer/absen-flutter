import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoint.dart';
import '../models/leave_request_model.dart';

class LeaveService {
  static Future<List<LeaveRequestModel>> list() async {
    final response = await ApiClient.dio.get(ApiEndpoint.leaveRequests);
    final data = response.data['data'] as List;
    return data
        .map(
          (item) => LeaveRequestModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Future<String> create({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    PlatformFile? attachment,
  }) async {
    final form = FormData.fromMap({
      'type': type,
      'start_date': _date(startDate),
      'end_date': _date(endDate),
      'reason': reason,
      if (attachment != null)
        'attachment': MultipartFile.fromBytes(
          attachment.bytes!,
          filename: attachment.name,
          contentType: DioMediaType('application', 'pdf'),
        ),
    });
    final response = await ApiClient.dio.post(
      ApiEndpoint.leaveRequests,
      data: form,
    );
    return response.data['message']?.toString() ??
        'Pengajuan berhasil dikirim.';
  }

  static Future<String> cancel(int id) async {
    final response = await ApiClient.dio.delete(
      '${ApiEndpoint.leaveRequests}$id/',
    );
    return response.data['message']?.toString() ?? 'Pengajuan dibatalkan.';
  }

  static String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
