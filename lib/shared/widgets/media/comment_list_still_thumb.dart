import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';

/// Fixed-height still for secondary comment lists (profile / search).
///
/// Feed decode path, solid placeholder, gate on scroll, poster-only for video,
/// optional +N for multi-media. Not [CommentMediaWidget] / autoplay / carousel.
class CommentListStillThumb extends StatelessWidget {
  const CommentListStillThumb({
    super.key,
    required this.media,
    this.extraCount = 0,
  });

  final List<MediaItem> media;
  final int extraCount;

  /// Locked height so recycle never reflows (unlike aspect-fit detail media).
  static const double height = 120;

  static String? stillUrl(MediaItem item) {
    if (item.isImage) return item.url;
    final thumb = item.thumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) return thumb;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();
    final first = media.first;
    final url = stillUrl(first);
    final cacheW = inPageMediaMemCacheWidth(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null && url.isNotEmpty)
              ScrollStableNetworkImage(
                imageUrl: url,
                memCacheWidth: cacheW,
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                placeholderColor: const Color(0xFFE8E8E8),
                gateOnScroll: true,
              )
            else
              const ColoredBox(color: Color(0xFFE8E8E8)),
            if (first.isVideo)
              const Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x66000000),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      MingCuteIcons.mgc_play_fill,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (extraCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xCC000000),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                      '+$extraCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
