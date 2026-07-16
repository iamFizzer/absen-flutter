import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoint.dart';
import '../../../core/storage/storage_service.dart';
import '../models/user_model.dart';
import '../../../core/session/session_service.dart';

class AuthService {
  AuthService._();

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoint.login,
        data: {"username": username, "password": password},
      );

      final data = response.data;

      if (data["access"] != null) {
        /// Simpan Token
        await StorageService.saveToken(
          accessToken: data["access"],
          refreshToken: data["refresh"],
        );

        /// Ambil Profile
        final user = await profile();

        if (user != null) {
          await SessionService.saveUser(user);
        }

        return {"success": true, "message": "Login berhasil"};
      }

      return {"success": false, "message": "Login gagal"};
    } on DioException catch (e) {
      final isConnectionError =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError;

      return {
        "success": false,
        "message": isConnectionError
            ? "Tidak dapat terhubung ke server. Pastikan backend Django sedang berjalan."
            : e.response?.data["detail"] ??
                  e.response?.data["message"] ??
                  e.message ??
                  "Terjadi kesalahan",
      };
    }
  }

  static Future<UserModel?> profile() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoint.profile);

      final data = response.data;

      if (data["success"] == true) {
        return UserModel.fromJson(data["data"]);
      }

      return null;
    } on DioException {
      return null;
    }
  }
}
