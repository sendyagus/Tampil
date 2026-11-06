// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List?> pickImageFromSource(bool isCamera) async {
  final completer = Completer<Uint8List?>();

  final input = html.FileUploadInputElement()..accept = 'image/*';
  if (isCamera) {
    input.setAttribute('capture', 'user');
  }

  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((_) {
        try {
          final result = reader.result;
          if (result is String) {
            final base64String = result.split(',').last;
            final bytes = base64Decode(base64String);
            completer.complete(bytes);
          } else {
            completer.complete(null);
          }
        } catch (_) {
          completer.complete(null);
        }
      });

      reader.onError.listen((_) {
        completer.complete(null);
      });

      reader.readAsDataUrl(file);
    } else {
      completer.complete(null);
    }
  });

  input.click();
  return completer.future;
}
