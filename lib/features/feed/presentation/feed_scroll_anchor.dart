import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/ads/domain/ads_placement.dart';

/// A visible post and its screen position before a feed layout changes.
final class FeedScrollAnchor {
  const FeedScrollAnchor({
    required this.postId,
    required this.top,
    required this.height,
    required this.visibleTop,
  });

  final int postId;
  final double top;
  final double height;
  final double visibleTop;
}

RenderSliverMultiBoxAdaptor? _feedSliver(GlobalKey key) {
  final renderObject = key.currentContext?.findRenderObject();
  return renderObject is RenderSliverMultiBoxAdaptor ? renderObject : null;
}

int? _postIdAt({
  required int listIndex,
  required List<int> postIds,
  required bool showAds,
}) {
  if (isFeedAdAt(
    index: listIndex,
    postCount: postIds.length,
    postsPerAd: AdsConfig.homePostsPerAd,
    showAds: showAds,
  )) {
    return null;
  }
  final postIndex = feedPostIndex(
    listIndex: listIndex,
    postsPerAd: AdsConfig.homePostsPerAd,
    showAds: showAds,
  );
  if (postIndex < 0 || postIndex >= postIds.length) return null;
  return postIds[postIndex];
}

/// Read only the materialized sliver children; off-screen posts stay recycled.
FeedScrollAnchor? captureFeedScrollAnchor({
  required GlobalKey sliverKey,
  required List<int> postIds,
  required bool showAds,
  required double visibleTop,
  required double visibleBottom,
}) {
  final sliver = _feedSliver(sliverKey);
  if (sliver == null) return null;
  FeedScrollAnchor? anchor;
  sliver.visitChildren((child) {
    if (child is! RenderBox || !child.hasSize || child.size.height <= 0) return;
    final postId = _postIdAt(
      listIndex: sliver.indexOf(child),
      postIds: postIds,
      showAds: showAds,
    );
    if (postId == null) return;
    final top = child.localToGlobal(Offset.zero).dy;
    if (top + child.size.height <= visibleTop || top >= visibleBottom) return;
    if (anchor == null || top < anchor!.top) {
      anchor = FeedScrollAnchor(
        postId: postId,
        top: top,
        height: child.size.height,
        visibleTop: visibleTop,
      );
    }
  });
  return anchor;
}

/// Pixel offset that restores the same post to the same screen position.
double? offsetForFeedScrollAnchor({
  required GlobalKey sliverKey,
  required FeedScrollAnchor anchor,
  required List<int> postIds,
  required bool showAds,
  required double currentOffset,
}) {
  final sliver = _feedSliver(sliverKey);
  if (sliver == null) return null;
  double? newTop;
  double? newHeight;
  sliver.visitChildren((child) {
    if (child is! RenderBox || !child.hasSize) return;
    final postId = _postIdAt(
      listIndex: sliver.indexOf(child),
      postIds: postIds,
      showAds: showAds,
    );
    if (postId == anchor.postId) {
      newTop = child.localToGlobal(Offset.zero).dy;
      newHeight = child.size.height;
    }
  });
  if (newTop == null || newHeight == null) return null;
  final obscuredFraction = ((anchor.visibleTop - anchor.top) / anchor.height)
      .clamp(0.0, 1.0);
  final desiredTop = anchor.top < anchor.visibleTop
      ? anchor.visibleTop - obscuredFraction * newHeight!
      : anchor.top;
  return currentOffset + newTop! - desiredTop;
}
