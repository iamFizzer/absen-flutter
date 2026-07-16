import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const String accessTokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";

  /// ===========================
  /// TOKEN
  /// ===========================

  static Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString(accessTokenKey, accessToken);
    await pref.setString(refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(refreshTokenKey);
  }

  static Future<void> clearToken() async {
    final pref = await SharedPreferences.getInstance();

    await pref.remove(accessTokenKey);
    await pref.remove(refreshTokenKey);
  }

  /// ===========================
  /// GENERIC STORAGE
  /// ===========================

  static Future<void> setString(String key, String value) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final pref = await SharedPreferences.getInstance();

    return pref.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final pref = await SharedPreferences.getInstance();

    return pref.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final pref = await SharedPreferences.getInstance();

    return pref.getInt(key);
  }

  static Future<void> remove(String key) async {
    final pref = await SharedPreferences.getInstance();

    await pref.remove(key);
  }

  static Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();

    await pref.clear();
  }
}
