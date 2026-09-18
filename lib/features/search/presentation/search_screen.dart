import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/search/data/search_repository_impl.dart';
import 'package:bluerum/features/search/domain/run_search.dart';
import 'package:bluerum/features/search/presentation/search_discover_view.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/shared/models/search.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/post_list/post_list.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/list/list_index_map.dart';
import 'package:bluerum/shared/widgets/media/comment_list_still_thumb.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';
import 'package:bluerum/features/post/presentation/comment_body_paint.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/post_detail_screen.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/features/shell/presentation/shell_chrome.dart';
import 'package:bluerum/core/utils/markdown_utils.dart';

// Search design system — matched to feed / profile / inbox / chat:
// Spacing: 4 micro · 8 section · 12 shell-Y · 16 shell-X
// Type: 10 label · 12 meta · 13 body · 16 title
// Color: #000 primary · #525252 meta · #E8E8E8 surface · #F5F6F8 field
const Color _kAccent = AppColors.accent;
const Color _kTextPrimary = AppColors.textPrimary;
const Color _kTextSecondary = Color(0xFF525252);
const Color _kSurfaceMuted = Color(0xFFE8E8E8);
/// Search field / filter chip — soft cool wash (not heavy mid-gray).
const Color _kSearchFieldBg = Color(0xFFF5F6F8);
/// Same hairline as post action pills (`#E0E0E0`).
const Color _kSearchFieldBorder = Color(0xFFE0E0E0);

class SearchScreen extends ConsumerStatefulWidget {
  final int? communityId;
  final String? instanceUrl;

  const SearchScreen({super.key, this.communityId, this.instanceUrl});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  late final AuthService _auth;
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  String _query = '';
  String _currentSort = 'TopAll'; // TopAll, Controversial, New, Old
  String _currentListingType = 'All'; // All, Subscribed, Local

  // Styling constants — same as file-level search design system
  static const Color accent = _kAccent;
  static const Color textPrimary = _kTextPrimary;
  static const Color textSecondary = _kTextSecondary;

  /// Community-scoped search: only content types Lemmy can filter with community_id.
  /// Tabs: All / Posts / Comments (no Communities, no Users).
  bool get _isCommunityScoped => widget.communityId != null;

  /// Global: All / Posts / Communities / Comments / Users
  /// Community: All / Posts / Comments
  int get _tabCount => _isCommunityScoped ? 3 : 5;

  int get _postsTabIndex => 1;
  int get _communitiesTabIndex => 2; // global only
  int get _commentsTabIndex => _isCommunityScoped ? 2 : 3;
  int get _usersTabIndex => 4; // global only

  /// Listing type (All/Local/Subscribed) is meaningless once scoped to one community.
  String get _effectiveListingType =>
      _isCommunityScoped ? 'All' : _currentListingType;

  @override
  void initState() {
    super.initState();
    _auth = ref.read(authRepositoryProvider);
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth.addListener(_onAuthChanged);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    try {
      _auth.removeListener(_onAuthChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    final text = _searchCtrl.text.trim();
    if (_tabController.indexIsChanging) {
      if (text.isNotEmpty && text != _query) {
        _query = text;
      }
    }
    setState(() {});
  }

  void _onAuthChanged() {
    if (!mounted) return;
    // Guest cannot use Subscribed listing — reset like home feed.
    if (!_auth.isLoggedIn && _currentListingType == 'Subscribed') {
      setState(() => _currentListingType = 'All');
    }
    // Shared client is kept in sync by providers; just refresh results.
    _triggerSearch();
  }

  void _triggerSearch() {
    final queryText = _searchCtrl.text.trim();
    if (queryText.isEmpty) return;
    setState(() {
      _query = queryText;
    });
  }

  /// Leave results and return to discover. Always re-show the shell tab bar —
  /// scroll-hide can leave [ShellChrome.hidePixels] at full hide with no
  /// scroll-to-top notification after the list is swapped out.
  void _clearSearch() {
    _searchCtrl.clear();
    ShellChrome.instance.resetHide();
    if (!mounted) return;
    setState(() {
      _query = '';
    });
  }

  // ── Dropdown sheet options ──

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SearchFilterBottomSheet(
        initialSort: _currentSort,
        initialListingType: _currentListingType,
        showListingType: !_isCommunityScoped,
        isLoggedIn: _auth.isLoggedIn,
        onSortChanged: (sort) {
          setState(() => _currentSort = sort);
          _triggerSearch();
        },
        onListingTypeChanged: (type) {
          if (type == 'Subscribed' && !_auth.isLoggedIn) return;
          setState(() => _currentListingType = type);
          _triggerSearch();
        },
        textPrimary: textPrimary,
      ),
    );
  }

  // ── Unified Search Bar ──

  Widget _buildSearchBar() {
    // Soft field wash + pill border; full secondary icons (no fade) so the
    // bar reads active — not disabled. Hint stays slightly softer.
    const fieldRadius = BorderRadius.all(Radius.circular(30));
    const enabledBorder = OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: _kSearchFieldBorder, width: 1),
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: AppColors.action, width: 1.5),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          if (widget.communityId != null) ...[
            IconButton(
              icon: const Icon(
                MingCuteIcons.mgc_left_line,
                size: 24,
                color: textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) {
                HapticFeedback.lightImpact();
                _triggerSearch();
              },
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: textPrimary),
              cursorColor: AppColors.action,
              decoration: InputDecoration(
                hintText: widget.communityId != null
                    ? 'Search in community...'
                    : 'Search posts, communities, users...',
                hintStyle: TextStyle(
                  color: textSecondary.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  MingCuteIcons.mgc_search_2_line,
                  size: 18,
                  color: textSecondary,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchCtrl,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              MingCuteIcons.mgc_close_line,
                              size: 16,
                              color: textSecondary,
                            ),
                            onPressed: _clearSearch,
                          )
                        : const SizedBox.shrink();
                  },
                ),
                filled: true,
                fillColor: _kSearchFieldBg,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: enabledBorder,
                enabledBorder: enabledBorder,
                focusedBorder: focusedBorder,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              MingCuteIcons.mgc_settings_2_line,
              size: 20,
              color: textSecondary,
            ),
            onPressed: _showFilterBottomSheet,
            style: IconButton.styleFrom(
              backgroundColor: _kSearchFieldBg,
              side: const BorderSide(color: _kSearchFieldBorder, width: 1),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialEmptyState() {
    if (_isCommunityScoped) {
      return const Align(
        alignment: Alignment(0.0, -0.2),
        child: Text(
          'Search in this community',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      );
    }
    // Global search: community discovery (Popular + Your communities).
    return SearchDiscoverView(api: _api, authService: _auth);
  }

  @override
  Widget build(BuildContext context) {
    final showTabs = _query.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Search Bar Header
            _buildSearchBar(),
            // 2. TabBar — only after the user has searched
            if (showTabs)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: accent,
                  unselectedLabelColor: textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    const Tab(text: 'All'),
                    const Tab(text: 'Posts'),
                    if (!_isCommunityScoped) const Tab(text: 'Communities'),
                    const Tab(text: 'Comments'),
                    if (!_isCommunityScoped) const Tab(text: 'Users'),
                  ],
                ),
              ),
            // 3. Body contents
            Expanded(
              child: _query.isEmpty
                  ? _buildInitialEmptyState()
                  : TabBarView(
                      controller: _tabController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Managed strictly by TabBar clicks
                      children: [
                        SearchAllTab(
                          api: _api,
                          authService: _auth,
                          key: const PageStorageKey('search_all_tab'),
                          query: _query,
                          sort: _currentSort,
                          listingType: _effectiveListingType,
                          communityId: widget.communityId,
                          postsTabIndex: _postsTabIndex,
                          commentsTabIndex: _commentsTabIndex,
                          communitiesTabIndex: _isCommunityScoped
                              ? null
                              : _communitiesTabIndex,
                          onTabChangeRequested: (index) {
                            _tabController.animateTo(index);
                          },
                          isActive: _tabController.index == 0,
                        ),
                        SearchTabList(
                          key: const PageStorageKey('search_posts_tab'),
                          api: _api,
                          authService: _auth,
                          query: _query,
                          type: 'Posts',
                          sort: _currentSort,
                          listingType: _effectiveListingType,
                          communityId: widget.communityId,
                          isActive: _tabController.index == _postsTabIndex,
                        ),
                        if (!_isCommunityScoped)
                          SearchTabList(
                            key: const PageStorageKey('search_communities_tab'),
                            api: _api,
                            authService: _auth,
                            query: _query,
                            type: 'Communities',
                            sort: _currentSort,
                            listingType: _effectiveListingType,
                            communityId: widget.communityId,
                            isActive:
                                _tabController.index == _communitiesTabIndex,
                          ),
                        SearchTabList(
                          key: const PageStorageKey('search_comments_tab'),
                          api: _api,
                          authService: _auth,
                          query: _query,
                          type: 'Comments',
                          sort: _currentSort,
                          listingType: _effectiveListingType,
                          communityId: widget.communityId,
                          isActive: _tabController.index == _commentsTabIndex,
                        ),
                        if (!_isCommunityScoped)
                          SearchTabList(
                            key: const PageStorageKey('search_users_tab'),
                            api: _api,
                            authService: _auth,
                            query: _query,
                            type: 'Users',
                            sort: _currentSort,
                            listingType: _effectiveListingType,
                            communityId: widget.communityId,
                            isActive: _tabController.index == _usersTabIndex,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Unified "All" tab - Fetches and displays Mixed results of first page
// ──────────────────────────────────────────────────────────────────────────────

abstract class SearchRowItem {}

class HeaderItem extends SearchRowItem {
  final String title;
  final int targetTab;
  HeaderItem(this.title, this.targetTab);
}

class CommunityItem extends SearchRowItem {
  final CommunityView community;
  CommunityItem(this.community);
}

class PostItem extends SearchRowItem {
  final PostView postView;
  PostItem(this.postView);
}

class CommentItem extends SearchRowItem {
  final CommentView comment;
  CommentItem(this.comment);
}

class SearchAllTab extends ConsumerStatefulWidget {
  final String query;
  final String sort;
  final String listingType;
  final LemmyApiService api;
  final AuthService? authService;
  final int? communityId;

  /// Tab indices for "See all". Null communitiesTabIndex hides Communities section.
  final int postsTabIndex;
  final int commentsTabIndex;
  final int? communitiesTabIndex;
  final ValueChanged<int> onTabChangeRequested;
  final bool isActive;

  const SearchAllTab({
    super.key,
    required this.query,
    required this.sort,
    required this.listingType,
    required this.api,
    this.authService,
    this.communityId,
    this.postsTabIndex = 1,
    this.commentsTabIndex = 3,
    this.communitiesTabIndex = 2,
    required this.onTabChangeRequested,
    required this.isActive,
  });

  @override
  ConsumerState<SearchAllTab> createState() => _SearchAllTabState();
}

class _SearchAllTabState extends ConsumerState<SearchAllTab>
    with AutomaticKeepAliveClientMixin {
  SearchResult? _result;
  bool _isLoading = false;
  String? _error;
  final PostListVmCache _vmCache = PostListVmCache();
  /// Pure virtualization (Home parity).
  final PostListMemoryPolicy _memoryPolicy = PostListMemoryPolicy();
  final PostListIdlePrecache _idlePrecache = PostListIdlePrecache();
  /// Separate from posts so shared [_lastPreloadedVisibleIndex] cannot skip
  /// comment still warm (profile parity).
  final PostListIdlePrecache _commentIdlePrecache = PostListIdlePrecache();
  final CommentBodyVmStore _commentBodyVms = CommentBodyVmStore();
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;
  ScrollMetrics? _lastScrollMetrics;

  String? _lastFetchedQuery;
  String? _lastFetchedSort;
  String? _lastFetchedListingType;
  LemmyApiService? _lastFetchedApi;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _phaseController.dispose();
    _scrollPhase.dispose();
    _memoryPolicy.clear();
    _idlePrecache.clear();
    _commentIdlePrecache.clear();
    _commentBodyVms.clear();
    _vmCache.clear();
    super.dispose();
  }

  void _onScrollPhaseChanged() {
    // Search All is page-1 only — no load-more. Warm posts/comments on idle.
    if (!mounted) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) return;
    final m = _lastScrollMetrics;
    if (m == null) return;
    final res = _result;
    if (res == null) return;
    if (res.posts.isNotEmpty) {
      _idlePrecache.preload(
        context: context,
        posts: [
          for (final p in res.posts) _resolvePost(p),
        ],
        scrollPixels: m.pixels,
        viewportHeight: m.viewportDimension,
        averageCardHeight: _memoryPolicy.averageHeight(),
        isFlinging: false,
      );
    }
    // All-tab comments are a short prefix (≤5) mixed with posts — warm all
    // stills without treating the mixed list as a pure comment index window.
    if (widget.communityId != null && res.comments.isNotEmpty) {
      final n = res.comments.length < 5 ? res.comments.length : 5;
      _commentIdlePrecache.preloadStillUrls(
        context: context,
        itemCount: n,
        stillUrlAt: (i) {
          final cv = res.comments[i];
          final vm = _commentBodyVms.obtain(
            commentId: cv.comment.id,
            content: cv.comment.content,
          );
          if (!vm.hasMedia) return null;
          return CommentListStillThumb.stillUrl(vm.media.first);
        },
        scrollPixels: 0,
        viewportHeight: 4000,
        averageRowHeight: CommentListStillThumb.height + 88,
        isFlinging: false,
      );
    }
  }

  void _warmCommentBodyVms(Iterable<CommentView> comments) {
    for (final cv in comments) {
      _commentBodyVms.obtain(
        commentId: cv.comment.id,
        content: cv.comment.content,
      );
    }
  }

  bool get _needsFetch {
    final q = widget.query.trim();
    if (q.isEmpty) return false;
    return q != (_lastFetchedQuery ?? '') ||
        widget.sort != _lastFetchedSort ||
        widget.listingType != _lastFetchedListingType ||
        widget.api != _lastFetchedApi;
  }

  @override
  void initState() {
    super.initState();
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    // Mark loading before the first frame when we will fetch — never paint
    // "No results found" while the request has not even started.
    if (widget.isActive && widget.query.trim().isNotEmpty) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetch();
      });
    }
  }

  @override
  void didUpdateWidget(SearchAllTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && _needsFetch) {
      // Sync flag so this build already shows skeleton (setState alone would
      // leave one empty frame when the parent just set a new query).
      if (!_isLoading || _result != null) {
        _isLoading = true;
        _error = null;
        _result = null;
        _commentBodyVms.clear();
        _idlePrecache.clear();
        _commentIdlePrecache.clear();
      }
      _fetch();
    }
  }

  Future<void> _fetch() async {
    if (widget.query.trim().isEmpty) return;
    final fetchQuery = widget.query;
    final fetchSort = widget.sort;
    final fetchListingType = widget.listingType;
    final fetchApi = widget.api;
    final canKeepExisting =
        _result != null &&
        fetchQuery == _lastFetchedQuery &&
        fetchSort == _lastFetchedSort &&
        fetchListingType == _lastFetchedListingType &&
        fetchApi == _lastFetchedApi;

    if (mounted) {
      setState(() {
        _isLoading = !canKeepExisting;
        _error = null;
        if (!canKeepExisting) _result = null;
      });
    } else {
      _isLoading = !canKeepExisting;
      _error = null;
      if (!canKeepExisting) _result = null;
    }
    try {
      final res = await runSearch(
        ref.read(searchRepositoryProvider),
        query: fetchQuery,
        type: 'All',
        sort: fetchSort,
        listingType: fetchListingType,
        page: 1,
        limit: 20,
        communityId: widget.communityId,
      );
      if (mounted) {
        if (fetchQuery != widget.query ||
            fetchSort != widget.sort ||
            fetchListingType != widget.listingType ||
            fetchApi != widget.api)
          return;
        _postBaseById
          ..clear()
          ..addEntries(res.posts.map((p) => MapEntry(p.post.id, p)));
        _commentBodyVms.clear();
        _idlePrecache.clear();
        _commentIdlePrecache.clear();
        if (widget.communityId != null) {
          _warmCommentBodyVms(res.comments.take(5));
        }
        setState(() {
          _result = res;
          _isLoading = false;
          _lastFetchedQuery = fetchQuery;
          _lastFetchedSort = fetchSort;
          _lastFetchedListingType = fetchListingType;
          _lastFetchedApi = fetchApi;
        });
      }
    } catch (e) {
      if (mounted) {
        if (fetchQuery != widget.query ||
            fetchSort != widget.sort ||
            fetchListingType != widget.listingType ||
            fetchApi != widget.api)
          return;
        setState(() {
          _isLoading = false;
          _error = canKeepExisting ? null : formatError(e);
        });
      }
    }
  }

  /// Silent base entity patches (SearchResult posts list is freezed/immutable).
  final Map<int, PostView> _postBaseById = <int, PostView>{};

  void _upsertPostSilent(PostView updated) {
    _postBaseById[updated.post.id] = updated;
  }

  PostView _resolvePost(PostView pv) => _postBaseById[pv.post.id] ?? pv;

  Future<void> _toggleUpvote(PostView pv) async {
    if (!(widget.authService?.isLoggedIn ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to vote')));
      return;
    }
    await toggleSurfacePostUpvote(ref, _resolvePost(pv), onUpdated: _upsertPostSilent);
  }

  Future<void> _toggleDownvote(PostView pv) async {
    if (!(widget.authService?.isLoggedIn ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to vote')));
      return;
    }
    await toggleSurfacePostDownvote(ref, _resolvePost(pv), onUpdated: _upsertPostSilent);
  }

  Future<void> _toggleSave(PostView pv) async {
    if (!(widget.authService?.isLoggedIn ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to save posts')));
      return;
    }
    await toggleSurfacePostSave(ref, _resolvePost(pv), onUpdated: _upsertPostSilent);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep state alive

    final communityScoped = widget.communityId != null;
    final hideCommunities =
        communityScoped || widget.communitiesTabIndex == null;

    // Pending first fetch counts as loading (avoids empty-text flash).
    if (_isLoading ||
        (_result == null && widget.query.trim().isNotEmpty && _error == null)) {
      return ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          if (communityScoped) {
            if (index < 2) return const _ShimmerPostRow();
            return const _ShimmerCommentRow();
          }
          if (!hideCommunities && index == 0)
            return const _ShimmerCommunityRow();
          if (index == (hideCommunities ? 0 : 1))
            return const _ShimmerUserRow();
          return const _ShimmerPostRow();
        },
      );
    }

    if (_error != null) {
      return _buildErrorState(context);
    }

    final res = _result;
    if (res == null) return const SizedBox.shrink();

    final hasCommunities = !hideCommunities && res.communities.isNotEmpty;
    final hasPosts = res.posts.isNotEmpty;
    // Comments only in community-scoped All (global All keeps communities + posts).
    final hasComments = communityScoped && res.comments.isNotEmpty;

    if (!hasCommunities && !hasPosts && !hasComments) {
      return _buildEmptyState(context);
    }

    final items = <SearchRowItem>[];
    if (hasCommunities) {
      items.add(HeaderItem('Communities', widget.communitiesTabIndex!));
      for (final c in res.communities.take(3)) {
        items.add(CommunityItem(c));
      }
    }
    if (hasPosts) {
      items.add(HeaderItem('Posts', widget.postsTabIndex));
      for (final p in res.posts) {
        items.add(PostItem(p));
      }
    }
    if (hasComments) {
      items.add(HeaderItem('Comments', widget.commentsTabIndex));
      for (final c in res.comments.take(5)) {
        items.add(CommentItem(c));
      }
    }

    final bottomInset =
        ShellChrome.chromeHeight + MediaQuery.paddingOf(context).bottom;

    final keys = <Object>[
      for (final item in items)
        if (item is HeaderItem)
          'hdr_${item.title}'
        else if (item is CommunityItem)
          'comm_${item.community.community.id}'
        else if (item is PostItem)
          item.postView.post.id
        else if (item is CommentItem)
          'cmt_${item.comment.comment.id}'
        else
          'row_${items.indexOf(item)}',
    ];
    final indexMap = PostListIndexMap.fromKeyedEntries(keys);

    return RefreshIndicator(
      color: _kAccent,
      onRefresh: () => runWithMediaBudgetRecovery(
        _fetch,
        isMounted: () => mounted,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _lastScrollMetrics = n.metrics;
          _phaseController.onNotification(n);
          // Media warm on phase → idle via [_onScrollPhaseChanged].
          return false;
        },
        child: ListView.builder(
        padding: EdgeInsets.only(bottom: bottomInset),
        cacheExtent: PostListMemoryPolicy.secondaryCacheExtent,
        itemCount: items.length,
        addAutomaticKeepAlives: false,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey) return indexMap.indexForKeyValue(key.value);
          return null;
        },
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is HeaderItem) {
            return KeyedSubtree(
              key: ValueKey('hdr_${item.title}'),
              child: _buildSectionHeader(item.title, item.targetTab),
            );
          } else if (item is CommunityItem) {
            return _CommunitySearchRow(
              key: ValueKey('comm_${item.community.community.id}'),
              communityView: item.community,
            );
          } else if (item is PostItem) {
            final pv = _resolvePost(item.postView);
            return OptimizedPostListTile(
              key: ValueKey(pv.post.id),
              postView: pv,
              vmCache: _vmCache,
              memoryPolicy: _memoryPolicy,
              onOpen: (p) {
                Navigator.of(context).push(
                  postDetailRoute(
                    builder: (_) => PostDetailScreen(
                      postView: p,
                      onUpvote: () async {
                        await _toggleUpvote(p);
                        return true;
                      },
                      onDownvote: () async {
                        await _toggleDownvote(p);
                        return true;
                      },
                      onSave: () async {
                        await _toggleSave(p);
                        return true;
                      },
                    ),
                  ),
                );
              },
              onUpvote: _toggleUpvote,
              onDownvote: _toggleDownvote,
              onSave: _toggleSave,
            );
          } else if (item is CommentItem) {
            final cv = item.comment;
            final bodyVm = _commentBodyVms.obtain(
              commentId: cv.comment.id,
              content: cv.comment.content,
            );
            return _CommentSearchRow(
              key: ValueKey('cmt_${cv.comment.id}'),
              commentView: cv,
              bodyVm: bodyVm,
              api: widget.api,
              authService: widget.authService,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int tabTargetIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () => widget.onTabChangeRequested(tabTargetIndex),
            child: const Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kTextSecondary,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  MingCuteIcons.mgc_right_line,
                  size: 12,
                  color: _kTextSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Icon(
                  MingCuteIcons.mgc_wifi_off_line,
                  size: 48,
                  color: _kTextSecondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _error ?? 'Unknown error',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kTextPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Scrollable Paginated Tab List - Handles tabs 1 to 4 with clean scroll state
// ──────────────────────────────────────────────────────────────────────────────

class SearchTabList extends ConsumerStatefulWidget {
  final String query;
  final String type; // Posts, Communities, Comments, Users
  final String sort;
  final String listingType;
  final LemmyApiService api;
  final AuthService? authService;
  final int? communityId;
  final bool isActive;

  const SearchTabList({
    super.key,
    required this.query,
    required this.type,
    required this.sort,
    required this.listingType,
    required this.api,
    this.authService,
    this.communityId,
    required this.isActive,
  });

  @override
  ConsumerState<SearchTabList> createState() => _SearchTabListState();
}

class _SearchTabListState extends ConsumerState<SearchTabList>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  bool _pendingLoadMore = false;
  final PostListVmCache _vmCache = PostListVmCache();
  /// Pure virtualization (Home parity).
  final PostListMemoryPolicy _memoryPolicy = PostListMemoryPolicy();
  final PostListIdlePrecache _idlePrecache = PostListIdlePrecache();
  final CommentBodyVmStore _commentBodyVms = CommentBodyVmStore();
  PostListIndexMap? _postsIndexMap;
  List<int>? _postsIndexOrder;
  PostListIndexMap? _commentsIndexMap;
  List<int>? _commentsIndexOrder;
  /// O(1) recycle for Communities / Users (`ValueKey<int>`).
  ListIndexMap? _entityIndexMap;
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;
  Timer? _loadMoreDebounce;
  ScrollMetrics? _lastScrollMetrics;

  String? _lastFetchedQuery;
  String? _lastFetchedSort;
  String? _lastFetchedListingType;
  LemmyApiService? _lastFetchedApi;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    if (widget.isActive && widget.query.trim().isNotEmpty) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetch(isRefresh: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _loadMoreDebounce?.cancel();
    _phaseController.dispose();
    _scrollPhase.dispose();
    _memoryPolicy.clear();
    _idlePrecache.clear();
    _commentBodyVms.clear();
    _vmCache.clear();
    _entityIndexMap = null;
    if (widget.type == 'Communities') {
      _communityPlainDescCache.clear();
    }
    super.dispose();
  }

  void _rebuildEntityIndexMap() {
    if (widget.type == 'Communities') {
      _entityIndexMap = ListIndexMap.fromIds([
        for (final e in _items) (e as CommunityView).community.id,
      ]);
    } else if (widget.type == 'Users') {
      _entityIndexMap = ListIndexMap.fromIds([
        for (final e in _items) (e as PersonView).person.id,
      ]);
    } else {
      _entityIndexMap = null;
    }
  }

  void _onScrollPhaseChanged() {
    if (!mounted) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) return;
    if (_pendingLoadMore) {
      _pendingLoadMore = false;
      _requestLoadMoreDebounced();
    }
    final metrics = _lastScrollMetrics;
    if (metrics == null || _items.isEmpty) return;
    if (widget.type == 'Posts') {
      _tryIdlePrecachePosts(metrics);
    } else if (widget.type == 'Comments') {
      _tryIdlePrecacheComments(metrics);
    }
  }

  void _tryIdlePrecachePosts(ScrollMetrics metrics) {
    if (!mounted || _scrollPhase.value != FeedScrollPhase.idle) return;
    _idlePrecache.preload(
      context: context,
      posts: _items.cast<PostView>(),
      scrollPixels: metrics.pixels,
      viewportHeight: metrics.viewportDimension,
      averageCardHeight: _memoryPolicy.averageHeight(),
      isFlinging: false,
    );
  }

  void _tryIdlePrecacheComments(ScrollMetrics metrics) {
    if (!mounted || _scrollPhase.value != FeedScrollPhase.idle) return;
    if (_items.isEmpty) return;
    _idlePrecache.preloadStillUrls(
      context: context,
      itemCount: _items.length,
      stillUrlAt: (i) {
        final cv = _items[i] as CommentView;
        final vm = _commentBodyVms.obtain(
          commentId: cv.comment.id,
          content: cv.comment.content,
        );
        if (!vm.hasMedia) return null;
        return CommentListStillThumb.stillUrl(vm.media.first);
      },
      scrollPixels: metrics.pixels,
      viewportHeight: metrics.viewportDimension,
      averageRowHeight: CommentListStillThumb.height + 88,
      isFlinging: false,
    );
  }

  void _warmCommentBodyVms(Iterable<CommentView> comments) {
    for (final cv in comments) {
      _commentBodyVms.obtain(
        commentId: cv.comment.id,
        content: cv.comment.content,
      );
    }
  }

  void _requestLoadMoreDebounced() {
    _loadMoreDebounce?.cancel();
    _loadMoreDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_scrollPhase.value != FeedScrollPhase.idle) {
        _pendingLoadMore = true;
        return;
      }
      unawaited(_fetch(isRefresh: false));
    });
  }

  PostListIndexMap _postsIndexMapFor(List<int> ids) {
    if (_postsIndexMap != null &&
        _postsIndexOrder != null &&
        _postsIndexOrder!.length == ids.length) {
      var same = true;
      for (var i = 0; i < ids.length; i++) {
        if (_postsIndexOrder![i] != ids[i]) {
          same = false;
          break;
        }
      }
      if (same) return _postsIndexMap!;
    }
    _postsIndexOrder = List<int>.from(ids);
    _postsIndexMap = PostListIndexMap.fromPostIds(
      ids,
      footerSlots: _isLoadingMore ? 1 : 0,
    );
    return _postsIndexMap!;
  }

  PostListIndexMap _commentsIndexMapFor(List<int> ids) {
    if (_commentsIndexMap != null &&
        _commentsIndexOrder != null &&
        _commentsIndexOrder!.length == ids.length) {
      var same = true;
      for (var i = 0; i < ids.length; i++) {
        if (_commentsIndexOrder![i] != ids[i]) {
          same = false;
          break;
        }
      }
      if (same) return _commentsIndexMap!;
    }
    _commentsIndexOrder = List<int>.from(ids);
    _commentsIndexMap = PostListIndexMap.fromPostIds(
      ids,
      footerSlots: _isLoadingMore ? 1 : 0,
    );
    return _commentsIndexMap!;
  }

  bool get _needsFetch {
    final q = widget.query.trim();
    if (q.isEmpty) return false;
    return q != (_lastFetchedQuery ?? '') ||
        widget.sort != _lastFetchedSort ||
        widget.listingType != _lastFetchedListingType ||
        widget.api != _lastFetchedApi;
  }

  @override
  void didUpdateWidget(SearchTabList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && _needsFetch) {
      // Paint skeleton in this build — avoid empty → loading flash.
      if (!_isLoading || _items.isNotEmpty) {
        _isLoading = true;
        _error = null;
        _items = [];
        _currentPage = 1;
        _hasMore = true;
        if (widget.type == 'Comments') {
          _commentBodyVms.clear();
          _idlePrecache.clear();
        } else if (widget.type == 'Posts') {
          _idlePrecache.clear();
        }
      }
      _fetch(isRefresh: true);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    _lastScrollMetrics = notification.metrics;
    _phaseController.onNotification(notification);
    // Media warm on phase → idle via [_onScrollPhaseChanged].
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.maxScrollExtent <= 0) return false;
      if (metrics.pixels >= metrics.maxScrollExtent - 200) {
        if (!_isLoading && !_isLoadingMore && _hasMore) {
          if (_scrollPhase.value != FeedScrollPhase.idle) {
            _pendingLoadMore = true;
          } else {
            _requestLoadMoreDebounced();
          }
        }
      }
    }
    return false;
  }

  Future<void> _fetch({bool isRefresh = false}) async {
    if (widget.query.trim().isEmpty) return;
    final fetchQuery = widget.query;
    final fetchSort = widget.sort;
    final fetchListingType = widget.listingType;
    final fetchApi = widget.api;
    final canKeepExisting =
        isRefresh &&
        _items.isNotEmpty &&
        fetchQuery == _lastFetchedQuery &&
        fetchSort == _lastFetchedSort &&
        fetchListingType == _lastFetchedListingType &&
        fetchApi == _lastFetchedApi;

    if (isRefresh) {
      if (mounted) {
        setState(() {
          _isLoading = !canKeepExisting;
          _error = null;
          if (!canKeepExisting) _items = [];
          _currentPage = 1;
          _hasMore = true;
        });
      } else {
        _isLoading = !canKeepExisting;
        _error = null;
        if (!canKeepExisting) _items = [];
        _currentPage = 1;
        _hasMore = true;
      }
    } else {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
      if (_scrollPhase.value != FeedScrollPhase.idle) {
        _pendingLoadMore = true;
        return;
      }
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final results = await runSearch(
        ref.read(searchRepositoryProvider),
        query: fetchQuery,
        type: widget.type,
        sort: fetchSort,
        listingType: fetchListingType,
        page: _currentPage,
        limit: 20,
        communityId: widget.communityId,
      );

      if (mounted) {
        if (fetchQuery != widget.query ||
            fetchSort != widget.sort ||
            fetchListingType != widget.listingType ||
            fetchApi != widget.api)
          return;
        // Freezed SearchResponse lists are unmodifiable — always copy into a
        // growable list so load-more can append without UnsupportedError.
        List<dynamic> newItems = [];
        if (widget.type == 'Posts') {
          newItems = List<dynamic>.from(results.posts);
        } else if (widget.type == 'Communities') {
          newItems = List<dynamic>.from(results.communities);
        } else if (widget.type == 'Comments') {
          newItems = List<dynamic>.from(results.comments);
        } else if (widget.type == 'Users') {
          newItems = List<dynamic>.from(results.users);
        }

        final existingIds = <dynamic>{};
        var uniqueCount = newItems.length;
        List<dynamic> nextItems;
        if (isRefresh) {
          if (widget.type == 'Comments') {
            _commentBodyVms.clear();
            _idlePrecache.clear();
          } else if (widget.type == 'Posts') {
            _idlePrecache.clear();
          }
          nextItems = newItems;
          if (widget.type == 'Comments') {
            _warmCommentBodyVms(newItems.cast<CommentView>());
          }
        } else {
          // Remove duplicates; stop paging when a full page is all dups.
          List<dynamic> filtered = newItems;
          if (widget.type == 'Posts') {
            existingIds.addAll(_items.map((p) => (p as PostView).post.id));
            filtered = newItems
                .where((p) => existingIds.add((p as PostView).post.id))
                .toList();
          } else if (widget.type == 'Communities') {
            existingIds.addAll(
              _items.map((c) => (c as CommunityView).community.id),
            );
            filtered = newItems
                .where(
                  (c) => existingIds.add((c as CommunityView).community.id),
                )
                .toList();
          } else if (widget.type == 'Comments') {
            existingIds.addAll(
              _items.map((c) => (c as CommentView).comment.id),
            );
            filtered = newItems
                .where((c) => existingIds.add((c as CommentView).comment.id))
                .toList();
          } else if (widget.type == 'Users') {
            existingIds.addAll(
              _items.map((u) => (u as PersonView).person.id),
            );
            filtered = newItems
                .where((u) => existingIds.add((u as PersonView).person.id))
                .toList();
          }
          uniqueCount = filtered.length;
          nextItems = List<dynamic>.from(_items)..addAll(filtered);
          if (widget.type == 'Comments') {
            _warmCommentBodyVms(filtered.cast<CommentView>());
          }
        }

        final nextPage = _currentPage + 1;
        final nextHasMore =
            newItems.length >= 20 && (isRefresh || uniqueCount > 0);

        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _items = nextItems;
          _rebuildEntityIndexMap();
          if (isRefresh) {
            _lastFetchedQuery = fetchQuery;
            _lastFetchedSort = fetchSort;
            _lastFetchedListingType = fetchListingType;
            _lastFetchedApi = fetchApi;
          }
          _currentPage = nextPage;
          _hasMore = nextHasMore;
        });
      }
    } catch (e) {
      if (mounted) {
        if (fetchQuery != widget.query ||
            fetchSort != widget.sort ||
            fetchListingType != widget.listingType ||
            fetchApi != widget.api)
          return;
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _error = canKeepExisting ? null : formatError(e);
        });
      }
    }
  }

  // ── Local Post Action states ──

  void _upsertPostSilent(PostView updated) {
    for (var i = 0; i < _items.length; i++) {
      final e = _items[i];
      if (e is PostView && e.post.id == updated.post.id) {
        _items[i] = updated;
        return;
      }
    }
  }

  Future<void> _toggleUpvote(PostView pv) async {
    if (!(widget.authService?.isLoggedIn ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to vote')));
      return;
    }
    await toggleSurfacePostUpvote(ref, pv, onUpdated: _upsertPostSilent);
  }

  Future<void> _toggleDownvote(PostView pv) async {
    if (!(widget.authService?.isLoggedIn ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to vote')));
      return;
    }
    await toggleSurfacePostDownvote(ref, pv, onUpdated: _upsertPostSilent);
  }

  Future<void> _toggleSave(PostView pv) async {
    if (!(widget.authService?.isLoggedIn ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to save posts')));
      return;
    }
    await toggleSurfacePostSave(ref, pv, onUpdated: _upsertPostSilent);
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Icon(
                  MingCuteIcons.mgc_wifi_off_line,
                  size: 48,
                  color: _kTextSecondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _error ?? 'Unknown error',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _fetch(isRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kTextPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSkeletons() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        if (widget.type == 'Posts') return const _ShimmerPostRow();
        if (widget.type == 'Communities') return const _ShimmerCommunityRow();
        if (widget.type == 'Comments') return const _ShimmerCommentRow();
        return const _ShimmerUserRow();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep state alive

    // Pending first fetch counts as loading (avoids empty-text flash).
    if (_isLoading ||
        (_items.isEmpty &&
            widget.query.trim().isNotEmpty &&
            _error == null &&
            _needsFetch)) {
      return _buildTabSkeletons();
    }

    if (_error != null) {
      return _buildErrorState(context);
    }

    if (_items.isEmpty) {
      return _buildEmptyState(context);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RefreshIndicator(
        color: _kAccent,
        onRefresh: () => runWithMediaBudgetRecovery(
          () => _fetch(isRefresh: true),
          isMounted: () => mounted,
        ),
        child: ListView.builder(
          padding: EdgeInsets.only(
            bottom: ShellChrome.chromeHeight +
                MediaQuery.paddingOf(context).bottom,
          ),
          // Avatar lists (Communities / Users): tight window = less ImageCache thrash.
          cacheExtent: widget.type == 'Posts'
              ? PostListMemoryPolicy.listCacheExtent
              : (widget.type == 'Communities' || widget.type == 'Users')
                  ? 240
                  : PostListMemoryPolicy.secondaryCacheExtent,
          itemCount: _items.length + (_isLoadingMore ? 1 : 0),
          // Fixed-height user rows: cheaper layout during fling.
          itemExtent: widget.type == 'Users' ? _kUserSearchRowExtent : null,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          findChildIndexCallback: widget.type == 'Posts'
              ? (Key key) {
                  if (key is! ValueKey) return null;
                  final ids = [
                    for (final e in _items) (e as PostView).post.id,
                  ];
                  return _postsIndexMapFor(ids).indexForKeyValue(key.value);
                }
              : widget.type == 'Comments'
                  ? (Key key) {
                      if (key is! ValueKey) return null;
                      final ids = [
                        for (final e in _items) (e as CommentView).comment.id,
                      ];
                      return _commentsIndexMapFor(ids)
                          .indexForKeyValue(key.value);
                    }
                  : (widget.type == 'Communities' || widget.type == 'Users')
                      ? (Key key) {
                          if (key is! ValueKey) return null;
                          return _entityIndexMap?.indexForKeyValue(key.value);
                        }
                      : null,
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: _kAccent,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }

            final item = _items[index];
            if (widget.type == 'Posts') {
              final pv = item as PostView;
              return OptimizedPostListTile(
                key: ValueKey(pv.post.id),
                postView: pv,
                vmCache: _vmCache,
                memoryPolicy: _memoryPolicy,
                onOpen: (p) {
                  Navigator.of(context).push(
                    postDetailRoute(
                      builder: (_) => PostDetailScreen(
                        postView: p,
                        onUpvote: () async {
                          await _toggleUpvote(p);
                          return true;
                        },
                        onDownvote: () async {
                          await _toggleDownvote(p);
                          return true;
                        },
                        onSave: () async {
                          await _toggleSave(p);
                          return true;
                        },
                      ),
                    ),
                  );
                },
                onUpvote: _toggleUpvote,
                onDownvote: _toggleDownvote,
                onSave: _toggleSave,
              );
            } else if (widget.type == 'Communities') {
              final cv = item as CommunityView;
              return KeyedSubtree(
                key: ValueKey<int>(cv.community.id),
                child: _CommunitySearchRow(communityView: cv),
              );
            } else if (widget.type == 'Comments') {
              final cv = item as CommentView;
              final bodyVm = _commentBodyVms.obtain(
                commentId: cv.comment.id,
                content: cv.comment.content,
              );
              return RepaintBoundary(
                key: ValueKey(cv.comment.id),
                child: _CommentSearchRow(
                  commentView: cv,
                  bodyVm: bodyVm,
                  api: widget.api,
                  authService: widget.authService,
                ),
              );
            } else {
              // Users tab
              final pv = item as PersonView;
              return KeyedSubtree(
                key: ValueKey<int>(pv.person.id),
                child: _UserSearchRow(personView: pv),
              );
            }
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Row Rendering Components
// ──────────────────────────────────────────────────────────────────────────────

class _CommentSearchRow extends StatelessWidget {
  final CommentView commentView;
  final CommentBodyVm bodyVm;
  final LemmyApiService api;
  final AuthService? authService;

  const _CommentSearchRow({
    super.key,
    required this.commentView,
    required this.bodyVm,
    required this.api,
    this.authService,
  });

  static final _commentMarkdownStyle = MarkdownStyleSheet(
    p: const TextStyle(fontSize: 13, color: _kTextPrimary, height: 1.5),
    a: BluerumMarkdownStyles.link(fontSize: 13),
    code: BluerumMarkdownStyles.code(
      fontSize: 12,
      color: _kTextPrimary,
    ),
    codeblockDecoration: BluerumMarkdownStyles.codeblockDecoration,
    blockquoteDecoration: const RoundedBorderDecoration(
      color: _kSearchFieldBorder,
      width: 3,
      isHorizontal: false,
    ),
    blockquotePadding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
    horizontalRuleDecoration: const RoundedBorderDecoration(
      color: _kSearchFieldBorder,
      width: 2,
      isHorizontal: true,
    ),
  );

  String _timeAgo(String published) {
    try {
      final utcTime = DateTime.parse(published).toUtc();
      final diff = DateTime.now().toUtc().difference(utcTime);
      if (diff.inDays > 365) return '${diff.inDays ~/ 365}y';
      if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo';
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return 'just now';
    } catch (_) {
      return '';
    }
  }

  Widget _buildAvatar(double size) {
    final avatarUrl = commentView.creator.avatar;
    final name = commentView.creator.displayNameOrName;
    return NetworkAvatar.forList(
      size: size,
      imageUrl: avatarUrl,
      name: name,
      fallback: _buildLetterAvatar(name, size),
    );
  }

  Widget _buildLetterAvatar(String name, double size) {
    final trimmed = name.trim();
    String letter = '?';
    if (trimmed.isNotEmpty) {
      final first = trimmed.characters.first;
      letter = first.isNotEmpty ? first.toUpperCase() : '?';
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _kSurfaceMuted,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
            color: _kTextSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = commentView.comment;
    final timeStr = _timeAgo(c.published);
    final creatorName = commentView.creator.displayNameOrName;
    final postTitle = commentView.post.name;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        // Prefetch real PostView so score/comments/vote don't flash at 0.
        final PostView postView;
        try {
          postView = await api.getPost(commentView.post.id);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open post: ${formatError(e)}')),
          );
          return;
        }
        if (!context.mounted) return;
        await Navigator.of(context).push(
          postDetailRoute(
            builder: (_) =>
                PostDetailScreen(postView: postView, threadRoot: commentView),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Community & time first (same layout as profile)
            Text(
              'c/${commentView.community.name} · $timeStr',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _kTextSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 2. Post title (emphasized, dark)
            Text(
              postTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 3. Avatar + username, muted, below the post
            Row(
              children: [
                _buildAvatar(24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'u/$creatorName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 4. Body + still media — profile secondary-list kit (not raw markdown).
            if (c.deleted || c.removed)
              Text(
                c.deleted ? '[deleted]' : '[removed]',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _kTextSecondary,
                ),
              )
            else ...[
              if (bodyVm.hasText) ...[
                if (bodyVm.paintKind == CommentBodyPaintKind.fullRich)
                  Text(
                    bodyVm.listPlain.isNotEmpty
                        ? bodyVm.listPlain
                        : bodyVm.markdownSource.trim(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _kTextPrimary,
                      height: 1.5,
                    ),
                  )
                else
                  CommentBodyPaint(
                    vm: bodyVm,
                    styleSheet: _commentMarkdownStyle,
                    maxPlainLines: 4,
                    fontSize: 13,
                    height: 1.5,
                    color: _kTextPrimary,
                    onLinkTap: (href) {
                      if (href == null || href.isEmpty) return;
                      launchUrl(
                        Uri.parse(href),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
              ],
              if (bodyVm.hasMedia) ...[
                if (bodyVm.hasText) const SizedBox(height: 8),
                CommentListStillThumb(
                  media: bodyVm.media,
                  extraCount:
                      bodyVm.media.length > 1 ? bodyVm.media.length - 1 : 0,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Session memo: markdown→plain is too expensive to redo every scroll rebuild.
/// Capped — cleared on tab dispose / when over budget.
final Map<int, String> _communityPlainDescCache = <int, String>{};
const int _kCommunityPlainDescCacheMax = 200;

String _plainCommunityDesc(int communityId, String rawDesc) {
  final hit = _communityPlainDescCache[communityId];
  if (hit != null) return hit;
  if (_communityPlainDescCache.length >= _kCommunityPlainDescCacheMax) {
    _communityPlainDescCache.clear();
  }
  final plain = markdownToPlainText(rawDesc);
  _communityPlainDescCache[communityId] = plain;
  return plain;
}

class _CommunitySearchRow extends StatelessWidget {
  final CommunityView communityView;

  const _CommunitySearchRow({super.key, required this.communityView});

  @override
  Widget build(BuildContext context) {
    final community = communityView.community;
    final iconUrl = community.icon;
    final title = community.title;
    final name = community.name;
    final activeWeek = communityView.counts.usersActiveWeek;
    final rawDesc = community.description ?? '';
    final plainDesc =
        rawDesc.isEmpty ? '' : _plainCommunityDesc(community.id, rawDesc);
    return RepaintBoundary(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CommunityDetailScreen(
                communityId: community.id,
                communityName: community.name,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkAvatar.forList(
                size: 40,
                imageUrl: iconUrl,
                name: name,
                backgroundColor: _kSurfaceMuted,
                foregroundColor: _kTextSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _kTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'c/$name · $activeWeek active/wk',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (plainDesc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plainDesc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kTextSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fixed row height for Users list virtualization ([itemExtent]).
const double _kUserSearchRowExtent = 74;

class _UserSearchRow extends StatelessWidget {
  final PersonView personView;

  const _UserSearchRow({super.key, required this.personView});

  @override
  Widget build(BuildContext context) {
    final person = personView.person;
    final avatarUrl = person.avatar;
    final displayName = person.displayNameOrName;
    final username = person.name;
    final stats =
        '${personView.counts.postCount} posts · ${personView.counts.commentCount} comments';

    return RepaintBoundary(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // Profiles are public — do not gate on auth.
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                personId: person.id,
                username: person.name,
              ),
            ),
          );
        },
        child: SizedBox(
          height: _kUserSearchRowExtent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                NetworkAvatar.forList(
                  size: 38,
                  imageUrl: avatarUrl,
                  name: username,
                  backgroundColor: _kSurfaceMuted,
                  foregroundColor: _kTextSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'u/$username',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shimmer Skeletons — layout matches the real search rows / PostCard
// ──────────────────────────────────────────────────────────────────────────────

class _ShimmerPostRow extends StatelessWidget {
  const _ShimmerPostRow();

  @override
  Widget build(BuildContext context) {
    return const PostCardSkeleton();
  }
}

class _ShimmerCommentRow extends StatelessWidget {
  const _ShimmerCommentRow();

  @override
  Widget build(BuildContext context) {
    return const SearchCommentRowSkeleton();
  }
}

class _ShimmerCommunityRow extends StatelessWidget {
  const _ShimmerCommunityRow();

  @override
  Widget build(BuildContext context) {
    return const SearchCommunityRowSkeleton();
  }
}

class _ShimmerUserRow extends StatelessWidget {
  const _ShimmerUserRow();

  @override
  Widget build(BuildContext context) {
    return const SearchUserRowSkeleton();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Unified Search Filter Bottom Sheet (Aggregate of Listing type & Sort posts)
// ──────────────────────────────────────────────────────────────────────────────

class SearchFilterBottomSheet extends StatefulWidget {
  final String initialSort;
  final String initialListingType;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onListingTypeChanged;
  final Color textPrimary;

  /// Hidden when search is already scoped to one community.
  final bool showListingType;

  /// Subscribed listing requires an authenticated session.
  final bool isLoggedIn;

  const SearchFilterBottomSheet({
    super.key,
    required this.initialSort,
    required this.initialListingType,
    required this.onSortChanged,
    required this.onListingTypeChanged,
    required this.textPrimary,
    this.showListingType = true,
    this.isLoggedIn = false,
  });

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late String _selectedSort;
  late String _selectedListingType;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _selectedListingType = widget.initialListingType;
  }

  String _getSortFriendlyName(String sort) {
    switch (sort) {
      case 'TopAll':
        return 'Top All Time';
      case 'Controversial':
        return 'Controversial';
      case 'New':
        return 'New';
      case 'Old':
        return 'Old';
      default:
        return sort;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _kSurfaceMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Filters',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: widget.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (widget.showListingType) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              leading: Icon(
                MingCuteIcons.mgc_globe_line,
                color: widget.textPrimary,
              ),
              title: Text(
                'Listing type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: widget.textPrimary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedListingType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    MingCuteIcons.mgc_right_line,
                    size: 16,
                    color: _kTextSecondary,
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showListingSelector(context);
              },
            ),
          ],

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            leading: Icon(
              MingCuteIcons.mgc_filter_line,
              color: widget.textPrimary,
            ),
            title: Text(
              'Sort',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: widget.textPrimary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getSortFriendlyName(_selectedSort),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _kTextSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  MingCuteIcons.mgc_right_line,
                  size: 16,
                  color: _kTextSecondary,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showSortSelector(context);
            },
          ),
        ],
      ),
    );
  }

  void _showListingSelector(BuildContext context) {
    final options = ['All', if (widget.isLoggedIn) 'Subscribed', 'Local'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _kSurfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Listing type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.textPrimary,
                    ),
                  ),
                ),
              ),
              ...options.map((opt) {
                final sel = _selectedListingType == opt;
                return ListTile(
                  leading: Icon(
                    sel
                        ? MingCuteIcons.mgc_check_circle_fill
                        : MingCuteIcons.mgc_round_line,
                    size: 22,
                    color: widget.textPrimary,
                  ),
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: widget.textPrimary,
                    ),
                  ),
                  onTap: () {
                    widget.onListingTypeChanged(opt);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              if (!widget.isLoggedIn)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Log in to use Subscribed',
                      style: TextStyle(fontSize: 12, color: _kTextSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSelector(BuildContext context) {
    final options = ['TopAll', 'Controversial', 'New', 'Old'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _kSurfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.textPrimary,
                    ),
                  ),
                ),
              ),
              ...options.map((opt) {
                final sel = _selectedSort == opt;
                return ListTile(
                  leading: Icon(
                    sel
                        ? MingCuteIcons.mgc_check_circle_fill
                        : MingCuteIcons.mgc_round_line,
                    size: 22,
                    color: widget.textPrimary,
                  ),
                  title: Text(
                    _getSortFriendlyName(opt),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: widget.textPrimary,
                    ),
                  ),
                  onTap: () {
                    widget.onSortChanged(opt);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
