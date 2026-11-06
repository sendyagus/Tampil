import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageFromSource(bool isCamera) async {
  final picker = ImagePicker();
  final source = isCamera ? ImageSource.camera : ImageSource.gallery;
  final XFile? file = await picker.pickImage(
    source: source,
    maxWidth: 600,
    maxHeight: 600,
    imageQuality: 75,
  );
  if (file != null) {
    return await file.readAsBytes();
  }
  return null;
}
