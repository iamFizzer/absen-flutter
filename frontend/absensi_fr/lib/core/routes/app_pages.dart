import 'package:get/get.dart';

import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/views/login_page.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_page.dart';

import 'app_routes.dart';

class AppPages {

  static final routes = [

    GetPage(

      name: AppRoutes.splash,

      page: () => const SplashPage(),

      binding: SplashBinding(),

    ),

    GetPage(

      name: AppRoutes.login,

      page: () => const LoginPage(),

      binding: LoginBinding(),

    ),

  ];

}