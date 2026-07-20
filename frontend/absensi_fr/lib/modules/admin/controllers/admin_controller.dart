import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/admin_service.dart';

class AdminController extends GetxController {
  final selected = 'employees'.obs;
  final isLoading = true.obs;
  final error = RxnString();
  final data = <String, List<Map<String, dynamic>>>{}.obs;
  final recapMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

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

  Future<void> uploadEmployeeFace(int employeeId, XFile image) async {
    try {
      await AdminService.uploadEmployeeFace(employeeId, image);
      data['employees'] = await AdminService.list('employees');
      Get.snackbar(
        'Foto tersimpan',
        'Foto identifikasi siap digunakan saat absensi.',
      );
    } catch (e) {
      Get.snackbar('Foto gagal disimpan', AdminService.errorMessage(e));
    }
  }

  Future<void> changeRecapMonth(int offset) async {
    final current = recapMonth.value;
    recapMonth.value = DateTime(current.year, current.month + offset);
    try {
      data['attendance_recap'] = await AdminService.list(
        'attendance_recap',
        queryParameters: {
          'year': recapMonth.value.year,
          'month': recapMonth.value.month,
        },
      );
    } catch (e) {
      Get.snackbar('Rekap gagal dimuat', AdminService.errorMessage(e));
    }
  }
}
