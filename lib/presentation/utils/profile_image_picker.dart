import 'dart:typed_data';

import 'profile_image_picker_io.dart'
    if (dart.library.html) 'profile_image_picker_web.dart' as platform_picker;

class ProfileImagePicker {
  static Future<Uint8List?> pickImage({required bool isCamera}) {
    return platform_picker.pickImageFromSource(isCamera);
  }
}
