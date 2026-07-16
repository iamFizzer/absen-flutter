import 'package:get/get.dart';

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
    isLoading.value = true;
    try {
      dashboard.value = await DashboardService.getDashboard();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() => loadDashboard();
}
