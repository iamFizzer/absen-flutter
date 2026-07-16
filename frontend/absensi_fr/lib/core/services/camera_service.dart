import 'package:camera/camera.dart';

class CameraService {
  CameraService._();

  static Future<List<CameraDescription>> getCameras() async {
    return availableCameras();
  }

  static CameraDescription preferredCamera(List<CameraDescription> cameras) {
    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
  }
}
