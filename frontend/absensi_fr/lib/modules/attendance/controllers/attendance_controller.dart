import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../models/attendance_today_model.dart';
import '../models/attendance_history_model.dart';
import '../services/attendance_service.dart';
import '../views/camera_capture_page.dart';

class AttendanceController extends GetxController {
  String? get action {
    final data = attendance.value;
    if (data == null || data.checkOut != null) return null;
    return data.checkIn == null ? 'check_in' : 'check_out';
  }

  String get actionLabel => action == 'check_out' ? 'CHECK OUT' : 'CHECK IN';

  bool get canSubmit {
    final data = attendance.value;
    return (isInsideOffice.value || !AppConfig.enforceAttendanceRadius) &&
        data != null &&
        action != null &&
        !isLocationLoading.value;
  }

  final attendance = Rxn<AttendanceTodayModel>();

  final history = <AttendanceHistoryModel>[].obs;

  final isLoading = true.obs;

  final latitude = 0.0.obs;

  final longitude = 0.0.obs;

  final distance = 0.0.obs;

  final isInsideOffice = false.obs;

  final isLocationLoading = false.obs;

  final locationError = RxnString();

  final photo = Rxn<XFile>();

  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();

    initialize();
  }

  Future<void> initialize() async {
    await loadAttendance();

    await loadHistory();

    await loadLocation();
  }

  Future<void> loadHistory() async {
    try {
      history.assignAll(await AttendanceService.history());
    } catch (_) {
      history.clear();
    }
  }

  /// ==========================
  /// Attendance
  /// ==========================
  Future<void> loadAttendance() async {
    isLoading.value = true;

    attendance.value = await AttendanceService.today();

    isLoading.value = false;
  }

  /// ==========================
  /// GPS
  /// ==========================
  Future<void> loadLocation() async {
    if (isLocationLoading.value) return;
    isLocationLoading.value = true;
    isInsideOffice.value = false;
    locationError.value = null;
    try {
      // Controller-level watchdog ensures the UI can never remain spinning,
      // even if a browser implementation leaves a permission promise pending.
      final location = await LocationService.getCurrentLocation().timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException(
          'Pengambilan lokasi terlalu lama. Periksa izin lokasi browser lalu coba lagi.',
        ),
      );
      if (location == null || attendance.value == null) return;
      latitude.value = location.latitude;
      longitude.value = location.longitude;
      distance.value = LocationService.calculateDistance(
        startLatitude: latitude.value,
        startLongitude: longitude.value,
        endLatitude: attendance.value!.officeLatitude,
        endLongitude: attendance.value!.officeLongitude,
      );
      isInsideOffice.value = distance.value <= attendance.value!.radius;
    } on LocationServiceDisabledException {
      locationError.value = 'Layanan lokasi/GPS belum aktif.';
    } on PermissionDeniedException catch (error) {
      locationError.value = error.message;
    } on TimeoutException catch (error) {
      locationError.value = error.message ?? 'Pengambilan lokasi terlalu lama.';
    } catch (error) {
      final details = error.toString().toLowerCase();
      locationError.value =
          details.contains('permissions policy') ||
              details.contains('permission policy')
          ? 'Akses lokasi diblokir oleh header Permissions-Policy situs.'
          : 'Lokasi gagal dibaca. Periksa izin browser/perangkat lalu coba lagi.';
    } finally {
      isLocationLoading.value = false;
    }
  }

  Future<void> openCamera() async {
    final image = await Get.to<XFile>(() => const CameraCapturePage());

    if (image == null) {
      return;
    }

    photo.value = image;
  }

  Future<void> retakePhoto() async {
    photo.value = null;
  }

  Future<void> submitAttendance() async {
    if (photo.value == null) {
      Get.snackbar("Peringatan", "Silakan ambil foto terlebih dahulu.");
      return;
    }

    if (!canSubmit || action == null) {
      Get.snackbar(
        "Presensi ditolak",
        attendance.value?.checkOut != null
            ? "Presensi hari ini sudah selesai."
            : "Pastikan Anda berada di dalam radius kantor.",
      );
      return;
    }

    isUploading.value = true;
    try {
      final result = await AttendanceService.submit(
        action: action!,
        latitude: latitude.value,
        longitude: longitude.value,
        selfie: photo.value!,
      );

      if (result["success"] == true) {
        photo.value = null;
        Get.back(result: true);
        Get.snackbar(
          "Berhasil",
          '${result["message"] ?? "Presensi berhasil."} Anda kembali ke Home.',
        );
      } else {
        Get.snackbar(
          "Presensi gagal",
          result["message"] ?? "Silakan coba kembali.",
        );
      }
    } finally {
      // Spinner harus selalu berhenti, termasuk jika request melempar error.
      isUploading.value = false;
    }
  }
}
