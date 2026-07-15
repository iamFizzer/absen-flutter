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

    dashboard.value = await DashboardService.getDashboard();

    isLoading.value = false;

  }

}