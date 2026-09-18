import 'package:bluerum/features/ads/domain/ads_placement.dart';

/// O(1) list-index lookup for [SliverChildBuilderDelegate.findChildIndexCallback]
/// / [ListView] recycle — avoids linear scans on every element recycle.
final class PostListIndexMap {
  /// Homogeneous post list: keys are post ids ([ValueKey] value is [int]).
  ///
  /// [footerSlots] reserves trailing indices (e.g. load-more spinner) that are
  /// not mapped to post ids.
  PostListIndexMap.fromPostIds(
    List<int> postIds, {
    this.footerSlots = 0,
  })  : postIdToListIndex = <int, int>{
          for (var i = 0; i < postIds.length; i++) postIds[i]: i,
        },
        stringKeyToListIndex = const {};

  /// Heterogeneous lists (search All): arbitrary [Object] keys → index.
  PostListIndexMap.fromKeyedEntries(List<Object> keys)
      : postIdToListIndex = <int, int>{},
        stringKeyToListIndex = <String, int>{},
        footerSlots = 0 {
    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      if (k is int) {
        postIdToListIndex[k] = i;
      } else if (k is String) {
        stringKeyToListIndex[k] = i;
      }
    }
  }

  /// Home-style post list with interleaved in-feed ads.
  ///
  /// Post [ValueKey] values are [int] ids. Ad slots use
  /// `'home-ad-slot-N'` (ordinal) string keys.
  PostListIndexMap.withFeedAds({
    required List<int> postIds,
    required bool showAds,
    required int postsPerAd,
    String adKeyPrefix = 'home-ad-slot-',
  })  : postIdToListIndex = <int, int>{},
        stringKeyToListIndex = <String, int>{},
        footerSlots = 0 {
    final postCount = postIds.length;
    final itemCount = feedItemCount(
      postCount: postCount,
      postsPerAd: postsPerAd,
      showAds: showAds,
    );
    var adOrdinal = 0;
    for (var i = 0; i < itemCount; i++) {
      if (isFeedAdAt(
        index: i,
        postCount: postCount,
        postsPerAd: postsPerAd,
        showAds: showAds,
      )) {
        stringKeyToListIndex['$adKeyPrefix$adOrdinal'] = i;
        adOrdinal++;
        continue;
      }
      final postIndex = feedPostIndex(
        listIndex: i,
        postsPerAd: postsPerAd,
        showAds: showAds,
      );
      if (postIndex >= 0 && postIndex < postCount) {
        postIdToListIndex[postIds[postIndex]] = i;
      }
    }
  }

  final Map<int, int> postIdToListIndex;
  final Map<String, int> stringKeyToListIndex;
  final int footerSlots;

  /// Resolves a [ValueKey] value.
  ///
  /// - [int] → post id
  /// - [String] → typed key (`post_12`, `home-ad-slot-0`, `hdr_Posts`, …)
  int? indexForKeyValue(Object? value) {
    if (value is int) return postIdToListIndex[value];
    if (value is String) return stringKeyToListIndex[value];
    return null;
  }
}
