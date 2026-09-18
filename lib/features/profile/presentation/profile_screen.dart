import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_bar_chrome.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/post_list/post_list.dart';
import 'package:bluerum/shared/widgets/media/full_screen_media_viewer.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/media/comment_list_still_thumb.dart';
import 'package:bluerum/shared/widgets/media/comment_media_widget.dart';
import 'package:bluerum/features/auth/presentation/login_screen.dart';
import 'package:bluerum/features/post/presentation/comment_body_paint.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/post_detail_screen.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/features/settings/presentation/settings_screen.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/features/chat/presentation/chat_detail_screen.dart';

// Profile design system — matched to feed PostCard / post-detail:
// Spacing: 4 micro · 8 section · 12 shell-Y · 16 shell-X
// Type: 10 label · 12 meta · 13 body · 16 title (18 hero name)
// Color: #000 primary · #525252 meta · #E0E0E0 border
const Color _accent = AppColors.accent;
const Color _cardBg = AppColors.card;
const Color _textPrimary = AppColors.textPrimary;
/// Meta secondary — same as PostCard / post-detail (not AppColors.textSecondary).
const Color _textSecondary = Color(0xFF525252);
const Color _borderLight = Color(0xFFE0E0E0);

class ProfileScreen extends ConsumerStatefulWidget {
  final String? instanceUrl;
  final int? personId;
  final String? username;

  const ProfileScreen({
    super.key,
    this.instanceUrl,
    this.personId,
    this.username,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  late final AuthService _auth;
  late final TabController _tabCtrl;

  PersonView? _personView;
  bool _isLoadingUser = true;
  String? _userError;

  final SurfacePostStore _postStore = SurfacePostStore();
  /// Pure virtualization (Home parity) — never pin full media cards off-screen.
  final PostListMemoryPolicy _memoryPolicy = PostListMemoryPolicy();
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;
  List<CommentView> _userComments = [];
  final CommentBodyVmStore _commentBodyVms = CommentBodyVmStore();
  PostListIndexMap? _commentsIndexMap;
  List<int>? _commentsIndexOrder;
  bool _isLoadingPosts = false;
  bool _isLoadingComments = false;
  /// False until the first posts/comments fetch finishes. Prevents the
  /// "No posts yet" empty state from flashing before loading starts.
  bool _postsFetchDone = false;
  bool _commentsFetchDone = false;
  bool _postsRequestInFlight = false;
  bool _commentsRequestInFlight = false;

  // Pagination & Sorting State
  int _postsPage = 1;
  int _commentsPage = 1;
  bool _hasMorePosts = true;
  bool _hasMoreComments = true;
  bool _isLoadingMorePosts = false;
  bool _isLoadingMoreComments = false;
  bool _pendingLoadMorePosts = false;
  final int _pageSize = 20;
  String _sortType = 'New';
  PostListIndexMap? _postsIndexMap;
  List<int>? _postsIndexOrder;
  Timer? _loadMorePostsDebounce;
  Timer? _loadMoreCommentsDebounce;

  String? _lastJwt;
  String? _lastInstanceUrl;

  // One pinned SliverPersistentHeader: text tabs → dots as it reaches pin.
  // ValueNotifier — morph does not setState the whole profile (posts/comments).
  late final ScrollController _scrollCtrl;
  final ValueNotifier<double> _morphT = ValueNotifier<double>(0.0);
  final PostListIdlePrecache _idlePrecache = PostListIdlePrecache();
  /// Separate from posts so tab switch does not skip comment still warm.
  final PostListIdlePrecache _commentIdlePrecache = PostListIdlePrecache();
  bool _pendingLoadMoreComments = false;

  /// Last inner-list metrics from posts/comments [ScrollNotification].
  /// Used when phase → idle (Home parity); do not warm on ScrollUpdate while
  /// [FeedScrollPhaseController] has already left idle.
  ScrollMetrics? _lastListScrollMetrics;
  /// Tab that produced [_lastListScrollMetrics] (0 posts, 1 comments).
  int? _lastListScrollTab;

  /// True only when the current finger-down began with the outer profile already
  /// parked at the absolute top. Used so fling/inertia (or drag-from-mid) cannot
  /// arm [RefreshIndicator] the way a deliberate pull-from-top does.
  bool _ptrGestureFromTop = false;

  /// Match [AppBarChrome.height] / post-detail toolbar (was 52).
  static const double _chromeHeight = AppBarChrome.height;

  @override
  void initState() {
    super.initState();
    _auth = ref.read(authRepositoryProvider);
    _tabCtrl = TabController(length: 2, vsync: this);
    _scrollCtrl = ScrollController()..addListener(_onOuterScroll);
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    _postStore.addListener(_onPostStoreChanged);

    _lastJwt = _auth.jwt;
    _lastInstanceUrl = _auth.activeInstanceUrl;

    _initSortPreference();

    // Public profiles can open by personId or username without being logged in.
    // JWT is owned by lemmyApiClientProvider — do not setAuthToken here.
    if (widget.personId != null ||
        widget.username != null ||
        _auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchUser();
      });
    } else {
      _isLoadingUser = false;
    }
    _auth.addListener(_onAuthChanged);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging || !mounted) return;
      // Mark the destination tab loading in the same frame we start the fetch
      // so NestedScrollView never paints "No … yet" for one frame.
      if (_personView != null) {
        if (_tabCtrl.index == 0 && !_postsFetchDone && !_isLoadingPosts) {
          setState(() => _isLoadingPosts = true);
        } else if (_tabCtrl.index == 1 &&
            !_commentsFetchDone &&
            !_isLoadingComments) {
          setState(() => _isLoadingComments = true);
        }
      }
      _fetchTabContent();
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _postStore.removeListener(_onPostStoreChanged);
    _loadMorePostsDebounce?.cancel();
    _loadMoreCommentsDebounce?.cancel();
    _phaseController.dispose();
    _scrollPhase.dispose();
    _memoryPolicy.clear();
    _idlePrecache.clear();
    _commentIdlePrecache.clear();
    _commentBodyVms.clear();
    _postStore.dispose();
    _morphT.dispose();
    _scrollCtrl.removeListener(_onOuterScroll);
    _scrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onPostStoreChanged() {
    if (mounted) setState(() {});
  }

  void _onScrollPhaseChanged() {
    if (!mounted) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) return;
    if (_personView == null) return;
    final pid = _personView!.person.id;
    // Idle: flush deferred load-more + warm media (never mid-fling) — Home parity.
    if (_pendingLoadMorePosts) {
      _pendingLoadMorePosts = false;
      _requestLoadMorePostsDebounced(pid);
    }
    if (_pendingLoadMoreComments) {
      _pendingLoadMoreComments = false;
      _requestLoadMoreCommentsDebounced(pid);
    }
    final metrics = _lastListScrollMetrics;
    final tab = _lastListScrollTab;
    if (metrics == null || tab == null || tab != _tabCtrl.index) return;
    if (tab == 0) {
      _tryIdlePrecache(metrics);
    } else if (tab == 1) {
      _tryIdlePrecacheComments(metrics);
    }
  }

  void _requestLoadMorePostsDebounced(int pid) {
    _loadMorePostsDebounce?.cancel();
    _loadMorePostsDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_scrollPhase.value != FeedScrollPhase.idle) {
        _pendingLoadMorePosts = true;
        return;
      }
      unawaited(_loadMorePosts(pid));
    });
  }

  void _requestLoadMoreCommentsDebounced(int pid) {
    _loadMoreCommentsDebounce?.cancel();
    _loadMoreCommentsDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_scrollPhase.value != FeedScrollPhase.idle) {
        _pendingLoadMoreComments = true;
        return;
      }
      unawaited(_loadMoreComments(pid));
    });
  }

  void _tryIdlePrecache(ScrollMetrics metrics) {
    // Home parity: only warm media when fully idle.
    if (!mounted || _scrollPhase.value != FeedScrollPhase.idle) return;
    _idlePrecache.preload(
      context: context,
      posts: _postStore.posts,
      scrollPixels: metrics.pixels,
      viewportHeight: metrics.viewportDimension,
      averageCardHeight: _memoryPolicy.averageHeight(),
      isFlinging: false,
    );
  }

  /// Still thumbs only (image URL / video poster) — never video decode.
  void _tryIdlePrecacheComments(ScrollMetrics metrics) {
    if (!mounted || _scrollPhase.value != FeedScrollPhase.idle) return;
    if (_userComments.isEmpty) return;
    _commentIdlePrecache.preloadStillUrls(
      context: context,
      itemCount: _userComments.length,
      stillUrlAt: (i) {
        final cv = _userComments[i];
        final vm = _commentBodyVms.obtain(
          commentId: cv.comment.id,
          content: cv.comment.content,
        );
        return _commentListStillUrl(vm);
      },
      scrollPixels: metrics.pixels,
      viewportHeight: metrics.viewportDimension,
      // Community row + title + optional text + fixed thumb — close enough for
      // ahead window (not measured like posts' [_memoryPolicy.averageHeight]).
      averageRowHeight: CommentListStillThumb.height + 88,
      isFlinging: false,
    );
  }

  /// Same still rule as paint ([CommentListStillThumb.stillUrl]).
  static String? _commentListStillUrl(CommentBodyVm vm) {
    if (!vm.hasMedia) return null;
    return CommentListStillThumb.stillUrl(vm.media.first);
  }

  void _warmCommentBodyVms(Iterable<CommentView> comments) {
    for (final cv in comments) {
      _commentBodyVms.obtain(
        commentId: cv.comment.id,
        content: cv.comment.content,
      );
    }
  }

  void _setUserComments(List<CommentView> comments) {
    _userComments = comments;
    _commentBodyVms.clear();
    _commentIdlePrecache.clear();
    _warmCommentBodyVms(comments);
    _commentsIndexMap = null;
    _commentsIndexOrder = null;
  }

  void _appendUserComments(List<CommentView> unique) {
    _userComments.addAll(unique);
    _warmCommentBodyVms(unique);
    _commentsIndexMap = null;
    _commentsIndexOrder = null;
  }

  PostListIndexMap _commentsIndexMapFor(List<CommentView> comments) {
    final ids = [for (final c in comments) c.comment.id];
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
    _commentsIndexOrder = ids;
    _commentsIndexMap = PostListIndexMap.fromPostIds(
      ids,
      footerSlots: _hasMoreComments ? 1 : 0,
    );
    return _commentsIndexMap!;
  }

  /// Scroll-linked morph on the *same* pinned bar.
  /// Outer maxScrollExtent == collapse of hero above the bar; at that point the
  /// bar is pinned. We fade text→dots over the last [_chromeHeight] of that
  /// collapse so the swap happens as it pins — not a second overlay later.
  void _onOuterScroll() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    double t = 0.0;
    if (pos.maxScrollExtent > 0) {
      final morphRange = _chromeHeight;
      final start =
          (pos.maxScrollExtent - morphRange).clamp(0.0, pos.maxScrollExtent);
      final span = (pos.maxScrollExtent - start).clamp(1.0, double.infinity);
      t = ((pos.pixels - start) / span).clamp(0.0, 1.0);
      t = Curves.easeInOut.transform(t);
    }
    if ((t - _morphT.value).abs() < 0.01) return;
    _morphT.value = t;
  }

  Future<void> _initSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _sortType = prefs.getString('bluerum_profile_sort') ?? 'New';
      });
    }
  }

  Future<void> _checkSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final newSort = prefs.getString('bluerum_profile_sort') ?? 'New';
    if (newSort != _sortType) {
      if (mounted) {
        setState(() {
          _sortType = newSort;
          _postStore.clear();
          _memoryPolicy.clear();
          _idlePrecache.clear();
          _setUserComments(const []);
          _postsFetchDone = false;
          _commentsFetchDone = false;
          _isLoadingPosts = true;
          _isLoadingComments = true;
          _pendingLoadMorePosts = false;
          _pendingLoadMoreComments = false;
        });
        _fetchTabContent();
      }
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final newUrl = _auth.activeInstanceUrl;
    final newJwt = _auth.jwt;

    if (newUrl != _lastInstanceUrl || newJwt != _lastJwt) {
      _lastInstanceUrl = newUrl;
      _lastJwt = newJwt;

      if (widget.personId != null || widget.username != null) {
        // Public profile: reload so block/message/follow UI matches session.
        _fetchUser();
        return;
      }
      if (_auth.isLoggedIn) {
        setState(() {
          _personView = null;
          _isLoadingUser = true;
          _userError = null;
          _postStore.clear();
          _memoryPolicy.clear();
          _setUserComments(const []);
          _postsFetchDone = false;
          _commentsFetchDone = false;
          _isLoadingPosts = false;
          _isLoadingComments = false;
          _postsPage = 1;
          _commentsPage = 1;
          _hasMorePosts = true;
          _hasMoreComments = true;
          _isLoadingMorePosts = false;
          _isLoadingMoreComments = false;
          _pendingLoadMorePosts = false;
        });
        _fetchUser();
      } else {
        setState(() {
          _personView = null;
          _isLoadingUser = false;
          _postsFetchDone = false;
          _commentsFetchDone = false;
          _userError = null;
          _postStore.clear();
          _memoryPolicy.clear();
          _setUserComments(const []);
          _postsPage = 1;
          _commentsPage = 1;
          _hasMorePosts = true;
          _hasMoreComments = true;
          _isLoadingMorePosts = false;
          _isLoadingMoreComments = false;
          _pendingLoadMorePosts = false;
        });
      }
    }
  }

  /// Keeps the currently rendered profile visible during a revalidation.
  /// Skeletons are reserved for the first load, when there is no profile to
  /// show yet.
  Future<void> _fetchUser({bool keepExisting = false}) async {
    final canKeepExisting = keepExisting && _personView != null;
    setState(() {
      _isLoadingUser = !canKeepExisting;
      _userError = null;
    });
    try {
      if (widget.personId != null || widget.username != null) {
        final d = await _api.getPersonDetails(
          personId: widget.personId,
          username: widget.username,
          page: 1,
          limit: _pageSize,
          sort: _sortType,
        );
        if (mounted) {
          _postStore.replaceAll(d.posts);
          _setUserComments(d.comments);
          setState(() {
            _personView = d.personView;
            _isLoadingUser = false;
            _isLoadingPosts = false;
            _isLoadingComments = false;
            // Public profile ships first page of posts+comments with the user.
            _postsFetchDone = true;
            _commentsFetchDone = true;
            if (d.posts.length < _pageSize) {
              _hasMorePosts = false;
            }
            if (d.comments.length < _pageSize) {
              _hasMoreComments = false;
            }
          });
        }
      } else {
        final site = await _api.fetchSiteInfo();
        if (mounted) {
          final myUser = site.myUser;
          if (myUser != null) {
            setState(() {
              _personView = PersonView(
                person: myUser.localUserView.person,
                counts: myUser.localUserView.counts,
                isAdmin: myUser.localUserView.localUser.admin,
              );
              _isLoadingUser = false;
              // Own profile: posts/comments load in a second request — mark
              // loading in this same frame so we never paint "No … yet" before
              // the fetch starts. On revalidate (keepExisting), refresh both
              // tabs; lists stay visible because skeleton requires isEmpty.
              if (canKeepExisting) {
                _isLoadingPosts = true;
                _isLoadingComments = true;
                _postsFetchDone = false;
                _commentsFetchDone = false;
              } else if (_tabCtrl.index == 0) {
                _isLoadingPosts = true;
                _postsFetchDone = false;
              } else {
                _isLoadingComments = true;
                _commentsFetchDone = false;
              }
            });
            if (canKeepExisting) {
              final pid = _personView!.person.id;
              // Await so RefreshIndicator stays until lists revalidate.
              await Future.wait([_fetchPosts(pid), _fetchComments(pid)]);
            } else {
              _fetchTabContent();
            }
          } else {
            setState(() {
              _isLoadingUser = false;
              _userError = 'No user data returned — JWT may be invalid.';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          // A failed background refresh must not replace usable profile data
          // with an error screen.
          _userError = canKeepExisting ? null : formatError(e);
        });
      }
    }
  }

  /// Pull-to-refresh: keep the current profile + lists visible (stale-while-
  /// revalidate). Skeleton is only for the first load when there is no data.
  Future<void> _handleRefresh() async {
    await runWithMediaBudgetRecovery(
      () async {
        setState(() {
          _postsPage = 1;
          _commentsPage = 1;
          _hasMorePosts = true;
          _hasMoreComments = true;
        });
        await _fetchUser(keepExisting: true);
      },
      isMounted: () => mounted,
    );
  }

  void _fetchTabContent() {
    if (_personView == null) return;
    final pid = _personView!.person.id;
    switch (_tabCtrl.index) {
      case 0:
        // First load only (or after refresh/sort reset clears the flag).
        // Safe to call while already marked loading — starts the network work.
        if (!_postsFetchDone) _fetchPosts(pid);
        break;
      case 1:
        if (!_commentsFetchDone) _fetchComments(pid);
        break;
    }
  }

  Future<void> _fetchPosts(int pid) async {
    if (_postsRequestInFlight) return;
    _postsRequestInFlight = true;
    setState(() {
      _isLoadingPosts = true;
      _postsFetchDone = false;
      _postsPage = 1;
      _hasMorePosts = true;
    });
    try {
      final d = await _api.getPersonDetails(
        personId: pid,
        page: 1,
        limit: _pageSize,
        sort: _sortType,
      );
      if (mounted) {
        _postStore.replaceAll(d.posts);
        setState(() {
          _isLoadingPosts = false;
          _postsFetchDone = true;
          if (d.posts.length < _pageSize) {
            _hasMorePosts = false;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
          _postsFetchDone = true;
        });
      }
    } finally {
      _postsRequestInFlight = false;
    }
  }

  Future<void> _loadMorePosts(int pid) async {
    if (_isLoadingMorePosts || !_hasMorePosts) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) {
      _pendingLoadMorePosts = true;
      return;
    }
    setState(() => _isLoadingMorePosts = true);
    try {
      final nextPage = _postsPage + 1;
      final d = await _api.getPersonDetails(
        personId: pid,
        page: nextPage,
        limit: _pageSize,
        sort: _sortType,
      );
      if (mounted) {
        _postStore.append(d.posts);
        setState(() {
          _postsPage = nextPage;
          _isLoadingMorePosts = false;
          _hasMorePosts = d.posts.length >= _pageSize;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMorePosts = false);
    }
  }

  Future<void> _toggleUpvote(PostView pv) async {
    if (!_auth.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to vote')),
      );
      return;
    }
    await toggleSurfacePostUpvote(
      ref,
      pv,
      onUpdated: _postStore.upsertSilent,
    );
  }

  Future<void> _toggleDownvote(PostView pv) async {
    if (!_auth.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to vote')),
      );
      return;
    }
    await toggleSurfacePostDownvote(
      ref,
      pv,
      onUpdated: _postStore.upsertSilent,
    );
  }

  Future<void> _toggleSave(PostView pv) async {
    if (!_auth.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to save posts')),
      );
      return;
    }
    await toggleSurfacePostSave(
      ref,
      pv,
      onUpdated: _postStore.upsertSilent,
    );
  }

  PostListIndexMap _postsIndexMapFor(List<int> order) {
    if (_postsIndexMap != null &&
        _postsIndexOrder != null &&
        _postsIndexOrder!.length == order.length) {
      var same = true;
      for (var i = 0; i < order.length; i++) {
        if (_postsIndexOrder![i] != order[i]) {
          same = false;
          break;
        }
      }
      if (same) return _postsIndexMap!;
    }
    _postsIndexOrder = List<int>.from(order);
    _postsIndexMap = PostListIndexMap.fromPostIds(
      order,
      footerSlots: _hasMorePosts ? 1 : 0,
    );
    return _postsIndexMap!;
  }

  Future<void> _fetchComments(int pid) async {
    if (_commentsRequestInFlight) return;
    _commentsRequestInFlight = true;
    setState(() {
      _isLoadingComments = true;
      _commentsFetchDone = false;
      _commentsPage = 1;
      _hasMoreComments = true;
    });
    try {
      final d = await _api.getPersonDetails(
        personId: pid,
        page: 1,
        limit: _pageSize,
        sort: _sortType,
      );
      if (mounted) {
        _setUserComments(d.comments);
        setState(() {
          _isLoadingComments = false;
          _commentsFetchDone = true;
          if (d.comments.length < _pageSize) {
            _hasMoreComments = false;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
          _commentsFetchDone = true;
        });
      }
    } finally {
      _commentsRequestInFlight = false;
    }
  }

  Future<void> _loadMoreComments(int pid) async {
    if (_isLoadingMoreComments || !_hasMoreComments) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) {
      _pendingLoadMoreComments = true;
      return;
    }
    setState(() => _isLoadingMoreComments = true);
    try {
      final nextPage = _commentsPage + 1;
      final d = await _api.getPersonDetails(
        personId: pid,
        page: nextPage,
        limit: _pageSize,
        sort: _sortType,
      );
      if (mounted) {
        final seen = _userComments.map((c) => c.comment.id).toSet();
        final unique =
            d.comments.where((c) => seen.add(c.comment.id)).toList();
        _appendUserComments(unique);
        setState(() {
          _commentsPage = nextPage;
          _isLoadingMoreComments = false;
          _hasMoreComments =
              d.comments.length >= _pageSize && unique.isNotEmpty;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMoreComments = false);
    }
  }

  void _openSettings() async {
    if (_personView == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(personId: _personView!.person.id),
      ),
    );
    _checkSortPreference();
    _fetchUser(keepExisting: true);
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  static const _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Profile-style join date, e.g. "Joined Mar 2024".
  String _formatJoined(String publishedStr) {
    final date = DateTime.tryParse(publishedStr)?.toLocal();
    if (date == null) return '';
    final month = _monthAbbr[date.month - 1];
    return 'Joined $month ${date.year}';
  }

  /// Home instance host from the person's actor_id (e.g. lemmy.world).
  String? _instanceHost(Person person) {
    final uri = Uri.tryParse(person.actorId);
    final host = uri?.host;
    if (host == null || host.isEmpty) return null;
    return host;
  }

  @override
  Widget build(BuildContext context) {
    final isPushed = ModalRoute.of(context)?.canPop ?? false;
    final content =
        (widget.personId != null || widget.username != null || _auth.isLoggedIn)
        ? _buildLoggedIn()
        : _buildLoggedOut();

    // Always use white scaffold — tab mode previously returned bare content and
    // showed through BluerumShell's canvas (AppColors.canvas).
    // Own profile opened as a pushed route: banner has no back, so keep a
    // top-left back over the hero. Hide once the pinned bar is mostly dots.
    final canShowTopBack = isPushed &&
        !_isLoadingUser &&
        (widget.personId == null && widget.username == null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          content,
          // Listenable only this chrome — not TabBarView posts/comments.
          if (canShowTopBack)
            ListenableBuilder(
              listenable: _morphT,
              builder: (context, _) {
                if (_morphT.value >= 0.5) return const SizedBox.shrink();
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  child: _buildGlassHeroButton(
                    icon: MingCuteIcons.mgc_left_line,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Logged Out ──

  Widget _buildLoggedOut() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your profile is waiting',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _openLogin,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                minimumSize: const Size(120, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logged In ──

  Widget _buildLoggedIn() {
    if (_isLoadingUser) {
      return _buildProfileSkeleton();
    }
    if (_userError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                MingCuteIcons.mgc_wifi_off_line,
                size: 48,
                color: _textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Could not load profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userError!,
                style: const TextStyle(fontSize: 13, color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _fetchUser,
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final personView = _personView;
    if (personView == null) {
      // Avoid null-check crash if build races before fetch starts / after reset.
      return _buildProfileSkeleton();
    }

    final person = personView.person;
    final isAdmin = personView.isAdmin;

    // Single pinned bar: text tabs under hero → morphs into dots chrome when sticky.
    // RefreshIndicator wraps NestedScrollView (not each tab body) so the spinner
    // sits at the top of the profile, not under the Posts/Comments region.
    return SafeArea(
      top: true,
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _accent,
        displacement: 40,
        // NestedScrollView + TabBarView + inner CustomScrollView: overscroll
        // notifications arrive at depth 1–2 (default only accepts depth 0).
        //
        // Match notification-screen behavior: only a deliberate pull when the
        // profile is already parked at the top arms PTR — not:
        //  • short lists reporting extentBefore==0 while the hero is scrolled away
        //  • fling / inertia bounce that lands on the top edge
        //  • a continuous drag that started mid-list and overshoots past top
        notificationPredicate: (ScrollNotification notification) {
          if (notification.depth > 2) return false;

          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            // Finger just went down: snapshot whether we're already at top.
            _ptrGestureFromTop =
                !_scrollCtrl.hasClients || _scrollCtrl.offset <= 0.5;
          }

          if (!_ptrGestureFromTop) return false;

          if (notification is ScrollEndNotification) {
            // NestedScrollView can emit several ScrollEnds (outer + inner) in
            // one gesture. Keep the flag true for this turn so armed→refresh
            // still sees the end event, then clear for the next gesture.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _ptrGestureFromTop = false;
            });
          }
          return true;
        },
        child: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(child: _buildProfileHeader(person, isAdmin)),
              // Same pinned root: text tabs under hero, becomes dots as it pins.
              // OverlapAbsorber + Injector keep tab bodies flush under the bar when
              // switching tabs with the header already collapsed.
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: _MorphingTabChromeDelegate(
                    height: _chromeHeight,
                    morphT: _morphT,
                    expandedChild: _buildTextTabBar(),
                    collapsedChild: _buildFloatingHeader(person),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              Builder(builder: (context) => _buildPostsTab(context)),
              Builder(builder: (context) => _buildCommentsTab(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextTabBar() {
    // Fill the full chrome height so no white strips peek above/below the tabs.
    return SizedBox(
      height: _chromeHeight,
      width: double.infinity,
      child: TabBar(
        controller: _tabCtrl,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorColor: Colors.transparent,
        indicatorWeight: 0.01,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        labelColor: _accent,
        unselectedLabelColor: _textSecondary,
        labelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(height: _chromeHeight, text: 'Posts'),
          Tab(height: _chromeHeight, text: 'Comments'),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(Person person) {
    final isOwnProfile =
        widget.personId == null && widget.username == null;
    final displayLabel = person.displayNameOrName;
    final avatarLabel = person.displayName?.isNotEmpty == true
        ? person.displayName!
        : person.name;

    // Same X metrics as post-detail AppBar: height 56, leading pad 4, end pad 4.
    return Container(
      height: _chromeHeight,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          if (Navigator.of(context).canPop()) ...[
            const SizedBox(width: AppBarChrome.leadingOuterPad),
            IconButton(
              tooltip: 'Back',
              iconSize: AppBarChrome.iconSize,
              icon: const Icon(
                MingCuteIcons.mgc_left_line,
                color: _textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ] else
            const SizedBox(width: 16),

          // Avatar
          NetworkAvatar(
            size: 28,
            imageUrl: person.avatar,
            name: avatarLabel,
            fallback: _buildLetterAvatar(avatarLabel, 28),
          ),
          const SizedBox(width: 10),

          // Name / username
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'u/${person.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Posts / Comments sliding dots
          _buildSlidingDots(),

          // Own profile → settings; others → more (same size/glyph as post-detail).
          if (isOwnProfile)
            IconButton(
              tooltip: 'Settings',
              iconSize: AppBarChrome.iconSize,
              icon: const Icon(
                MingCuteIcons.mgc_settings_1_line,
                color: _textPrimary,
              ),
              onPressed: _openSettings,
            )
          else
            IconButton(
              tooltip: 'More actions',
              iconSize: AppBarChrome.iconSize,
              icon: const Icon(
                MingCuteIcons.mgc_more_2_line,
                color: _textPrimary,
              ),
              onPressed: () => _showMoreActions(person),
            ),
          const SizedBox(width: AppBarChrome.leadingOuterPad),
        ],
      ),
    );
  }

  Widget _buildSlidingDots() {
    // 2 tabs (Posts / Comments) — tighter than community's 3-dot strip.
    return SizedBox(
      width: 40,
      height: 30,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 7,
            top: 12,
            child: _buildStaticInactiveDot(),
          ),
          Positioned(
            left: 27,
            top: 12,
            child: _buildStaticInactiveDot(),
          ),
          AnimatedBuilder(
            animation: _tabCtrl.animation!,
            builder: (context, child) {
              final value =
                  _tabCtrl.animation?.value ?? _tabCtrl.index.toDouble();
              final clampedValue = value.clamp(0.0, 1.0);

              final double leftEdge;
              final double rightEdge;
              if (clampedValue >= 1.0) {
                leftEdge = 30.0 - 4.0;
                rightEdge = 30.0 + 4.0;
              } else {
                final fraction = clampedValue;
                const xLeft = 10.0;

                const rightCurve = Interval(0.0, 0.7, curve: Curves.easeInOut);
                const leftCurve = Interval(0.3, 1.0, curve: Curves.easeInOut);

                final rightFraction = rightCurve.transform(fraction);
                final leftFraction = leftCurve.transform(fraction);

                leftEdge = xLeft - 4.0 + (leftFraction * 20.0);
                rightEdge = xLeft + 4.0 + (rightFraction * 20.0);
              }

              final width = rightEdge - leftEdge;
              final height = (8.0 - (width - 8.0) * 0.12).clamp(5.0, 8.0);
              final top = 15.0 - height / 2.0;

              return Positioned(
                left: leftEdge,
                width: width,
                top: top,
                height: height,
                child: Container(
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            width: 20,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _tabCtrl.animateTo(0),
            ),
          ),
          Positioned(
            left: 20,
            width: 20,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _tabCtrl.animateTo(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticInactiveDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _textSecondary.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProfileSkeleton() {
    // Mirrors _buildProfileHeader + text tab chrome + post cards.
    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner + overlapping avatar (stack height 171 like real header)
            Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(height: 171, width: double.infinity),
                const Skeleton(
                  height: 135,
                  width: double.infinity,
                  borderRadius: 0,
                ),
                Positioned(
                  left: 16,
                  top: 95,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Skeleton.circle(size: 70),
                  ),
                ),
              ],
            ),
            // Text info (padding matches real header after stack)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(height: 16, width: 160, borderRadius: 4),
                  SizedBox(height: 4),
                  Skeleton(height: 12, width: 220, borderRadius: 4),
                  SizedBox(height: 8),
                  Skeleton(height: 13, width: double.infinity, borderRadius: 4),
                  SizedBox(height: 4),
                  Skeleton(height: 13, width: 260, borderRadius: 4),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Skeleton(height: 14, width: 52, borderRadius: 4),
                      SizedBox(width: 16),
                      Skeleton(height: 14, width: 72, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
            // Text tab bar chrome (height matches AppBarChrome / Posts·Comments)
            const SizedBox(
              height: _chromeHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Skeleton(height: 14, width: 48, borderRadius: 4),
                    SizedBox(width: 48),
                    Skeleton(height: 14, width: 72, borderRadius: 4),
                  ],
                ),
              ),
            ),
            // Post feed skeletons
            const PostCardSkeleton(showBodyPreview: true, showMedia: true),
            const SizedBox(height: 8),
            const PostCardSkeleton(showBodyPreview: false, showMedia: true),
            const SizedBox(height: 8),
            const PostCardSkeleton(showBodyPreview: true, showMedia: false),
          ],
        ),
      ),
    );
  }

  void _openFullScreenImage(String url) {
    FullScreenMediaViewer.open(
      context,
      mediaItems: [MediaItem(url: url, type: MediaType.image)],
    );
  }

  Future<void> _openPostForComment(CommentView commentView) async {
    // Comment list payloads only include the Post shell, not PostView counts /
    // my_vote. Fetch the real post first so score/comments/vote don't open at 0
    // and then jump (same flicker as opening from notifications).
    final PostView postView;
    try {
      postView = await _api.getPost(commentView.post.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open post: ${formatError(e)}')),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      postDetailRoute(
        builder: (_) => PostDetailScreen(
          postView: postView,
          threadRoot: commentView,
        ),
      ),
    );
  }

  void _showMoreActions(Person person) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    MingCuteIcons.mgc_chat_3_line,
                    size: 22,
                    color: _textPrimary,
                  ),
                  title: Text(
                    'Message u/${person.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                  onTap: () {
                    if (!_auth.isLoggedIn) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Log in to send messages'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          otherPerson: person,
                          initialMessages: const [],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mirrors the frosted close button used by the full-screen media viewer.
  Widget _buildGlassHeroButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: tooltip,
            iconSize: AppBarChrome.iconSize,
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Person person, bool isAdmin) {
    final joinedLabel = _formatJoined(person.published);
    final instanceHost = _instanceHost(person);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Spacer to expand Stack bounds so the overlapping avatar is fully touchable
            const SizedBox(height: 171, width: double.infinity),
            // Banner
            person.banner != null
                ? GestureDetector(
                    onTap: () => _openFullScreenImage(person.banner!),
                    child: CachedNetworkImage(
                      imageUrl: person.banner!,
                      height: 135,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ShimmerPlaceholder(
                        height: 135,
                        width: double.infinity,
                      ),
                      errorWidget: (_, _, _) => _buildDefaultBanner(),
                    ),
                  )
                : _buildDefaultBanner(),

            // Floating Settings Gear
            if (widget.personId == null && widget.username == null)
              Positioned(
                top: 12,
                right: 16,
                child: _buildGlassHeroButton(
                  icon: MingCuteIcons.mgc_settings_1_line,
                  tooltip: 'Settings',
                  onPressed: _openSettings,
                ),
              ),

            // Floating 3-Dots Button (only show on other people's profiles)
            if (widget.personId != null || widget.username != null)
              Positioned(
                top: 12,
                right: 16,
                child: _buildGlassHeroButton(
                  icon: MingCuteIcons.mgc_more_2_line,
                  tooltip: 'More actions',
                  onPressed: () => _showMoreActions(person),
                ),
              ),

            // Floating Back Button (only show on other people's profiles to avoid flicker on own profile)
            if ((widget.personId != null || widget.username != null) &&
                (ModalRoute.of(context)?.canPop ?? false))
              Positioned(
                top: 12,
                left: 16,
                child: _buildGlassHeroButton(
                  icon: MingCuteIcons.mgc_left_line,
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

            // Avatar (overlapping banner)
            Positioned(
              left: 16,
              top: 95,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  // Solid fill so the banner never bleeds through the ring
                  // while the avatar image / skeleton is resolving.
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: person.avatar != null
                      ? () => _openFullScreenImage(person.avatar!)
                      : null,
                  child: NetworkAvatar(
                    size: 70,
                    imageUrl: person.avatar,
                    name: person.displayName?.isNotEmpty == true
                        ? person.displayName!
                        : person.name,
                    fallback: _buildLetterAvatar(
                      person.displayName?.isNotEmpty == true
                          ? person.displayName!
                          : person.name,
                      70,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Text info and metadata (spacing adjusted to match stack height increase)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Name & Admin Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      person.displayNameOrName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (person.banned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Text(
                        'Banned',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // u/slug · from instance · Joined Mar 2024
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    'u/${person.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _textSecondary,
                    ),
                  ),
                  if (instanceHost != null) ...[
                    const Text(
                      '•',
                      style: TextStyle(color: _textSecondary, fontSize: 12),
                    ),
                    Text(
                      'from $instanceHost',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: _textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                  if (joinedLabel.isNotEmpty) ...[
                    const Text(
                      '•',
                      style: TextStyle(color: _textSecondary, fontSize: 12),
                    ),
                    Text(
                      joinedLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Bio
              if (person.bio != null && person.bio!.isNotEmpty) ...[
                Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(Colors.transparent),
                      trackColor: WidgetStateProperty.all(Colors.transparent),
                      thickness: WidgetStateProperty.all(0.0),
                      radius: Radius.zero,
                      interactive: false,
                    ),
                  ),
                  child: ScrollConfiguration(
                    behavior: const _NoScrollbarBehavior(),
                    child: BluerumMarkdown(
                      data: person.bio!,
                      selectable: false,
                      softLineBreak: true,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(
                            Uri.parse(href),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      sizedImageBuilder: (config) {
                        final imgUrl = config.uri.toString();
                        return CommentMediaWidget(
                          item: MediaItem(url: imgUrl, type: MediaType.image),
                          allMedia: [
                            MediaItem(url: imgUrl, type: MediaType.image),
                          ],
                          depth: 0.0,
                        );
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 13,
                          color: _textPrimary,
                          height: 1.5,
                        ),
                        a: BluerumMarkdownStyles.link(fontSize: 13),
                        code: BluerumMarkdownStyles.code(
                          fontSize: 12,
                          color: _textPrimary,
                        ),
                        codeblockDecoration:
                            BluerumMarkdownStyles.codeblockDecoration,
                        blockquoteDecoration: const RoundedBorderDecoration(
                          color: _borderLight,
                          width: 3,
                          isHorizontal: false,
                        ),
                        blockquotePadding: const EdgeInsets.only(
                          left: 12,
                          top: 2,
                          bottom: 2,
                        ),
                        horizontalRuleDecoration: const RoundedBorderDecoration(
                          color: _borderLight,
                          width: 2,
                          isHorizontal: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Stats Row: postCount & commentCount
              Row(
                children: [
                  _buildStat(context, _personView!.counts.postCount, 'posts'),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    _personView!.counts.commentCount,
                    'comments',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      height: 135,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, int count, String label) {
    return Row(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _accent,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildPostsTab(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final Widget content;
    // Skeleton until the first fetch completes — never flash empty text first.
    if ((!_postsFetchDone || _isLoadingPosts) && _postStore.isEmpty) {
      content = CustomScrollView(
        key: const PageStorageKey<String>('profile_posts_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: handle),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
                  child: PostCardSkeleton(
                    showBodyPreview: index != 1,
                    showMedia: index != 2,
                  ),
                ),
                childCount: 3,
              ),
            ),
          ),
        ],
      );
    } else if (_postStore.isEmpty) {
      content = CustomScrollView(
        key: const PageStorageKey<String>('profile_posts_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: handle),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _empty('No posts yet'),
          ),
        ],
      );
    } else if (_personView == null) {
      content = const SizedBox.shrink();
    } else {
      final pid = _personView!.person.id;
      final order = _postStore.order;
      final itemCount = order.length + (_hasMorePosts ? 1 : 0);
      final indexMap = _postsIndexMapFor(order);
      content = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          _lastListScrollMetrics = scrollInfo.metrics;
          _lastListScrollTab = 0;
          _phaseController.onNotification(scrollInfo);
          // Media warm runs on phase → idle via [_onScrollPhaseChanged]
          // (not here: onNotification leaves idle on every ScrollUpdate).
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 500 &&
              !_isLoadingMorePosts &&
              _hasMorePosts &&
              !_isLoadingPosts) {
            if (_scrollPhase.value != FeedScrollPhase.idle) {
              _pendingLoadMorePosts = true;
            } else {
              _requestLoadMorePostsDebounced(pid);
            }
          }
          return false;
        },
        child: CustomScrollView(
          key: const PageStorageKey<String>('profile_posts_scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: PostListMemoryPolicy.listCacheExtent,
          slivers: [
            SliverOverlapInjector(handle: handle),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == order.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(color: _accent),
                        ),
                      );
                    }
                    final postId = order[i];
                    final pv = _postStore[postId];
                    if (pv == null) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i < itemCount - 1 ? 8 : 0,
                      ),
                      child: OptimizedPostListTile(
                        key: ValueKey(postId),
                        postView: pv,
                        vmCache: _postStore.vmCache,
                        memoryPolicy: _memoryPolicy,
                        showCreator: false,
                        onOpen: (p) => Navigator.of(context).push(
                          postDetailRoute(
                            builder: (_) => PostDetailScreen(postView: p),
                          ),
                        ),
                        onUpvote: _toggleUpvote,
                        onDownvote: _toggleDownvote,
                        onSave: _toggleSave,
                      ),
                    );
                  },
                  childCount: itemCount,
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey) {
                      return indexMap.indexForKeyValue(key.value);
                    }
                    return null;
                  },
                  addAutomaticKeepAlives: false,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }

  // ── Comments Tab ──

  Widget _buildCommentsTab(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final Widget content;
    // Skeleton until the first fetch completes — never flash empty text first.
    if ((!_commentsFetchDone || _isLoadingComments) && _userComments.isEmpty) {
      content = CustomScrollView(
        key: const PageStorageKey<String>('profile_comments_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: handle),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ProfileCommentCardSkeleton(),
                childCount: 4,
              ),
            ),
          ),
        ],
      );
    } else if (_userComments.isEmpty) {
      content = CustomScrollView(
        key: const PageStorageKey<String>('profile_comments_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: handle),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _empty('No comments yet'),
          ),
        ],
      );
    } else if (_personView == null) {
      content = const SizedBox.shrink();
    } else {
      final pid = _personView!.person.id;
      final itemCount = _userComments.length + (_hasMoreComments ? 1 : 0);
      final commentsIndex = _commentsIndexMapFor(_userComments);
      content = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          _lastListScrollMetrics = scrollInfo.metrics;
          _lastListScrollTab = 1;
          _phaseController.onNotification(scrollInfo);
          // Media warm runs on phase → idle via [_onScrollPhaseChanged]
          // (not here: onNotification leaves idle on every ScrollUpdate).
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 500 &&
              !_isLoadingMoreComments &&
              _hasMoreComments &&
              !_isLoadingComments) {
            if (_scrollPhase.value != FeedScrollPhase.idle) {
              _pendingLoadMoreComments = true;
            } else {
              _requestLoadMoreCommentsDebounced(pid);
            }
          }
          return false;
        },
        child: CustomScrollView(
          key: const PageStorageKey<String>('profile_comments_scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: PostListMemoryPolicy.secondaryCacheExtent,
          slivers: [
            SliverOverlapInjector(handle: handle),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == _userComments.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(color: _accent),
                        ),
                      );
                    }
                    final cv = _userComments[i];
                    final bodyVm = _commentBodyVms.obtain(
                      commentId: cv.comment.id,
                      content: cv.comment.content,
                    );
                    return RepaintBoundary(
                      key: ValueKey(cv.comment.id),
                      child: _CommentCard(
                        commentView: cv,
                        bodyVm: bodyVm,
                        onTap: () => _openPostForComment(cv),
                      ),
                    );
                  },
                  childCount: itemCount,
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey) {
                      return commentsIndex.indexForKeyValue(key.value);
                    }
                    return null;
                  },
                  addAutomaticKeepAlives: false,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }

  Widget _empty(String text) {
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
    );
  }
}

// ── Comment Card (list preview — body VM tiers + still thumb, no video play) ──

class _CommentCard extends StatelessWidget {
  final CommentView commentView;
  final CommentBodyVm bodyVm;
  final VoidCallback? onTap;

  const _CommentCard({
    required this.commentView,
    required this.bodyVm,
    this.onTap,
  });

  static final _commentMarkdownStyle = MarkdownStyleSheet(
    p: const TextStyle(fontSize: 13, color: _textPrimary, height: 1.5),
    a: BluerumMarkdownStyles.link(fontSize: 13),
    code: BluerumMarkdownStyles.code(
      fontSize: 12,
      color: _textPrimary,
    ),
    codeblockDecoration: BluerumMarkdownStyles.codeblockDecoration,
    blockquoteDecoration: const RoundedBorderDecoration(
      color: _borderLight,
      width: 3,
      isHorizontal: false,
    ),
    blockquotePadding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
    horizontalRuleDecoration: const RoundedBorderDecoration(
      color: _borderLight,
      width: 2,
      isHorizontal: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = commentView.comment;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: _cardBg,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CommunityDetailScreen(
                                  communityId: commentView.community.id,
                                  communityName: commentView.community.name,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'c/${commentView.community.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        ' · ${_timeAgo(c.published)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  MingCuteIcons.mgc_large_arrow_up_line,
                  size: 14,
                  color: _textSecondary,
                ),
                const SizedBox(width: 2),
                Text(
                  '${commentView.counts.score}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              commentView.post.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (c.deleted || c.removed)
              Text(
                c.deleted ? '[deleted]' : '[removed]',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _textSecondary,
                ),
              )
            else ...[
              if (bodyVm.hasText) ...[
                if (bodyVm.paintKind == CommentBodyPaintKind.fullRich)
                  // List preview: plain truncate — full rich at post detail.
                  Text(
                    bodyVm.listPlain.isNotEmpty
                        ? bodyVm.listPlain
                        : bodyVm.markdownSource.trim(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textPrimary,
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
                    color: _textPrimary,
                    onLinkTap: (href) {
                      if (href == null || href.isEmpty) return;
                      launchUrl(
                        Uri.parse(href),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
              ],
              // Still thumb only — fixed height, feed decode, no autoplay.
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

  String _timeAgo(String published) {
    final date = DateTime.tryParse(published);
    if (date == null) return '';
    final diff = DateTime.now().toUtc().difference(date);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ── One pinned bar: scroll-linked text tabs ↔ dots (same root) ──

class _MorphingTabChromeDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  /// 0 = text tabs, 1 = dots chrome (pinned). Listenable — no parent setState.
  final ValueListenable<double> morphT;
  final Widget expandedChild;
  final Widget collapsedChild;

  _MorphingTabChromeDelegate({
    required this.height,
    required this.morphT,
    required this.expandedChild,
    required this.collapsedChild,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ListenableBuilder(
      listenable: morphT,
      builder: (context, _) {
        final t = morphT.value.clamp(0.0, 1.0);
        return Material(
          color: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: t > 0.5,
                  child: Opacity(opacity: 1.0 - t, child: expandedChild),
                ),
                IgnorePointer(
                  ignoring: t < 0.5,
                  child: Opacity(opacity: t, child: collapsedChild),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(_MorphingTabChromeDelegate oldDelegate) {
    return oldDelegate.morphT != morphT ||
        oldDelegate.height != height ||
        oldDelegate.expandedChild != expandedChild ||
        oldDelegate.collapsedChild != collapsedChild;
  }
}

// ── Letter Avatar Helper ──

Widget _buildLetterAvatar(String name, double size) {
  final trimmed = name.trim();
  String letter;
  if (trimmed.isNotEmpty) {
    final first = trimmed.characters.first;
    letter = first.isNotEmpty ? first.toUpperCase() : '?';
  } else {
    letter = '?';
  }
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _borderLight,
      borderRadius: BorderRadius.circular(size / 2),
    ),
    child: Center(
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
        ),
      ),
    ),
  );
}
