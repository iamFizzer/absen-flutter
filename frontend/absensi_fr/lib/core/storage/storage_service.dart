import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const String accessTokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";

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

  static Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}