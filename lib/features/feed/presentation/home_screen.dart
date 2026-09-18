import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/features/post/presentation/post_detail_screen.dart';
import 'package:bluerum/features/shell/presentation/shell_chrome.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/auth/auth_action_gate.dart';
import 'package:bluerum/shared/widgets/filters/home_filter_bottom_sheet.dart';
import 'package:bluerum/shared/widgets/media/nav_perf_log.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_idle_precache.dart';
import 'package:bluerum/shared/widgets/post_list/surface_post_interactions.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

import 'feed_controller.dart';
import 'feed_list_index.dart';
import 'feed_list_memory.dart';
import 'feed_perf_log.dart';
import 'feed_scroll_phase.dart';
import 'home_feed_header.dart';
import 'home_feed_pagination.dart';
import 'home_feed_posts_sliver.dart';
import 'home_feed_viewport_coordinator.dart';
import 'post_interaction_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AuthService _auth;
  String? _activeAuthToken;
  late String _activeInstanceUrl;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late final AnimationController _titleAnimController;
  late final Animation<double> _titleScale;
  late final FeedScrollPhaseController _phaseController;
  late final HomeFeedViewportCoordinator _viewport;
  late final HomeFeedPagination _pagination;

  final FeedListMemoryPolicy _memoryPolicy = FeedListMemoryPolicy();
  final PostListIdlePrecache _idlePrecache = PostListIdlePrecache(
    maxCachedUrls: 40,
    ahead: 2,
  );

  FeedListIndexMap? _indexMap;
  List<int>? _indexMapPostIds;
  bool? _indexMapShowAds;

  Color _titleColorFrom = const Color(0xFF000000);
  Color _titleColorTo = const Color(0xFF000000);
  GetSiteResponse? _cachedSiteResponse;

  static const Color _accent = Color(0xFF000000);
  static const Color _textSecondary = Color(0xFF525252);

  Color get _currentTitleColor {
    final t = Curves.easeInOutCubic.transform(_titleAnimController.value);
    return Color.lerp(_titleColorFrom, _titleColorTo, t)!;
  }

  void _snapTitleColor(String type) {
    final color = homeTitleColorForType(type);
    _titleColorFrom = color;
    _titleColorTo = color;
    _titleAnimController.value = 0;
  }

  void _animateTitleForTypeChange(String newType) {
    final target = homeTitleColorForType(newType);
    _titleColorFrom = _currentTitleColor;
    _titleColorTo = target;
    _titleAnimController.forward(from: 0);
  }

  bool get _canUseSubscribed => feedCanUseSubscribed(_auth);

  @override
  void initState() {
    super.initState();
    FeedPerfLog.ensureAttached();
    NavPerfLog.ensureAttached();
    _auth = ref.read(authRepositoryProvider);
    _activeAuthToken = _auth.jwt;
    _activeInstanceUrl = _auth.activeInstanceUrl;
    // Home owns the global phase listenable so in-feed ads share idle/fling edges.
    _phaseController = FeedScrollPhaseController(
      listenable: feedScrollPhaseListenable,
    );
    _viewport = HomeFeedViewportCoordinator(
      scrollController: _scrollController,
      memoryPolicy: _memoryPolicy,
      idlePrecache: _idlePrecache,
      isMounted: () => mounted,
      setState: setState,
      refreshIndicatorKey: _refreshIndicatorKey,
    );
    _pagination = HomeFeedPagination(
      scrollController: _scrollController,
      memoryPolicy: _memoryPolicy,
      idlePrecache: _idlePrecache,
      phaseListenable: feedScrollPhaseListenable,
      isMounted: () => mounted,
      isBusy: () => _viewport.isBusy,
      suppressPrecache: () => _viewport.programmaticRefreshRunning,
    );
    _titleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _titleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.22)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.22, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),
    ]).animate(_titleAnimController);
    _scrollController.addListener(_onScroll);
    feedScrollPhaseListenable.addListener(_onScrollPhaseChanged);
    ShellChrome.instance.homeScrollAndRefresh.addListener(
      _onHomeScrollAndRefresh,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(feedControllerProvider.notifier).bootstrap(
              canUseSubscribed: _canUseSubscribed,
            ),
      );
      _snapTitleColor(ref.read(feedControllerProvider).type);
    });
    _auth.addListener(_onInstanceChanged);
  }

  void _onHomeScrollAndRefresh() {
    unawaited(
      _viewport.runProgrammaticPullRefresh(
        ref: ref,
        cancelLoadMore: _pagination.cancel,
      ),
    );
  }

  @override
  void dispose() {
    ShellChrome.instance.homeScrollAndRefresh.removeListener(
      _onHomeScrollAndRefresh,
    );
    feedScrollPhaseListenable.removeListener(_onScrollPhaseChanged);
    _pagination.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _titleAnimController.dispose();
    _phaseController.dispose();
    _memoryPolicy.clear();
    _idlePrecache.clear();
    _auth.removeListener(_onInstanceChanged);
    super.dispose();
  }

  void _onScrollPhaseChanged() {
    if (!mounted) return;
    _pagination.onScrollPhaseIdle(context, ref);
  }

  void _onScroll() {
    _pagination.onScroll(
      context,
      ref,
      onMetrics: _phaseController.onScrollMetrics,
    );
  }

  void _onInstanceChanged() {
    final newUrl = _auth.activeInstanceUrl;
    final newToken = _auth.jwt;
    if ((newUrl != _activeInstanceUrl || newToken != _activeAuthToken) &&
        mounted) {
      _activeInstanceUrl = newUrl;
      _activeAuthToken = newToken;
      if (!_canUseSubscribed &&
          ref.read(feedControllerProvider).type == 'Subscribed') {
        unawaited(
          ref.read(feedControllerProvider.notifier).demoteTypeIfNeeded('All'),
        );
        _animateTitleForTypeChange('All');
      }
      unawaited(ref.read(feedControllerProvider.notifier).load());
    }
  }

  void _changeSort(String newSort) {
    unawaited(
      _viewport.applyFeedFilter(
        ref: ref,
        cancelLoadMore: _pagination.cancel,
        onTypeAnimating: _animateTitleForTypeChange,
        sort: newSort,
        awaitSheetDismiss: true,
      ),
    );
  }

  void _changeType(String newType, {bool awaitSheetDismiss = true}) {
    if (newType == 'Subscribed' && !_canUseSubscribed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log in to view subscribed communities'),
          ),
        );
      }
      return;
    }
    unawaited(
      _viewport.applyFeedFilter(
        ref: ref,
        cancelLoadMore: _pagination.cancel,
        onTypeAnimating: _animateTitleForTypeChange,
        type: newType,
        awaitSheetDismiss: awaitSheetDismiss,
      ),
    );
  }

  void _onHorizontalFeedSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null || velocity.abs() < 280) return;
    final feed = ref.read(feedControllerProvider);
    if (feed.isLoading || _viewport.filterChangeRunning) return;

    final target = velocity < 0 ? 'All' : 'Subscribed';
    if (target == feed.type) return;

    unawaited(HapticFeedback.selectionClick());
    _changeType(target, awaitSheetDismiss: false);
  }

  void scrollToTop() => _viewport.scrollToTop();

  Future<bool> _toggleUpvote(PostView pv) async {
    if (!mounted) return false;
    if (!requireLogin(context, _auth, message: 'Log in to vote')) return false;
    final ok = await toggleSurfacePostUpvote(ref, pv);
    if (!ok && mounted) showActionFailedSnack(context, 'Vote failed');
    return ok;
  }

  Future<bool> _toggleDownvote(PostView pv) async {
    if (!mounted) return false;
    if (!requireLogin(context, _auth, message: 'Log in to vote')) return false;
    final ok = await toggleSurfacePostDownvote(ref, pv);
    if (!ok && mounted) showActionFailedSnack(context, 'Vote failed');
    return ok;
  }

  Future<bool> _toggleSave(PostView pv) async {
    if (!mounted) return false;
    if (!requireLogin(context, _auth, message: 'Log in to save posts')) {
      return false;
    }
    return toggleSurfacePostSave(ref, pv);
  }

  void _openPostDetail(PostView pv) {
    final id = pv.post.id;
    final voteOverlay = ref.read(postMyVoteOverlaysProvider)[id];
    final savedOverlay = ref.read(postSavedOverlaysProvider)[id];
    NavPerfLog.beginSession(
      'open_post',
      data: {
        'postId': id,
        'hasThumb': (pv.post.thumbnailUrl ?? '').isNotEmpty ||
            (pv.post.url ?? '').isNotEmpty,
      },
    );
    Navigator.of(context).push(
      postDetailRoute(
        builder: (_) => PostDetailScreen(
          postView: pv,
          initialVote: effectiveMyVote(pv, voteOverlay),
          initialSaved: effectiveSaved(pv, savedOverlay),
          onUpvote: () => _toggleUpvote(pv),
          onDownvote: () => _toggleDownvote(pv),
          onSave: () => _toggleSave(pv),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final feed = ref.read(feedControllerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeFilterBottomSheet(
        initialSort: feed.sort,
        initialType: feed.type,
        cachedSiteResponse: _cachedSiteResponse,
        onSiteResponseLoaded: (res) => _cachedSiteResponse = res,
        onSortChanged: _changeSort,
        onTypeChanged: _changeType,
      ),
    );
  }

  FeedListIndexMap _indexMapFor(List<int> postIds, bool showAds) {
    if (_indexMap != null &&
        identical(_indexMapPostIds, postIds) &&
        _indexMapShowAds == showAds) {
      return _indexMap!;
    }
    _indexMapPostIds = postIds;
    _indexMapShowAds = showAds;
    _indexMap = buildHomeFeedIndexMap(
      postIds: postIds,
      showAds: showAds,
      postsPerAd: AdsConfig.homePostsPerAd,
    );
    return _indexMap!;
  }

  int? _findChildIndex(Key key) {
    if (key is! ValueKey) return null;
    final feed = ref.read(feedControllerProvider);
    final showAds = ref.read(adsSettingsProvider).showAds;
    return _indexMapFor(feed.postIds, showAds).indexForKeyValue(key.value);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const headerHeight = ShellChrome.chromeHeight;
    final headerExtent = topInset + headerHeight;

    final postIds =
        ref.watch(feedControllerProvider.select((s) => s.postIds));
    final isLoading =
        ref.watch(feedControllerProvider.select((s) => s.isLoading));
    final error = ref.watch(feedControllerProvider.select((s) => s.error));
    final isLoadingMore =
        ref.watch(feedControllerProvider.select((s) => s.isLoadingMore));
    final loadMoreError =
        ref.watch(feedControllerProvider.select((s) => s.loadMoreError));

    ref.listen(feedControllerProvider.select((s) => s.postIds.length), (
      prev,
      next,
    ) {
      if (next > (prev ?? 0)) _pagination.scheduleDataBufferCheck(ref);
    });
    ref.listen(feedControllerProvider.select((s) => s.loadEpoch), (
      prev,
      next,
    ) {
      if (prev != null && prev != next) {
        final fullReload = ref.read(feedControllerProvider).isLoading;
        if (fullReload) _memoryPolicy.clear();
        _indexMap = null;
        _indexMapPostIds = null;
        _idlePrecache.clear();
        _pagination.pendingLoadMore = false;
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: _onHorizontalFeedSwipe,
            behavior: HitTestBehavior.opaque,
            child: NotificationListener<ScrollNotification>(
              onNotification: _phaseController.onNotification,
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () async {
                  unawaited(HapticFeedback.mediumImpact());
                  await runWithMediaBudgetRecovery(
                    () => ref.read(feedControllerProvider.notifier).refresh(),
                    isMounted: () => mounted,
                  );
                },
                color: _accent,
                edgeOffset: headerExtent,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: _viewport.lockScrollDuringJump
                      ? const AlwaysScrollableScrollPhysics(
                          parent: NeverScrollableScrollPhysics(),
                        )
                      : const AlwaysScrollableScrollPhysics(),
                  cacheExtent: _viewport.lockScrollDuringJump
                      ? 200.0
                      : FeedListMemoryPolicy.listCacheExtent,
                  slivers: [
                    ThemedHeaderSpacer(height: headerExtent),
                    if (isLoading && postIds.isEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => PostCardSkeleton(
                            showBodyPreview: index % 3 != 0,
                            showMedia: index % 2 == 0,
                          ),
                          childCount: 6,
                        ),
                      )
                    else if (error != null && postIds.isEmpty)
                      HomeFeedStatusSliver.error(
                        error: error.toString(),
                        onRetry: () => unawaited(
                          ref.read(feedControllerProvider.notifier).load(),
                        ),
                      )
                    else if (postIds.isEmpty)
                      HomeFeedStatusSliver.empty()
                    else
                      HomeFeedPostsSliver(
                        postIds: postIds,
                        memoryPolicy: _memoryPolicy,
                        indexMapFor: _indexMapFor,
                        findChildIndex: _findChildIndex,
                        onOpen: _openPostDetail,
                        onUpvote: _toggleUpvote,
                        onDownvote: _toggleDownvote,
                        onSave: _toggleSave,
                      ),
                    if (isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: _accent,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (loadMoreError != null && !isLoadingMore)
                      SpacedRetryFooter(
                        textSecondary: _textSecondary,
                        onRetry: () => unawaited(
                          ref.read(feedControllerProvider.notifier).loadMore(),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ),
          ),
          HomeFeedHeader(
            topInset: topInset,
            titleAnimController: _titleAnimController,
            titleScale: _titleScale,
            titleColor: _currentTitleColor,
            onTitleTap: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
    );
  }
}

/// Fixed top inset under the sliding chrome header.
class ThemedHeaderSpacer extends StatelessWidget {
  const ThemedHeaderSpacer({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: SizedBox(height: height));
  }
}

class SpacedRetryFooter extends StatelessWidget {
  const SpacedRetryFooter({
    super.key,
    required this.textSecondary,
    required this.onRetry,
  });

  final Color textSecondary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Text(
              'Could not load more posts',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            HomeFeedActionButton(label: 'Try again', onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
