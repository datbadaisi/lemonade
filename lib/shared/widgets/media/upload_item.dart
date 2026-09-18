import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// In-progress or completed media attachment for compose screens.
class UploadItem {
  final XFile file;
  final Uint8List? bytes;
  String? url;
  bool isUploading;
  String? error;
  bool isCancelled;
  void Function()? _cancelRequest;

  /// Already on the server (e.g. hydrated from an existing post body).
  /// No re-upload; [url] is the final media URL.
  final bool isRemote;

  UploadItem({
    required this.file,
    this.bytes,
    this.url,
    this.isUploading = true,
    this.error,
    this.isCancelled = false,
    this.isRemote = false,
  });

  /// Attachment already hosted remotely — used when editing an existing post.
  factory UploadItem.remote({required String url, bool isVideo = false}) {
    final name = isVideo ? 'remote_video.mp4' : 'remote_image.jpg';
    final mime = isVideo ? 'video/mp4' : 'image/jpeg';
    // Empty path so UI prefers [url] / CachedNetworkImage over Image.file.
    return UploadItem(
      file: XFile('', name: name, mimeType: mime),
      url: url,
      isUploading: false,
      isRemote: true,
    );
  }

  bool get isVideo {
    final path = file.path.toLowerCase();
    final name = file.name.toLowerCase();
    final urlLower = url?.toLowerCase() ?? '';
    final mime = file.mimeType?.toLowerCase() ?? '';
    return mime.startsWith('video/') ||
        _hasVideoExtension(path) ||
        _hasVideoExtension(name) ||
        _hasVideoExtension(urlLower);
  }

  bool get isSuccessful =>
      !isCancelled &&
      !isUploading &&
      error == null &&
      url != null &&
      url!.isNotEmpty;

  void cancel() {
    isCancelled = true;
    isUploading = false;
    _cancelRequest?.call();
    _cancelRequest = null;
  }

  void attachCancellation(void Function() cancelRequest) {
    _cancelRequest = cancelRequest;
    if (isCancelled) cancelRequest();
  }

  static bool _hasVideoExtension(String value) {
    return value.endsWith('.mp4') ||
        value.endsWith('.mov') ||
        value.endsWith('.webm') ||
        value.endsWith('.avi') ||
        value.endsWith('.mkv') ||
        value.endsWith('.3gp') ||
        value.endsWith('.m3u8');
  }
}
