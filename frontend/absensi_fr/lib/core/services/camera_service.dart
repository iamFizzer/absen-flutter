import 'package:image_picker/image_picker.dart';

class CameraService {

  CameraService._();

  static final ImagePicker _picker =
      ImagePicker();

  static Future<XFile?> takePicture() async {

    final image =
        await _picker.pickImage(

      source: ImageSource.camera,

      preferredCameraDevice:
          CameraDevice.front,

      imageQuality: 80,

    );

    return image;

  }

}