import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Presensi Pegawai",

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      getPages: AppPages.routes,

      unknownRoute: AppPages.unknownRoute,
    );
  }
}
