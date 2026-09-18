import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/ads/domain/ads_placement.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_idle_precache.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_memory.dart';

import 'feed_controller.dart';
import 'feed_scroll_phase.dart';
import 'post_card_vm.dart';

/// Idle-gated load-more + media precache for the home feed list.
final class HomeFeedPagination {
  HomeFeedPagination({
    required this.scrollController,
    required this.memoryPolicy,
    required this.idlePrecache,
    required this.phaseListenable,
    required this.isMounted,
    required this.isBusy,
    required this.suppressPrecache,
  });

  final ScrollController scrollController;
  final PostListMemoryPolicy memoryPolicy;
  final PostListIdlePrecache idlePrecache;
  final ValueNotifier<FeedScrollPhase> phaseListenable;
  final bool Function() isMounted;
  final bool Function() isBusy;
  final bool Function() suppressPrecache;

  static const double minimumDataBuffer = 1200;

  bool pendingLoadMore = false;
  Timer? _loadMoreDebounce;

  void cancel() {
    _loadMoreDebounce?.cancel();
    pendingLoadMore = false;
  }

  void dispose() {
    _loadMoreDebounce?.cancel();
  }

  void onScrollPhaseIdle(BuildContext context, WidgetRef ref) {
    if (!isMounted() || isBusy()) return;
    if (phaseListenable.value != FeedScrollPhase.idle) return;
    if (pendingLoadMore) {
      pendingLoadMore = false;
      requestLoadMoreDebounced(ref);
    }
    preloadAhead(context, ref);
  }

  void onScroll(
    BuildContext context,
    WidgetRef ref, {
    required void Function(ScrollPosition) onMetrics,
  }) {
    if (!isMounted() || !scrollController.hasClients || isBusy()) return;
    final position = scrollController.position;
    onMetrics(position);

    if (needsMoreData(position)) {
      final phase = phaseListenable.value;
      final busy =
          phase != FeedScrollPhase.idle || position.isScrollingNotifier.value;
      if (busy) {
        pendingLoadMore = true;
      } else {
        requestLoadMoreDebounced(ref);
      }
    }

    if (phaseListenable.value == FeedScrollPhase.idle) {
      preloadAhead(context, ref);
    }
  }

  bool needsMoreData(ScrollPosition position) {
    final targetBuffer = math.max(
      minimumDataBuffer,
      position.viewportDimension * 1.75,
    );
    return position.extentAfter <= targetBuffer;
  }

  void requestLoadMoreDebounced(WidgetRef ref) {
    _loadMoreDebounce?.cancel();
    _loadMoreDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!isMounted() || !scrollController.hasClients) return;
      if (phaseListenable.value != FeedScrollPhase.idle) {
        pendingLoadMore = true;
        return;
      }
      if (scrollController.position.isScrollingNotifier.value) {
        pendingLoadMore = true;
        return;
      }
      if (needsMoreData(scrollController.position)) {
        unawaited(ref.read(feedControllerProvider.notifier).loadMore());
      }
    });
  }

  void scheduleDataBufferCheck(WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted() || !scrollController.hasClients) return;
      if (phaseListenable.value != FeedScrollPhase.idle) {
        if (needsMoreData(scrollController.position)) {
          pendingLoadMore = true;
        }
        return;
      }
      if (needsMoreData(scrollController.position)) {
        requestLoadMoreDebounced(ref);
      }
    });
  }

  void preloadAhead(BuildContext context, WidgetRef ref) {
    if (suppressPrecache()) return;
    if (!context.mounted) return;
    final feed = ref.read(feedControllerProvider);
    final postsById = ref.read(feedPostsByIdProvider);
    if (feed.postIds.isEmpty || !scrollController.hasClients) return;
    if (phaseListenable.value == FeedScrollPhase.flinging) return;

    final pos = scrollController.position;
    final showAds = ref.read(adsSettingsProvider).showAds;
    final itemCount = feedItemCount(
      postCount: feed.postIds.length,
      postsPerAd: AdsConfig.homePostsPerAd,
      showAds: showAds,
    );
    if (itemCount == 0) return;

    var avgH = memoryPolicy.averageHeight(fallback: 0);
    if (avgH <= 0) {
      avgH = 360.0;
      var samples = 0;
      for (final id in feed.postIds.take(8)) {
        final vm = ref.read(postCardVmProvider(id));
        if (vm != null) {
          avgH += vm.estimatedHeight;
          samples++;
        }
      }
      if (samples > 0) avgH = avgH / (samples + 1);
    }

    idlePrecache.preloadStillUrls(
      context: context,
      itemCount: itemCount,
      stillUrlAt: (listIndex) {
        if (isFeedAdAt(
          index: listIndex,
          postCount: feed.postIds.length,
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
        if (postIndex < 0 || postIndex >= feed.postIds.length) return null;
        final id = feed.postIds[postIndex];
        if (postsById[id] == null) return null;
        final vm = ref.read(postCardVmProvider(id));
        if (vm == null || !vm.hasMedia) return null;
        final first = vm.firstMedia!;
        if (first.isImage) return first.url;
        final thumb = first.thumbnailUrl;
        return (thumb != null && thumb.isNotEmpty) ? thumb : null;
      },
      scrollPixels: pos.pixels,
      viewportHeight: pos.viewportDimension,
      averageRowHeight: avgH,
      isFlinging: false,
    );
  }
}
