import 'dart:typed_data';

import 'package:bluerum/core/utils/media_upload_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test(
    'accepts supported image/video types and rejects unsupported media',
    () async {
      final image = XFile.fromData(
        Uint8List.fromList([1]),
        name: 'photo.webp',
        mimeType: 'image/webp',
      );
      final video = XFile.fromData(
        Uint8List.fromList([1]),
        name: 'clip.mp4',
        mimeType: 'video/mp4',
      );
      final other = XFile.fromData(
        Uint8List.fromList([1]),
        name: 'archive.zip',
        mimeType: 'application/zip',
      );

      expect(MediaUploadPolicy.isImage(image), isTrue);
      expect(MediaUploadPolicy.isVideo(video), isTrue);
      expect(await MediaUploadPolicy.validate(image), isNull);
      expect(await MediaUploadPolicy.validate(video), isNull);
      expect(await MediaUploadPolicy.validate(other), contains('Unsupported'));
    },
  );
}
