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

    await StorageService.setString(
      userKey,
      jsonEncode(user.toJson()),
    );
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

    _currentUser = UserModel.fromJson(
      jsonDecode(json),
    );

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

    return token != null;
  }
}