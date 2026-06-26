import 'package:image_picker/image_picker.dart';

enum ProfilePhotoSource {
  camera,
  gallery,
}

abstract class ProfilePhotoPicker {
  Future<String?> pick(ProfilePhotoSource source);
}

class DeviceProfilePhotoPicker implements ProfilePhotoPicker {
  DeviceProfilePhotoPicker({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pick(ProfilePhotoSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source == ProfilePhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 88,
    );
    return file?.path;
  }
}
