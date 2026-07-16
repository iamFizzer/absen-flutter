import 'package:get/get.dart';

import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/views/login_page.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_page.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_page.dart';

import '../../modules/attendance/bindings/attendance_binding.dart';
import '../../modules/attendance/views/attendance_page.dart';
import '../../modules/admin/bindings/admin_binding.dart';
import '../../modules/admin/views/admin_dashboard_page.dart';

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

    GetPage(
      name: AppRoutes.dashboard,

      page: () => const DashboardPage(),

      binding: DashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendancePage(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: AdminBinding(),
    ),
  ];
}
