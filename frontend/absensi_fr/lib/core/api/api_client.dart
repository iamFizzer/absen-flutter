import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../routes/app_routes.dart';
import '../session/session_service.dart';
import '../storage/storage_service.dart';

class ApiClient {
  ApiClient._();

  static bool _isRedirectingToLogin = false;

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            headers: {"Accept": "application/json"},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await StorageService.getAccessToken();

              if (token != null && token.isNotEmpty) {
                options.headers["Authorization"] = "Bearer $token";
              }

              handler.next(options);
            },

            onResponse: (response, handler) {
              handler.next(response);
            },

            onError: (e, handler) async {
              if (e.response?.statusCode == 401) {
                final token = await StorageService.getAccessToken();

                // Jangan perlakukan salah password pada endpoint login sebagai
                // session kedaluwarsa. Logout hanya jika sebelumnya ada token.
                if (token != null && token.isNotEmpty) {
                  await _expireSession();
                }
              }

              handler.next(e);
            },
          ),
        );

  static Future<void> _expireSession() async {
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;

    try {
      await SessionService.logout();

      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      _isRedirectingToLogin = false;
    }
  }
}
