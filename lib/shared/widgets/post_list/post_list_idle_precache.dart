import 'dart:async';

import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:flutter/widgets.dart';

/// Bounded idle-only media warm for post-card lists (secondary surfaces + home).
///
/// Skip while [isFlinging]; cap unique URLs so reverse fling stays cheap without
/// unbounded ImageCache growth.
final class PostListIdlePrecache {
  PostListIdlePrecache({this.maxCachedUrls = 120, this.ahead = 4});

  final int maxCachedUrls;
  final int ahead;

  final Set<String> _preloadedUrls = <String>{};
  int _lastPreloadedVisibleIndex = -1;

  void clear() {
    _preloadedUrls.clear();
    _lastPreloadedVisibleIndex = -1;
  }

  /// Prefetch first media for posts near the viewport.
  void preload({
    required BuildContext context,
    required List<PostView> posts,
    required double scrollPixels,
    required double viewportHeight,
    required double averageCardHeight,
    required bool isFlinging,
  }) {
    if (isFlinging || !context.mounted || posts.isEmpty) return;
    preloadStillUrls(
      context: context,
      itemCount: posts.length,
      stillUrlAt: (i) {
        final media = extractPostMedia(posts[i]);
        if (media.isEmpty) return null;
        final first = media.first;
        if (first.isImage) return first.url;
        // Poster image only — never MediaCodec-extract offscreen video.
        final thumb = first.thumbnailUrl;
        return (thumb != null && thumb.isNotEmpty) ? thumb : null;
      },
      scrollPixels: scrollPixels,
      viewportHeight: viewportHeight,
      averageRowHeight: averageCardHeight <= 0 ? 360.0 : averageCardHeight,
      isFlinging: isFlinging,
    );
  }

  /// Prefetch still URLs (images / video posters) near the viewport.
  ///
  /// Used by post cards and lightweight comment list thumbs. [stillUrlAt]
  /// returns null for rows with no still to warm.
  void preloadStillUrls({
    required BuildContext context,
    required int itemCount,
    required String? Function(int index) stillUrlAt,
    required double scrollPixels,
    required double viewportHeight,
    required double averageRowHeight,
    required bool isFlinging,
  }) {
    if (isFlinging || !context.mounted || itemCount <= 0) return;
    final avgH = averageRowHeight <= 0 ? 160.0 : averageRowHeight;
    final lastVisible =
        ((scrollPixels + viewportHeight) / avgH).ceil().clamp(0, itemCount - 1);
    final firstVisible =
        (scrollPixels / avgH).floor().clamp(0, itemCount - 1);

    if (lastVisible == _lastPreloadedVisibleIndex) return;
    _lastPreloadedVisibleIndex = lastVisible;

    final preloadEnd = (lastVisible + ahead).clamp(0, itemCount);
    for (var i = firstVisible; i < preloadEnd; i++) {
      _precache(context, stillUrlAt(i));
    }

    if (_preloadedUrls.length > maxCachedUrls) {
      _preloadedUrls.removeAll(
        _preloadedUrls.take(_preloadedUrls.length - maxCachedUrls),
      );
    }
  }

  void _precache(BuildContext context, String? url) {
    if (url == null || url.isEmpty || !_preloadedUrls.add(url)) return;
    unawaited(precacheMediaImage(context, url));
  }
}
