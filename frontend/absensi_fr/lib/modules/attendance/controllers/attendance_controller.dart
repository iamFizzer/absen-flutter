import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../models/attendance_today_model.dart';
import '../services/attendance_service.dart';
import '../views/camera_capture_page.dart';

class AttendanceController extends GetxController {
  bool get canCheckIn {
    final data = attendance.value;
    return (isInsideOffice.value || !AppConfig.enforceAttendanceRadius) &&
        data != null &&
        data.checkOut == null &&
        !isLocationLoading.value;
  }

  final attendance = Rxn<AttendanceTodayModel>();

  final isLoading = true.obs;

  final latitude = 0.0.obs;

  final longitude = 0.0.obs;

  final distance = 0.0.obs;

  final isInsideOffice = false.obs;

  final isLocationLoading = false.obs;

  final photo = Rxn<XFile>();

  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();

    initialize();
  }

  Future<void> initialize() async {
    await loadAttendance();

    await loadLocation();
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
    isLocationLoading.value = true;

    final location = await LocationService.getCurrentLocation();

    if (location != null && attendance.value != null) {
      latitude.value = location.latitude;

      longitude.value = location.longitude;

      distance.value = LocationService.calculateDistance(
        startLatitude: latitude.value,

        startLongitude: longitude.value,

        endLatitude: attendance.value!.officeLatitude,

        endLongitude: attendance.value!.officeLongitude,
      );

      isInsideOffice.value = distance.value <= attendance.value!.radius;
    }

    isLocationLoading.value = false;
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

    if (!canCheckIn) {
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
        latitude: latitude.value,
        longitude: longitude.value,
        selfie: photo.value!,
      );

      if (result["success"] == true) {
        photo.value = null;
        await loadAttendance();
        Get.snackbar("Berhasil", result["message"] ?? "Presensi berhasil.");
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
