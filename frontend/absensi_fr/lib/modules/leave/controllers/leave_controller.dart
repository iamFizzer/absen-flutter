import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/leave_request_model.dart';
import '../services/leave_service.dart';

class LeaveController extends GetxController {
  final requests = <LeaveRequestModel>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      requests.assignAll(await LeaveService.list());
    } catch (e) {
      error.value = _message(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submit(
    String type,
    DateTime start,
    DateTime end,
    String reason,
    XFile? attachment,
  ) async {
    isSubmitting.value = true;
    try {
      final message = await LeaveService.create(
        type: type,
        startDate: start,
        endDate: end,
        reason: reason,
        attachment: attachment,
      );
      await load();
      Get.snackbar(
        'Pengajuan terkirim',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Pengajuan gagal',
        _message(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> cancel(int id) async {
    try {
      final message = await LeaveService.cancel(id);
      await load();
      Get.snackbar('Berhasil', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Pembatalan gagal', _message(e));
    }
  }

  String _message(Object error) {
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      return data['message']?.toString() ?? data.values.join('\n');
    }
    return 'Tidak dapat terhubung ke server. Silakan coba kembali.';
  }
}
