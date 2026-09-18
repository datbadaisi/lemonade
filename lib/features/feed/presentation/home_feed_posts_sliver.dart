import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/ads/domain/ads_placement.dart';
import 'package:bluerum/features/ads/presentation/in_feed_native_ad.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_memory.dart';

import 'feed_list_index.dart';
import 'home_feed_tile.dart';

/// Posts + ads sliver — only rebuilds when [postIds] / ads setting change,
/// not when load-more footer flags flip on the parent [HomeScreen].
class HomeFeedPostsSliver extends ConsumerWidget {
  const HomeFeedPostsSliver({
    super.key,
    required this.postIds,
    required this.memoryPolicy,
    required this.indexMapFor,
    required this.findChildIndex,
    required this.onOpen,
    required this.onUpvote,
    required this.onDownvote,
    required this.onSave,
  });

  final List<int> postIds;
  final PostListMemoryPolicy memoryPolicy;
  final FeedListIndexMap Function(List<int> postIds, bool showAds) indexMapFor;
  final int? Function(Key key) findChildIndex;
  final void Function(PostView pv) onOpen;
  final Future<bool> Function(PostView pv) onUpvote;
  final Future<bool> Function(PostView pv) onDownvote;
  final Future<bool> Function(PostView pv) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAds = ref.watch(adsSettingsProvider).showAds;
    final postCount = postIds.length;
    final itemCount = feedItemCount(
      postCount: postCount,
      postsPerAd: AdsConfig.homePostsPerAd,
      showAds: showAds,
    );
    // Warm O(1) findChildIndex map for recycle.
    indexMapFor(postIds, showAds);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (isFeedAdAt(
            index: index,
            postCount: postCount,
            postsPerAd: AdsConfig.homePostsPerAd,
            showAds: showAds,
          )) {
            final slot = (index + 1) ~/ (AdsConfig.homePostsPerAd + 1) - 1;
            return RepaintBoundary(
              child: InFeedNativeAd(
                key: ValueKey('home-ad-slot-$slot'),
                placement: InFeedAdPlacement.homeFeed,
                slot: slot,
                deferUntilNearViewport: true,
                keepHeightOnFailure: true,
              ),
            );
          }
          final postIndex = feedPostIndex(
            listIndex: index,
            postsPerAd: AdsConfig.homePostsPerAd,
            showAds: showAds,
          );
          final postId = postIds[postIndex];
          return HomeFeedTile(
            key: ValueKey(postId),
            postId: postId,
            memoryPolicy: memoryPolicy,
            onOpen: onOpen,
            onUpvote: onUpvote,
            onDownvote: onDownvote,
            onSave: onSave,
          );
        },
        childCount: itemCount,
        findChildIndexCallback: findChildIndex,
        // Commercial virtualization: destroy off-screen Element trees.
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      ),
    );
  }
}

/// Full-viewport empty / error states for the home feed list.
class HomeFeedStatusSliver {
  HomeFeedStatusSliver._();

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF525252);

  static Widget error({
    required String error,
    required VoidCallback onRetry,
  }) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                MingCuteIcons.mgc_wifi_off_line,
                size: 48,
                color: textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 13, color: textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              HomeFeedActionButton(label: 'Retry', onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }

  static Widget empty() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MingCuteIcons.mgc_folder_open_line,
              size: 48,
              color: textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No posts found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary action pill used on home empty/error footers.
class HomeFeedActionButton extends StatelessWidget {
  const HomeFeedActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
