import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/auth/presentation/login_screen.dart';
import 'package:bluerum/features/community/data/community_repository_impl.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/features/search/presentation/discover_community_vm.dart';
import 'package:bluerum/features/shell/presentation/shell_chrome.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

// Match search_screen design tokens.
const Color _kAccent = AppColors.accent;
const Color _kTextPrimary = AppColors.textPrimary;
const Color _kTextSecondary = Color(0xFF525252);
const Color _kSurfaceMuted = Color(0xFFE8E8E8);

/// Empty-query discovery: Popular communities + Your communities.
///
/// Architecture parity with home / post-list kit (adapted for horizontal
/// carousels):
/// - **Data**: list state isolated per section (Popular vs Subscribed)
/// - **List**: fixed column stride, pure virtualize, bounded cacheExtent
/// - **Row**: [DiscoverCommunityRowVm] (markdown once), join via provider select
/// - **Media**: [NetworkAvatar.deferWhileScrolling]
/// - **Load-more**: idle-only + 180ms debounce (not mid-fling setState)
class SearchDiscoverView extends StatefulWidget {
  final LemmyApiService api;
  final AuthService authService;

  const SearchDiscoverView({
    super.key,
    required this.api,
    required this.authService,
  });

  @override
  State<SearchDiscoverView> createState() => _SearchDiscoverViewState();
}

class _SearchDiscoverViewState extends State<SearchDiscoverView> {
  final GlobalKey<_DiscoverCarouselSectionState> _popularKey =
      GlobalKey<_DiscoverCarouselSectionState>();
  final GlobalKey<_DiscoverCarouselSectionState> _subscribedKey =
      GlobalKey<_DiscoverCarouselSectionState>();

  Future<void> _onRefresh() async {
    await runWithMediaBudgetRecovery(
      () => Future.wait([
        _popularKey.currentState?.reload() ?? Future<void>.value(),
        if (widget.authService.isLoggedIn)
          _subscribedKey.currentState?.reload() ?? Future<void>.value(),
      ]),
      isMounted: () => mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        ShellChrome.chromeHeight + MediaQuery.paddingOf(context).bottom;

    return RefreshIndicator(
      color: _kAccent,
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        // Outer list only holds two fixed sections — no heavy children here.
        cacheExtent: 0,
        padding: EdgeInsets.only(bottom: bottomInset),
        children: [
          _DiscoverCarouselSection(
            key: _popularKey,
            api: widget.api,
            authService: widget.authService,
            title: 'Popular communities',
            listingType: 'All',
            sort: 'TopAll',
            rowsPerColumn: 3,
            requireLogin: false,
            emptyMessage: 'No communities to show yet',
          ),
          _DiscoverCarouselSection(
            key: _subscribedKey,
            api: widget.api,
            authService: widget.authService,
            title: 'Your communities',
            listingType: 'Subscribed',
            sort: null,
            rowsPerColumn: 2,
            requireLogin: true,
            emptyMessage: 'You have not joined any communities yet',
          ),
        ],
      ),
    );
  }
}

/// One horizontal discover carousel with its own data + scroll phase.
class _DiscoverCarouselSection extends StatefulWidget {
  final LemmyApiService api;
  final AuthService authService;
  final String title;
  final String listingType;
  final String? sort;
  final int rowsPerColumn;
  final bool requireLogin;
  final String emptyMessage;

  const _DiscoverCarouselSection({
    super.key,
    required this.api,
    required this.authService,
    required this.title,
    required this.listingType,
    required this.sort,
    required this.rowsPerColumn,
    required this.requireLogin,
    required this.emptyMessage,
  });

  @override
  State<_DiscoverCarouselSection> createState() =>
      _DiscoverCarouselSectionState();
}

class _DiscoverCarouselSectionState extends State<_DiscoverCarouselSection> {
  static const int _pageSize = 12;
  static const Duration _loadMoreDebounce = Duration(milliseconds: 180);
  /// ~1.2 columns ahead — enough for smooth fling, not a decode stampede.
  static const double _cacheExtentFactor = 1.2;
  static const double _columnGap = 12;
  static const double _loadingFooterWidth = 56;

  final DiscoverCommunityVmCache _vmCache = DiscoverCommunityVmCache();
  final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;

  List<CommunityView> _items = [];
  List<List<CommunityView>> _columns = const [];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  bool _pendingLoadMore = false;
  Timer? _loadMoreDebounceTimer;
  bool _wasLoggedIn = false;
  /// Drops stale network responses after reset / dispose races.
  int _fetchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _wasLoggedIn = widget.authService.isLoggedIn;
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    _scrollController.addListener(_onScrollMetrics);
    widget.authService.addListener(_onAuthChanged);

    if (widget.requireLogin && !_wasLoggedIn) {
      _loading = false;
    } else {
      unawaited(_fetch(reset: true));
    }
  }

  @override
  void didUpdateWidget(covariant _DiscoverCarouselSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authService != widget.authService) {
      oldWidget.authService.removeListener(_onAuthChanged);
      widget.authService.addListener(_onAuthChanged);
      _wasLoggedIn = widget.authService.isLoggedIn;
    }
    if (oldWidget.api != widget.api) {
      unawaited(_fetch(reset: true));
    } else if (oldWidget.authService != widget.authService) {
      _syncLoginGate(force: true);
    }
  }

  @override
  void dispose() {
    widget.authService.removeListener(_onAuthChanged);
    _scrollController.removeListener(_onScrollMetrics);
    _scrollController.dispose();
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _loadMoreDebounceTimer?.cancel();
    _phaseController.dispose();
    _scrollPhase.dispose();
    _vmCache.clear();
    super.dispose();
  }

  Future<void> reload() => _fetch(reset: true);

  void _onAuthChanged() {
    if (!mounted) return;
    final loggedIn = widget.authService.isLoggedIn;
    if (loggedIn == _wasLoggedIn) return;
    _wasLoggedIn = loggedIn;
    _syncLoginGate(force: true);
  }

  void _syncLoginGate({required bool force}) {
    if (!widget.requireLogin) return;
    if (_wasLoggedIn) {
      if (force || _items.isEmpty) {
        setState(() => _loading = true);
        unawaited(_fetch(reset: true));
      }
    } else {
      _clearItems();
    }
  }

  void _clearItems() {
    _loadMoreDebounceTimer?.cancel();
    _pendingLoadMore = false;
    setState(() {
      _items = [];
      _columns = const [];
      _page = 1;
      _hasMore = true;
      _error = null;
      _loading = false;
      _loadingMore = false;
    });
    _vmCache.clear();
  }

  void _onScrollMetrics() {
    if (!_scrollController.hasClients) return;
    _phaseController.onScrollMetrics(_scrollController.position);
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      _requestLoadMore();
    }
  }

  void _onScrollPhaseChanged() {
    if (!mounted) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) return;
    if (_pendingLoadMore) {
      _pendingLoadMore = false;
      _requestLoadMoreDebounced();
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    _phaseController.onNotification(notification);
    return false;
  }

  void _requestLoadMore() {
    if (_loading || _loadingMore || !_hasMore) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) {
      _pendingLoadMore = true;
      return;
    }
    _requestLoadMoreDebounced();
  }

  void _requestLoadMoreDebounced() {
    _loadMoreDebounceTimer?.cancel();
    _loadMoreDebounceTimer = Timer(_loadMoreDebounce, () {
      if (!mounted) return;
      if (_scrollPhase.value != FeedScrollPhase.idle) {
        _pendingLoadMore = true;
        return;
      }
      unawaited(_fetch(reset: false));
    });
  }

  Future<void> _fetch({required bool reset}) async {
    if (!mounted) return;
    if (widget.requireLogin && !widget.authService.isLoggedIn) return;

    if (reset) {
      _fetchGeneration++;
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
        _loadingMore = false;
      });
      _pendingLoadMore = false;
      _loadMoreDebounceTimer?.cancel();
    } else {
      if (_loading || _loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final gen = _fetchGeneration;
    final page = reset ? 1 : _page;
    try {
      final list = await widget.api.listCommunities(
        type: widget.listingType,
        sort: widget.sort,
        page: page,
        limit: _pageSize,
      );
      if (!mounted || gen != _fetchGeneration) return;

      late final List<CommunityView> next;
      late final bool hasMore;
      if (reset) {
        next = list;
        hasMore = list.length >= _pageSize;
      } else {
        final seen = _items.map((c) => c.community.id).toSet();
        final unique = list.where((c) => seen.add(c.community.id)).toList();
        next = [..._items, ...unique];
        // Stop when the page is short or the server only returned dupes.
        hasMore = list.length >= _pageSize && unique.isNotEmpty;
      }

      // Warm VMs off the itemBuilder path (markdown once per new id).
      _vmCache.warm(next);
      _vmCache.retainOnly(next.map((c) => c.community.id).toSet());

      setState(() {
        _items = next;
        _columns = chunkDiscoverColumns(
          next,
          rowsPerColumn: widget.rowsPerColumn,
        );
        _page = page + 1;
        _hasMore = hasMore;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || gen != _fetchGeneration) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (reset || _items.isEmpty) {
          _error = formatError(e);
        }
      });
    }
  }

  double _columnWidth(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).width;
    return (screen * 0.82).clamp(260.0, 340.0);
  }

  @override
  Widget build(BuildContext context) {
    // Guest subscribed section: fixed-height login prompt.
    if (widget.requireLogin && !widget.authService.isLoggedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(widget.title),
          SizedBox(
            height: _DiscoverCommunityColumn.columnHeightFor(
              widget.rowsPerColumn,
            ),
            child: const _DiscoverLoginPrompt(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(widget.title),
        if (_loading && _items.isEmpty)
          _horizontalSkeleton(context)
        else if (_error != null && _items.isEmpty)
          _sectionError(_error!, () => unawaited(_fetch(reset: true)))
        else if (_items.isEmpty)
          _emptyMessage(widget.emptyMessage)
        else
          _buildCarousel(context),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _kTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _sectionError(String message, VoidCallback onRetry) {
    return SizedBox(
      height: _DiscoverCommunityColumn.columnHeightFor(widget.rowsPerColumn),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: _kTextSecondary),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: _kTextPrimary),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalSkeleton(BuildContext context) {
    final width = _columnWidth(context);
    final height =
        _DiscoverCommunityColumn.columnHeightFor(widget.rowsPerColumn);
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 2,
        itemExtent: width + _columnGap,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(right: _columnGap),
          child: _DiscoverCommunityColumnSkeleton(
            width: width,
            rowsPerColumn: widget.rowsPerColumn,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    final columnWidth = _columnWidth(context);
    final height =
        _DiscoverCommunityColumn.columnHeightFor(widget.rowsPerColumn);
    final dataCount = _columns.length;
    final count = dataCount + (_loadingMore ? 1 : 0);
    final stride = columnWidth + _columnGap;

    return SizedBox(
      height: height,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          // Fixed stride for data columns; footer is narrower.
          itemExtentBuilder: (index, _) {
            if (index >= dataCount) return _loadingFooterWidth;
            return stride;
          },
          cacheExtent: columnWidth * _cacheExtentFactor,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            if (index >= dataCount) {
              return SizedBox(
                width: _loadingFooterWidth,
                height: height,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
              );
            }

            final columnItems = _columns[index];
            final vms = [
              for (final cv in columnItems) _vmCache.vmFor(cv),
            ];

            return Padding(
              padding: const EdgeInsets.only(right: _columnGap),
              child: RepaintBoundary(
                child: _DiscoverCommunityColumn(
                  key: ValueKey('col_${widget.listingType}_$index'),
                  vms: vms,
                  width: columnWidth,
                  rowsPerColumn: widget.rowsPerColumn,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One horizontal page: stacked community rows (Reddit-style).
class _DiscoverCommunityColumn extends StatelessWidget {
  static const double rowHeight = 96;
  static double columnHeightFor(int rowsPerColumn) => rowHeight * rowsPerColumn;

  final List<DiscoverCommunityRowVm> vms;
  final double width;
  final int rowsPerColumn;

  const _DiscoverCommunityColumn({
    super.key,
    required this.vms,
    required this.width,
    this.rowsPerColumn = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: columnHeightFor(rowsPerColumn),
      child: Column(
        children: [
          for (var i = 0; i < rowsPerColumn; i++)
            if (i < vms.length)
              SizedBox(
                height: rowHeight,
                child: _DiscoverCommunityRow(
                  key: ValueKey(vms[i].id),
                  vm: vms[i],
                ),
              )
            else
              const SizedBox(height: rowHeight),
        ],
      ),
    );
  }
}

/// Single community row: avatar + precomputed info + Join pill.
class _DiscoverCommunityRow extends ConsumerStatefulWidget {
  final DiscoverCommunityRowVm vm;

  const _DiscoverCommunityRow({super.key, required this.vm});

  @override
  ConsumerState<_DiscoverCommunityRow> createState() =>
      _DiscoverCommunityRowState();
}

class _DiscoverCommunityRowState extends ConsumerState<_DiscoverCommunityRow> {
  bool _subscribing = false;
  bool _justSubscribed = false;

  bool _isAlreadySubscribed(String subscribed, int communityId) {
    if (_justSubscribed) return true;
    if (subscribed == 'Subscribed' || subscribed == 'Pending') return true;
    // Select only this id — unrelated joins must not rebuild this row.
    return ref.watch(
      sessionSubscribedCommunityIdsProvider.select(
        (s) => s.contains(communityId),
      ),
    );
  }

  Future<void> _subscribe() async {
    if (_subscribing) return;

    final auth = ref.read(authRepositoryProvider);
    if (!auth.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to subscribe to communities')),
      );
      return;
    }

    final vm = widget.vm;
    setState(() => _subscribing = true);

    try {
      await ref
          .read(communityRepositoryProvider)
          .follow(communityId: vm.id, follow: true);
      if (!mounted) return;
      ref.read(sessionSubscribedCommunityIdsProvider.notifier).add(vm.id);
      setState(() {
        _subscribing = false;
        _justSubscribed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscribed to c/${vm.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _subscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription failed: ${formatError(e)}')),
      );
    }
  }

  Widget _subscribePill({required bool isLoading, VoidCallback? onTap}) {
    return Semantics(
      button: true,
      label: 'Join community',
      child: Tooltip(
        message: 'Join community',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.action.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: AppColors.action.withValues(alpha: 0.28),
              ),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.action,
                    ),
                  )
                : const Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.action,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final showSubscribe = !_isAlreadySubscribed(vm.subscribed, vm.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommunityDetailScreen(
                        communityId: vm.id,
                        communityName: vm.name,
                      ),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NetworkAvatar.forList(
                      size: 44,
                      imageUrl: vm.hasIcon ? vm.iconUrl : null,
                      name: vm.name,
                      backgroundColor: _kSurfaceMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vm.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'c/${vm.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _kTextSecondary,
                            ),
                          ),
                          if (vm.hasDescription) ...[
                            const SizedBox(height: 4),
                            Text(
                              vm.descriptionPlain,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.25,
                                color: _kTextSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            vm.statsLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showSubscribe) ...[
            const SizedBox(width: 8),
            _subscribePill(
              isLoading: _subscribing,
              onTap: _subscribing ? null : _subscribe,
            ),
          ],
        ],
      ),
    );
  }
}

class _DiscoverCommunityColumnSkeleton extends StatelessWidget {
  final double width;
  final int rowsPerColumn;

  const _DiscoverCommunityColumnSkeleton({
    required this.width,
    this.rowsPerColumn = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _DiscoverCommunityColumn.columnHeightFor(rowsPerColumn),
      child: Column(
        children: List.generate(rowsPerColumn, (_) {
          return const SizedBox(
            height: _DiscoverCommunityColumn.rowHeight,
            child: DiscoverCommunityRowSkeleton(),
          );
        }),
      ),
    );
  }
}

/// Guest empty state under "Your communities".
class _DiscoverLoginPrompt extends StatelessWidget {
  const _DiscoverLoginPrompt();

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your communities are waiting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _openLogin(context),
              style: FilledButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(104, 36),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: const StadiumBorder(),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Log in',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
