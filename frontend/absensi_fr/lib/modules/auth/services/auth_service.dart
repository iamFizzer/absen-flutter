import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoint.dart';
import '../../../core/storage/storage_service.dart';

class AuthService {
  AuthService._();

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoint.login,
        data: {
          "username": username,
          "password": password,
        },
      );

      final data = response.data;

      print(data);

      // Jika access ada berarti login berhasil
      if (data["access"] != null) {
        await StorageService.saveToken(
          accessToken: data["access"],
          refreshToken: data["refresh"],
        );

        return {
          "success": true,
          "message": "Login berhasil",
          "access": data["access"],
          "refresh": data["refresh"],
        };
      }

      return {
        "success": false,
        "message": "Login gagal",
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["detail"] ??
            e.response?.data["message"] ??
            e.message ??
            "Terjadi kesalahan",
      };
    }
  }
}