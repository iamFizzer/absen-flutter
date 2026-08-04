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
    await loadSection(initialSection);
  }

  Future<void> loadAll() => loadSection(initialSection);

  Future<void> loadSection(String section) async {
    isLoading.value = true;
    error.value = null;
    try {
      if (section == 'dashboard') {
        data['employees'] = await AdminService.list('employees');
        final today = DateTime.now();
        biStart.value = today;
        biEnd.value = today;
        await loadBusinessIntelligence(showLoading: false);
      } else if (section == 'business_intelligence') {
        await loadBusinessIntelligence(showLoading: false);
      } else if (section == 'leave_requests') {
        data['leave_requests'] = await AdminService.leaveRequests();
      } else if (AdminService.endpoints.containsKey(section)) {
        if (section == 'employees') {
          final results = await Future.wait([
            AdminService.list('employees'),
            AdminService.list('offices'),
          ]);
          data['employees'] = results[0];
          data['offices'] = results[1];
        } else if (section == 'holidays') {
          final results = await Future.wait([
            AdminService.list('holidays'),
            AdminService.holidayApprovals(),
          ]);
          data['holidays'] = results[0];
          data['holiday_approvals'] = results[1];
        } else {
          data[section] = await AdminService.list(section);
        }
      }
    } catch (e) {
      error.value = AdminService.errorMessage(e);
    } finally {
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

  Future<bool> decideHolidayAttendance(
    int attendanceId,
    String decision, {
    String note = '',
  }) async {
    try {
      final message = await AdminService.decideHolidayAttendance(
        attendanceId,
        decision,
        note: note,
      );
      data['holiday_approvals'] = await AdminService.holidayApprovals();
      Get.snackbar(
        decision == 'approved' ? 'Presensi disetujui' : 'Presensi ditolak',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Approval gagal', AdminService.errorMessage(e));
      return false;
    }
  }

  Future<bool> decideLeaveRequest(
    int id,
    String decision, {
    String note = '',
  }) async {
    try {
      final message = await AdminService.decideLeaveRequest(
        id,
        decision,
        note: note,
      );
      data['leave_requests'] = await AdminService.leaveRequests();
      Get.snackbar(
        decision == 'approved' ? 'Pengajuan disetujui' : 'Pengajuan ditolak',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Pengajuan gagal diproses', AdminService.errorMessage(e));
      return false;
    }
  }

  Future<void> uploadEmployeeFace(int employeeId, XFile image) async {
    try {
      await AdminService.uploadEmployeeFace(employeeId, image);
      data['employees'] = await AdminService.list('employees');
      Get.snackbar(
        'Foto tersimpan',
        'Foto identifikasi siap digunakan saat presensi.',
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
