import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/business_intelligence_model.dart';
import '../services/admin_service.dart';

class AdminController extends GetxController {
  final String initialSection;

  AdminController({this.initialSection = 'dashboard'});

  final isSidebarCollapsed = false.obs;
  final isLoading = true.obs;
  final error = RxnString();
  final data = <String, List<Map<String, dynamic>>>{}.obs;
  final businessIntelligence = Rxn<BusinessIntelligenceModel>();
  final isBusinessIntelligenceLoading = false.obs;
  final businessIntelligenceError = RxnString();
  final recapMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final recapStart = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final recapEnd = DateTime.now().obs;
  final biStart = DateTime.now().subtract(const Duration(days: 29)).obs;
  final biEnd = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    if (!await SessionService.isLoggedIn()) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    var user = await SessionService.getUser();
    user ??= await AuthService.profile();
    if (user == null) {
      await SessionService.logout();
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    await SessionService.saveUser(user);
    final isAdmin = user.role == 'admin' || user.role == 'superadmin';
    if (!isAdmin) {
      Get.offAllNamed(AppRoutes.unauthorized);
      return;
    }
    await loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final values = await Future.wait(
        AdminService.endpoints.keys.map(AdminService.list),
      );
      data.assignAll(Map.fromIterables(AdminService.endpoints.keys, values));
      if (initialSection == 'dashboard') {
        final today = DateTime.now();
        biStart.value = today;
        biEnd.value = today;
      }
      if (initialSection == 'dashboard' ||
          initialSection == 'business_intelligence') {
        await loadBusinessIntelligence(showLoading: false);
      }
      isLoading.value = false;
    } catch (e) {
      error.value = AdminService.errorMessage(e);
      isLoading.value = false;
    }
  }

  void toggleSidebar() => isSidebarCollapsed.toggle();

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
    businessIntelligenceError.value = null;
    try {
      final result = await AdminService.businessIntelligence(
        startDate: biStart.value,
        endDate: biEnd.value,
      );
      businessIntelligence.value = BusinessIntelligenceModel.fromJson(result);
    } catch (e) {
      businessIntelligenceError.value = AdminService.errorMessage(e);
    } finally {
      if (showLoading) isBusinessIntelligenceLoading.value = false;
    }
  }

  Future<void> setBusinessIntelligenceRange(
    DateTime start,
    DateTime end,
  ) async {
    biStart.value = start;
    biEnd.value = end;
    await loadBusinessIntelligence();
  }

  Future<void> resetBusinessIntelligenceRange() async {
    biStart.value = DateTime.now().subtract(const Duration(days: 29));
    biEnd.value = DateTime.now();
    await loadBusinessIntelligence();
  }
}
