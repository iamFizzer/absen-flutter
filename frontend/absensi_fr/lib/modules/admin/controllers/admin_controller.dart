import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/business_intelligence_model.dart';
import '../services/admin_service.dart';

class AdminController extends GetxController {
  final selected = 'employees'.obs;
  final isLoading = true.obs;
  final error = RxnString();
  final data = <String, List<Map<String, dynamic>>>{}.obs;
  final businessIntelligence = Rxn<BusinessIntelligenceModel>();
  final isBusinessIntelligenceLoading = false.obs;
  final recapMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final recapStart = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final recapEnd = DateTime.now().obs;
  final biStart = DateTime.now().subtract(const Duration(days: 29)).obs;
  final biEnd = DateTime.now().obs;

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
      await loadBusinessIntelligence(showLoading: false);
      isLoading.value = false;
    } catch (e) {
      error.value = AdminService.errorMessage(e);
      // Tetap tampilkan loading sesuai UX admin ketika data belum berhasil
      // diterima. Tombol refresh pada header masih dapat mencoba ulang.
      isLoading.value = true;
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
      Get.snackbar(
        'Data berhasil dihapus',
        'Daftar data sudah diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<bool> changeEmployeePassword(
    int employeeId,
    String password,
    String confirmation,
  ) async {
    try {
      await AdminService.changeEmployeePassword(
        employeeId,
        password,
        confirmation,
      );
      Get.snackbar(
        'Password berhasil diubah',
        'Pegawai dapat login menggunakan password baru.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Password gagal diubah', AdminService.errorMessage(e));
      return false;
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

  Future<void> loadRecapRange() async {
    try {
      data['attendance_recap'] = await AdminService.list(
        'attendance_recap',
        queryParameters: {
          'start_date': AdminService.dateText(recapStart.value),
          'end_date': AdminService.dateText(recapEnd.value),
        },
      );
    } catch (e) {
      Get.snackbar('Rekap gagal dimuat', AdminService.errorMessage(e));
    }
  }

  Future<void> exportEmployees(String format) async {
    try {
      await AdminService.exportEmployees(format);
    } catch (e) {
      Get.snackbar('Download gagal', AdminService.errorMessage(e));
    }
  }

  Future<void> exportRecap(String format) async {
    try {
      await AdminService.exportRecap(format, recapStart.value, recapEnd.value);
    } catch (e) {
      Get.snackbar('Download gagal', AdminService.errorMessage(e));
    }
  }

  Future<void> loadBusinessIntelligence({bool showLoading = true}) async {
    if (showLoading) isBusinessIntelligenceLoading.value = true;
    try {
      final result = await AdminService.businessIntelligence(
        startDate: biStart.value,
        endDate: biEnd.value,
      );
      businessIntelligence.value = BusinessIntelligenceModel.fromJson(result);
    } catch (e) {
      Get.snackbar('Dashboard BI gagal dimuat', AdminService.errorMessage(e));
    } finally {
      if (showLoading) isBusinessIntelligenceLoading.value = false;
    }
  }

  Future<void> setBusinessIntelligenceRange(DateTime start, DateTime end) async {
    biStart.value = start;
    biEnd.value = end;
    await loadBusinessIntelligence();
  }
}
