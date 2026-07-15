import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/location_model.dart';
import '../../../core/services/location_service.dart';
import '../../../core/config/app_config.dart';
import '../models/attendance_today_model.dart';
import '../services/attendance_service.dart';
import '../../../core/services/camera_service.dart';

class AttendanceController extends GetxController {
  
  bool get canCheckIn {

  if (AppConfig.devMode) {
    return true;
  }

  return isInsideOffice.value;

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

    attendance.value =
        await AttendanceService.today();

    isLoading.value = false;
  }

  /// ==========================
  /// GPS
  /// ==========================
  Future<void> loadLocation() async {

    isLocationLoading.value = true;

    final location =
        await LocationService.getCurrentLocation();

    if (location != null &&
        attendance.value != null) {

      latitude.value = location.latitude;

      longitude.value = location.longitude;

      distance.value =
          LocationService.calculateDistance(

        startLatitude: latitude.value,

        startLongitude: longitude.value,

        endLatitude:
            attendance.value!.officeLatitude,

        endLongitude:
            attendance.value!.officeLongitude,

      );

      isInsideOffice.value =
          distance.value <=
          attendance.value!.radius;

    }

    isLocationLoading.value = false;

  }

  Future<void> openCamera() async {

    final image =
        await CameraService.takePicture();

    if(image==null){
      return;
    }

    photo.value=image;

  }

  Future<void> retakePhoto() async {
    photo.value = null;
  }

  Future<void> submitAttendance() async {
    if (photo.value == null) {
      Get.snackbar(
        "Peringatan",
        "Silakan ambil foto terlebih dahulu.",
      );
      return;
    }

    isUploading.value = true;

    await Future.delayed(
      const Duration(seconds: 2),
    );

    isUploading.value = false;

    Get.snackbar(
      "Berhasil",
      "Tahap selanjutnya upload ke Django",
    );
  }
}