import 'package:bluerum/shared/widgets/post_list/post_list_index.dart';

/// Home-feed ads-aware index map (alias of shared [PostListIndexMap.withFeedAds]).
///
/// O(1) list-index lookup for [SliverChildBuilderDelegate.findChildIndexCallback].
typedef FeedListIndexMap = PostListIndexMap;

/// Builds a home feed index map (posts + `home-ad-slot-N` keys).
PostListIndexMap buildHomeFeedIndexMap({
  required List<int> postIds,
  required bool showAds,
  required int postsPerAd,
}) =>
    PostListIndexMap.withFeedAds(
      postIds: postIds,
      showAds: showAds,
      postsPerAd: postsPerAd,
    );
