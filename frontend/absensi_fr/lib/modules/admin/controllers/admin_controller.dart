import 'package:get/get.dart';
import '../services/admin_service.dart';

class AdminController extends GetxController {
  final selected = 'employees'.obs;
  final isLoading = true.obs;
  final error = RxnString();
  final data = <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final values = await Future.wait(
        AdminService.endpoints.keys.map(AdminService.list),
      );
      data.assignAll(Map.fromIterables(AdminService.endpoints.keys, values));
    } catch (e) {
      error.value = AdminService.errorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save(String type, Map<String, dynamic> value, {int? id}) async {
    try {
      if (id == null) {
        await AdminService.create(type, value);
      } else {
        await AdminService.update(type, id, value);
      }
      data[type] = await AdminService.list(type);
      return true;
    } catch (e) {
      Get.snackbar('Data gagal disimpan', AdminService.errorMessage(e));
      return false;
    }
  }

  Future<void> remove(String type, int id) async {
    try {
      await AdminService.delete(type, id);
      data[type] = await AdminService.list(type);
    } catch (e) {
      Get.snackbar('Data gagal dihapus', AdminService.errorMessage(e));
    }
  }
}
