import 'package:dio/dio.dart';

import '../storage/storage_service.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient._();

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

            onError: (e, handler) {
              handler.next(e);
            },
          ),
        );
}
