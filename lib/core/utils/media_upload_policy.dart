import 'package:image_picker/image_picker.dart';

/// Client-side guardrails. The server remains the authority, but these limits
/// prevent accidental memory exhaustion and make failure deterministic.
abstract final class MediaUploadPolicy {
  static const maxItems = 10;
  static const maxImageBytes = 15 * 1024 * 1024;
  static const maxVideoBytes = 100 * 1024 * 1024;

  static const imageExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.gif',
    '.heic',
    '.avif',
  };
  static const videoExtensions = {'.mp4', '.mov', '.webm', '.mkv', '.3gp'};

  static bool isVideo(XFile file) =>
      file.mimeType?.toLowerCase().startsWith('video/') == true ||
      videoExtensions.any(
        (extension) => file.name.toLowerCase().endsWith(extension),
      );

  static bool isImage(XFile file) =>
      file.mimeType?.toLowerCase().startsWith('image/') == true ||
      imageExtensions.any(
        (extension) => file.name.toLowerCase().endsWith(extension),
      );

  static String mimeType(XFile file) {
    final supplied = file.mimeType?.toLowerCase();
    if (supplied != null &&
        (supplied.startsWith('image/') || supplied.startsWith('video/'))) {
      return supplied;
    }
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.gif')) return 'image/gif';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.heic')) return 'image/heic';
    if (name.endsWith('.avif')) return 'image/avif';
    if (name.endsWith('.mov')) return 'video/quicktime';
    if (name.endsWith('.webm')) return 'video/webm';
    if (name.endsWith('.mkv')) return 'video/x-matroska';
    if (name.endsWith('.3gp')) return 'video/3gpp';
    if (name.endsWith('.mp4')) return 'video/mp4';
    return 'image/jpeg';
  }

  static Future<String?> validate(XFile file) async {
    final video = isVideo(file);
    if (!video && !isImage(file))
      return 'Unsupported file format: ${file.name}';
    final size = await file.length();
    final limit = video ? maxVideoBytes : maxImageBytes;
    if (size > limit) {
      final maxMb = limit ~/ (1024 * 1024);
      return '${file.name} exceeds the $maxMb MB ${video ? 'video' : 'image'} limit';
    }
    if (size == 0) return '${file.name} is empty';
    return null;
  }
}
