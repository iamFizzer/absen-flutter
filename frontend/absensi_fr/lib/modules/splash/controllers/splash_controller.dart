import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    print("SplashController dibuat");

    Future.delayed(
      const Duration(seconds: 2),
      () {
        print("Pindah ke Login");

        Get.offNamed(AppRoutes.login);
      },
    );
  }
}