import 'package:dio/dio.dart';

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
  );
}