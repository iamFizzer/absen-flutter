import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class LocationService {
  LocationService._();

  /// ============================
  /// Check Permission
  /// ============================
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// ============================
  /// Current Location
  /// ============================
  static Future<LocationModel?> getCurrentLocation() async {
    try {
      final hasPermission =
          await checkPermission();

      if (!hasPermission) {
        return null;
      }

      final position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print(e);

      return null;
    }
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