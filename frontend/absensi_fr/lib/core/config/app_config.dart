class AppConfig {
  // Gunakan true saat build production.
  static const enforceAttendanceRadius = bool.fromEnvironment(
    "ENFORCE_ATTENDANCE_RADIUS",
    defaultValue: false,
  );

  static const _configuredApiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "https://202-155-94-237.sslip.io/api/v1/",
  );

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) {
      return _configuredApiBaseUrl.endsWith("/")
          ? _configuredApiBaseUrl
          : "$_configuredApiBaseUrl/";
    }

    throw StateError("API_BASE_URL belum dikonfigurasi.");
  }
}
