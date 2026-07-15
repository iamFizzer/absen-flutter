import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoint.dart';
import '../models/attendance_today_model.dart';

class AttendanceService {
  AttendanceService._();

  static Future<AttendanceTodayModel?> today() async {
    try {
      final response = await ApiClient.dio.get(
        ApiEndpoint.attendanceToday,
      );

      final data = response.data;

      if (data["success"] == true) {
        return AttendanceTodayModel.fromJson(
          data["data"],
        );
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}