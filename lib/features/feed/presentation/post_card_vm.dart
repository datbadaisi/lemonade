import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/media/media_aspect_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_controller.dart';

/// Precomputed, immutable fields for a feed card — expensive pure work once
/// per [PostView] identity change, not every rebuild.
final class PostCardVm {
  const PostCardVm({
    required this.postId,
    required this.title,
    required this.bodyPreview,
    required this.mediaItems,
    required this.aspectRatio,
    required this.letterbox,
    required this.communityName,
    required this.communityId,
    required this.communityIcon,
    required this.communityTitle,
    required this.creatorName,
    required this.creatorId,
    required this.publishedIso,
    required this.isNsfw,
    required this.hasLinkPreview,
    required this.embedTitle,
    required this.subscribed,
    required this.baseMyVote,
    required this.baseScore,
    required this.baseSaved,
    required this.baseRead,
    required this.commentCount,
    required this.estimatedHeight,
  });

  final int postId;
  final String title;
  final String bodyPreview;
  final List<MediaItem> mediaItems;
  final double aspectRatio;
  final bool letterbox;
  final String communityName;
  final int communityId;
  final String? communityIcon;
  final String communityTitle;
  final String creatorName;
  final int creatorId;
  final String publishedIso;
  final bool isNsfw;
  final bool hasLinkPreview;
  final String? embedTitle;
  final String subscribed;
  final int? baseMyVote;
  final int baseScore;
  final bool baseSaved;
  final bool baseRead;
  final int commentCount;
  final double estimatedHeight;

  MediaItem? get firstMedia => mediaItems.isEmpty ? null : mediaItems.first;
  int get extraMediaCount =>
      mediaItems.isEmpty ? 0 : mediaItems.length - 1;
  bool get hasMedia => mediaItems.isNotEmpty;

  /// Proxy / prefetch height for a known content width (screen − horizontal pad).
  double heightForContentWidth(double contentWidth) {
    final w = contentWidth.clamp(200.0, 600.0);
    // padY 12×2 + meta 20 + title gap 8 + title ≤2 lines + action gap 8 + bar 32
    var est = 12.0 + 12.0 + 20.0 + 8.0 + (16.0 * 1.3 * 2) + 8.0 + 32.0;
    if (bodyPreview.isNotEmpty) {
      est += 8.0 + (13.0 * 1.45 * 2);
    }
    if (hasLinkPreview) est += 8.0 + 48.0;
    if (hasMedia) {
      est += 8.0 + (w / aspectRatio);
    }
    return est;
  }

  factory PostCardVm.fromPostView(PostView pv) {
    final post = pv.post;
    final community = pv.community;
    final creator = pv.creator;
    final media = List<MediaItem>.unmodifiable(extractPostMedia(pv));
    final body = post.body != null
        ? markdownToPlainText(post.body!).trim()
        : '';

    final ratio = _resolveAspectRatio(pv, media);
    final letterbox = ratio < 0.8 || ratio > 3.0;
    final clamped = ratio.clamp(0.8, 3.0);

    // Default estimate at ~360 content width; runtime uses [heightForContentWidth].
    const contentW = 360.0;
    var est = 12.0 + 12.0 + 20.0 + 8.0 + (16.0 * 1.3 * 2) + 8.0 + 32.0;
    if (body.isNotEmpty) {
      est += 8.0 + (13.0 * 1.45 * 2);
    }
    if (post.embedTitle != null) est += 8.0 + 48.0;
    if (media.isNotEmpty) {
      est += 8.0 + (contentW / clamped);
    }

    return PostCardVm(
      postId: post.id,
      title: post.name,
      bodyPreview: body,
      mediaItems: media,
      aspectRatio: clamped,
      letterbox: letterbox,
      communityName: community.name,
      communityId: community.id,
      communityIcon: community.icon,
      communityTitle: community.title,
      creatorName: creator.name,
      creatorId: creator.id,
      publishedIso: post.published,
      isNsfw: post.nsfw,
      hasLinkPreview: post.embedTitle != null,
      embedTitle: post.embedTitle,
      subscribed: pv.subscribed,
      baseMyVote: pv.myVote,
      baseScore: pv.counts.score,
      baseSaved: pv.saved,
      baseRead: pv.read,
      commentCount: pv.counts.comments,
      estimatedHeight: est,
    );
  }

  static double _resolveAspectRatio(PostView pv, List<MediaItem> media) {
    if (media.isEmpty) return 16 / 9;
    final first = media.first;
    if (first.isVideo && first.videoType == VideoType.youtube) {
      return 16 / 9;
    }
    final details = pv.imageDetails;
    final isGif = first.url.toLowerCase().contains('.gif') ||
        (details?.link.toLowerCase().contains('.gif') ?? false);
    if (details != null &&
        details.width > 0 &&
        details.height > 0 &&
        !isGif) {
      final ratio = details.aspectRatio;
      putMediaAspect(first.url, ratio);
      return ratio;
    }
    // Shared process cache (same as comment media) — reverse remounts reuse.
    final cached = cachedMediaAspect(first.url) ??
        cachedMediaAspect(first.thumbnailUrl);
    if (cached != null) return cached;
    return 16 / 9;
  }
}

/// Derived VM for a post id. Null when the entity is not in the feed map.
final postCardVmProvider = Provider.family<PostCardVm?, int>((ref, postId) {
  final pv = ref.watch(feedPostsByIdProvider.select((m) => m[postId]));
  if (pv == null) return null;
  return PostCardVm.fromPostView(pv);
});
