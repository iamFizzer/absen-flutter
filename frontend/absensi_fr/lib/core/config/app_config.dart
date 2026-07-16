import 'package:flutter/foundation.dart';

class AppConfig {
  // Gunakan true saat build production.
  static const enforceAttendanceRadius = bool.fromEnvironment(
    "ENFORCE_ATTENDANCE_RADIUS",
    defaultValue: false,
  );

  static const _configuredApiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "",
  );

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) {
      return _configuredApiBaseUrl.endsWith("/")
          ? _configuredApiBaseUrl
          : "$_configuredApiBaseUrl/";
    }

    if (kIsWeb) {
      final backendHost = Uri.base.host.isEmpty ? "127.0.0.1" : Uri.base.host;
      return "http://$backendHost:8000/api/v1/";
    }

    // Alamat host machine dari Android Emulator.
    return "http://10.0.2.2:8000/api/v1/";
  }
}
