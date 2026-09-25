import 'package:bluerum/shared/widgets/post_list/post_list_index.dart';

/// O(1) home-feed key lookup.
///
/// O(1) list-index lookup for [SliverChildBuilderDelegate.findChildIndexCallback].
typedef FeedListIndexMap = PostListIndexMap;

/// Builds a home feed index map.
PostListIndexMap buildHomeFeedIndexMap({required List<int> postIds}) =>
    PostListIndexMap.fromPostIds(postIds);
