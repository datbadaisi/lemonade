import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/media_upload_policy.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/compose/media_attach_list.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

const double _fontLabel = 10;
const double _fontMeta = 12;
const double _fontBody = 13;
const Color _kTextPrimary = Color(0xFF000000);
const Color _kTextSecondary = Color(0xFF525252);
const Color _kSurfaceMuted = Color(0xFFE8E8E8);
const Color _kBorder = Color(0xFFE0E0E0);

/// Upload one tray item (repository lives in the feature screen / Riverpod).
typedef MediaItemUploader = Future<void> Function(UploadItem item);

/// Opens the shared media manager bottom sheet.
///
/// Empty picker cancel is a no-op (no list notify, no parent rebuild).
Future<void> showMediaAttachSheet({
  required BuildContext context,
  required MediaAttachList list,
  required MediaItemUploader uploadItem,
  required String Function(Object error) formatError,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => MediaAttachSheet(
      list: list,
      uploadItem: uploadItem,
      formatError: formatError,
    ),
  );
}

/// Bottom sheet UI for compose media attachments.
class MediaAttachSheet extends StatelessWidget {
  const MediaAttachSheet({
    super.key,
    required this.list,
    required this.uploadItem,
    required this.formatError,
  });

  final MediaAttachList list;
  final MediaItemUploader uploadItem;
  final String Function(Object error) formatError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: ListenableBuilder(
        listenable: list,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (list.isEmpty)
                const Column(
                  children: [
                    SizedBox(height: 28),
                    Center(
                      child: Text(
                        'No media attached',
                        style: TextStyle(
                          fontSize: _fontBody,
                          color: _kTextSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        'You can also add GIFs from the GIF tab on your keyboard',
                        style: TextStyle(
                          fontSize: _fontMeta,
                          color: _kTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: GridView.builder(
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list.items[index];
                      return RepaintBoundary(
                        child: _MediaTile(
                          item: item,
                          onRemove: () => list.removeAt(index),
                          onRetry: () => uploadItem(item),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickAndUpload(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTextPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(MingCuteIcons.mgc_add_line, size: 16),
                label: const Text(
                  'Add Media',
                  style: TextStyle(
                    fontSize: _fontBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext sheetContext) async {
    final messenger = ScaffoldMessenger.maybeOf(sheetContext);
    final picker = ImagePicker();
    try {
      final mediaList = await picker.pickMultipleMedia();
      // Empty cancel: no-op — do not touch list or parent.
      if (!sheetContext.mounted || mediaList.isEmpty) return;

      final newItems = <UploadItem>[];
      for (final media in mediaList) {
        if (list.length + newItems.length >= MediaUploadPolicy.maxItems) {
          messenger?.showSnackBar(
            const SnackBar(
              content: Text('You can attach up to 10 media items'),
            ),
          );
          break;
        }
        final validationError = await MediaUploadPolicy.validate(media);
        if (validationError != null) {
          messenger?.showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Colors.orange,
            ),
          );
          continue;
        }

        final isVideo = MediaUploadPolicy.isVideo(media);
        Uint8List? bytes;
        if (!isVideo) {
          bytes = await media.readAsBytes();
        } else {
          try {
            bytes = await FlutterVideoThumbnailPlus.thumbnailData(
              video: media.path,
              imageFormat: ImageFormat.jpeg,
              maxWidth: 250,
              quality: 75,
            );
          } catch (_) {}
        }
        newItems.add(UploadItem(file: media, bytes: bytes));
      }

      if (newItems.isEmpty) return;
      list.addAll(newItems);
      for (final item in newItems) {
        // Fire uploads; list notifies on progress via [uploadItem] → markChanged.
        // ignore: unawaited_futures
        uploadItem(item);
      }
    } catch (e) {
      if (!sheetContext.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Failed to pick media: ${formatError(e)}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.item,
    required this.onRemove,
    required this.onRetry,
  });

  final UploadItem item;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 8,
          right: 8,
          bottom: 0,
          left: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.error != null
                ? GestureDetector(
                    onTap: () => _showErrorDialog(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0x14E53935),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MingCuteIcons.mgc_refresh_1_line,
                            color: AppColors.danger,
                            size: 22,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: _fontLabel,
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      _LocalThumb(item: item),
                      if (item.isUploading)
                        Container(
                          color: Colors.black38,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  MingCuteIcons.mgc_close_line,
                  size: 12,
                  color: _kTextPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Media Upload Error'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to upload: ${item.file.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                item.error ?? 'Unknown error occurred.',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: _fontBody,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              onRetry();
            },
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalThumb extends StatelessWidget {
  const _LocalThumb({required this.item});

  final UploadItem item;

  static Widget _skeleton() => const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: ShimmerPlaceholder.fill(),
      );

  @override
  Widget build(BuildContext context) {
    // Static thumbs only — no VideoPlayer (avoids dispose/sheet races).
    if (item.isVideo) {
      final Widget thumbnail;
      if (item.bytes != null) {
        thumbnail = Image.memory(
          item.bytes!,
          fit: BoxFit.cover,
          cacheWidth: 250,
        );
      } else if (item.url != null &&
          item.url!.isNotEmpty &&
          isImageUrl(item.url!)) {
        thumbnail = CachedNetworkImage(
          imageUrl: item.url!,
          fit: BoxFit.cover,
          memCacheWidth: 250,
          placeholder: (_, _) => _skeleton(),
          errorWidget: (_, _, _) => Container(
            color: _kTextPrimary,
            alignment: Alignment.center,
            child: const Icon(
              MingCuteIcons.mgc_video_camera_line,
              color: Colors.white54,
              size: 28,
            ),
          ),
        );
      } else {
        thumbnail = Container(
          color: _kTextPrimary,
          alignment: Alignment.center,
          child: const Icon(
            MingCuteIcons.mgc_video_camera_line,
            color: Colors.white54,
            size: 28,
          ),
        );
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          thumbnail,
          Container(color: item.isUploading ? Colors.black54 : Colors.black26),
          Positioned(
            bottom: 8,
            left: 8,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    MingCuteIcons.mgc_play_fill,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (item.url != null && item.url!.isNotEmpty && !item.isUploading) {
      return CachedNetworkImage(
        imageUrl: item.url!,
        fit: BoxFit.cover,
        memCacheWidth: 250,
        placeholder: (_, _) => _skeleton(),
        errorWidget: (_, _, _) => Container(
          color: _kSurfaceMuted,
          child: const Icon(
            MingCuteIcons.mgc_pic_2_line,
            color: _kTextSecondary,
          ),
        ),
      );
    }
    if (item.bytes != null) {
      return Image.memory(
        item.bytes!,
        fit: BoxFit.cover,
        cacheWidth: 250,
      );
    }
    if (item.file.path.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(item.file.path, fit: BoxFit.cover);
      }
      return Image.file(
        io.File(item.file.path),
        fit: BoxFit.cover,
        cacheWidth: 250,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _skeleton();
        },
      );
    }
    return _skeleton();
  }
}
