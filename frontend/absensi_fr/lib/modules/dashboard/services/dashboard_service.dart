import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoint.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  DashboardService._();

  static Future<DashboardModel?> getDashboard() async {
    try {
      final response = await ApiClient.dio.get(
        ApiEndpoint.dashboard,
      );

      final data = response.data;

      if (data["success"] == true) {
        return DashboardModel.fromJson(
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