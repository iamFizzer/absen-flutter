import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';

class LoginController extends GetxController {
  /// Form Controller
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  /// State
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  /// Toggle Show Password
  void togglePassword() {
    isPasswordHidden.toggle();
  }

  /// Login (sementara)
 Future<void> login() async {

  if (usernameController.text.isEmpty ||
      passwordController.text.isEmpty) {

    Get.snackbar(
      "Peringatan",
      "Username dan Password wajib diisi",
    );

    return;
  }

  isLoading.value = true;

  final result = await AuthService.login(
    username: usernameController.text,
    password: passwordController.text,
  );

  isLoading.value = false;
  if (result["success"] == true) {
    final user = await SessionService.getUser();

    print(user?.nama);
    print(user?.role);

    Get.offAllNamed(
      AppRoutes.dashboard,
    );

  } else {

    Get.snackbar(
      "Login Gagal",
      result["message"],
    );

  }
 }

}