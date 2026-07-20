import 'dart:convert';

import '../../modules/auth/models/user_model.dart';
import '../storage/storage_service.dart';

class SessionService {
  SessionService._();

  static UserModel? _currentUser;

  static const String userKey = "user";

  /// ===============================
  /// Save User
  /// ===============================
  static Future<void> saveUser(UserModel user) async {
    _currentUser = user;

    await StorageService.setString(userKey, jsonEncode(user.toJson()));
  }

  /// ===============================
  /// Get User
  /// ===============================
  static Future<UserModel?> getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final json = await StorageService.getString(userKey);

    if (json == null) {
      return null;
    }

    _currentUser = UserModel.fromJson(jsonDecode(json));

    return _currentUser;
  }

  /// ===============================
  /// Clear User
  /// ===============================
  static Future<void> clearUser() async {
    _currentUser = null;

    await StorageService.remove(userKey);
  }

  /// ===============================
  /// Logout
  /// ===============================
  static Future<void> logout() async {
    _currentUser = null;

    await StorageService.clearToken();

    await StorageService.remove(userKey);
  }

  /// ===============================
  /// Check Login
  /// ===============================
  static Future<bool> isLoggedIn() async {
    final token = await StorageService.getAccessToken();

    if (token == null || token.isEmpty || _isTokenExpired(token)) {
      await logout();
      return false;
    }

    return true;
  }

  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final expiresAt = payload['exp'];

      if (expiresAt is! num) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return expiresAt.toInt() <= now;
    } catch (_) {
      return true;
    }
  }
}
