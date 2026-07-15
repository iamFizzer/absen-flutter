import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../../auth/services/auth_service.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    super.onInit();

    checkLogin();
  }

  Future<void> checkLogin() async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    /// cek token
    final isLogin = await SessionService.isLoggedIn();

    if (!isLogin) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    /// cek user di local
    var user = await SessionService.getUser();

    /// kalau belum ada, ambil dari server
    if (user == null) {

      user = await AuthService.profile();

      if (user != null) {
        await SessionService.saveUser(user);
      } else {
        await SessionService.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

    }

    print(user.nama);
    print(user.role);

    Get.offAllNamed(
      AppRoutes.dashboard,
    );

  }
}