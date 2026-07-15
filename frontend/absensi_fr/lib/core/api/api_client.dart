import 'package:dio/dio.dart';

import '../storage/storage_service.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:8000/api/v1/",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(

        onRequest: (options, handler) async {

          final token = await StorageService.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("========== REQUEST ==========");
          print(options.method);
          print(options.uri);
          print(options.headers);

          handler.next(options);
        },

        onResponse: (response, handler) {

          print("========== RESPONSE ==========");
          print(response.statusCode);
          print(response.data);

          handler.next(response);
        },

        onError: (e, handler) {

          print("========== ERROR ==========");
          print(e.response?.statusCode);
          print(e.response?.data);

          handler.next(e);
        },

      ),
    );
}