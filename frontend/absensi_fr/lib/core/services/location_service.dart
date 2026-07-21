import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class LocationService {
  LocationService._();

  static const _permissionTimeout = Duration(seconds: 8);
  static const _positionTimeout = Duration(seconds: 15);

  /// ============================
  /// Check Permission
  /// ============================
  static Future<bool> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
      _permissionTimeout,
      onTimeout: () =>
          throw TimeoutException('Pemeriksaan layanan lokasi terlalu lama.'),
    );

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission().timeout(
      _permissionTimeout,
    );

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission().timeout(
        _permissionTimeout,
      );

      if (permission == LocationPermission.denied) {
        throw const PermissionDeniedException(
          'Izin lokasi ditolak. Izinkan lokasi untuk melakukan presensi.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        'Izin lokasi diblokir permanen. Aktifkan kembali melalui pengaturan browser atau perangkat.',
      );
    }

    return true;
  }

  /// ============================
  /// Current Location
  /// ============================
  static Future<LocationModel?> getCurrentLocation() async {
    final hasPermission = await checkPermission();

    if (!hasPermission) {
      return null;
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ),
      ).timeout(_positionTimeout);
    } on TimeoutException {
      // getLastKnownPosition is not implemented by geolocator_web.
      if (kIsWeb) {
        throw TimeoutException(
          'Browser tidak berhasil memperoleh lokasi. Pastikan lokasi perangkat aktif lalu coba lagi.',
        );
      }
      position = await Geolocator.getLastKnownPosition().timeout(
        _permissionTimeout,
        onTimeout: () => null,
      );
    }

    if (position == null) {
      throw TimeoutException(
        'Lokasi tidak berhasil diperoleh. Pastikan GPS aktif dan coba di area terbuka.',
      );
    }

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// ============================
  /// Distance
  /// ============================
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
