import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final dashboard = Rxn<DashboardModel>();

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final user = await SessionService.getUser();
    if (user?.role == 'admin' || user?.role == 'superadmin') {
      Get.offAllNamed(AppRoutes.adminDashboard);
      return;
    }
    isLoading.value = true;
    try {
      final result = await DashboardService.getDashboard();

      if (result == null) {
        await SessionService.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      dashboard.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() => loadDashboard();
}
