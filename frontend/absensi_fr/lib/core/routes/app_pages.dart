import 'package:get/get.dart';

import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/views/login_page.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_page.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_page.dart';

import '../../modules/attendance/bindings/attendance_binding.dart';
import '../../modules/attendance/views/attendance_page.dart';
import '../../modules/attendance/views/check_in_page.dart';
import '../../modules/attendance/views/check_out_page.dart';
import '../../modules/admin/bindings/admin_binding.dart';
import '../../modules/admin/views/admin_dashboard_page.dart';
import '../../modules/admin/views/unauthorized_page.dart';

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
    GetPage(name: AppRoutes.checkIn, page: () => const CheckInPage()),
    GetPage(name: AppRoutes.checkOut, page: () => const CheckOutPage()),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: AdminBinding(initialSection: 'dashboard'),
    ),
    GetPage(
      name: AppRoutes.businessIntelligence,
      page: () =>
          const AdminDashboardPage(initialSection: 'business_intelligence'),
      binding: AdminBinding(initialSection: 'business_intelligence'),
    ),
    GetPage(
      name: AppRoutes.adminEmployees,
      page: () => const AdminDashboardPage(initialSection: 'employees'),
      binding: AdminBinding(initialSection: 'employees'),
    ),
    GetPage(
      name: AppRoutes.adminOffices,
      page: () => const AdminDashboardPage(initialSection: 'offices'),
      binding: AdminBinding(initialSection: 'offices'),
    ),
    GetPage(
      name: AppRoutes.adminShifts,
      page: () => const AdminDashboardPage(initialSection: 'shifts'),
      binding: AdminBinding(initialSection: 'shifts'),
    ),
    GetPage(
      name: AppRoutes.adminHolidays,
      page: () => const AdminDashboardPage(initialSection: 'holidays'),
      binding: AdminBinding(initialSection: 'holidays'),
    ),
    GetPage(
      name: AppRoutes.adminAttendanceRecap,
      page: () => const AdminDashboardPage(initialSection: 'attendance_recap'),
      binding: AdminBinding(initialSection: 'attendance_recap'),
    ),
    GetPage(name: AppRoutes.unauthorized, page: () => const UnauthorizedPage()),
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => const UnauthorizedPage(notFound: true),
  );
}
