import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_bar_chrome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/community/data/community_repository_impl.dart';
import 'package:bluerum/features/community/domain/load_community.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post_list/post_list.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/media/full_screen_media_viewer.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/features/post/presentation/post_detail_screen.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/features/search/presentation/search_screen.dart';
import 'package:bluerum/app/router/routes.dart';
import 'package:http/http.dart' as http;
import 'package:bluerum/shared/models/site.dart';
import 'package:go_router/go_router.dart';

const Color _accent = Color(0xFF000000);
const Color _textPrimary = Color(0xFF000000);
const Color _textSecondary = Color(0xFF525252);
const Color _borderLight = Color(0xFFE0E0E0);

class CommunityDetailScreen extends ConsumerStatefulWidget {
  final int? communityId;
  final String? communityName;

  const CommunityDetailScreen({
    super.key,
    this.communityId,
    this.communityName,
  });

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  late final AuthService _auth;
  late final TabController _tabCtrl;

  CommunityView? _communityView;
  bool _isLoadingInfo = true;
  String? _infoError;
  bool _loadingInstanceInfo = false;
  SiteView? _instanceSiteView;
  List<PersonView>? _instanceAdmins;
  String? _instanceVersion;

  // Feed State (local surface store — not home feed SSOT)
  final SurfacePostStore _postStore = SurfacePostStore();
  /// Pure virtualization (Home parity) — never pin full media cards off-screen.
  final PostListMemoryPolicy _memoryPolicy = PostListMemoryPolicy();
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;
  bool _isLoadingPosts = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _postsError;
  String _currentSort = 'Active';
  bool _pendingLoadMore = false;
  Timer? _loadMoreDebounce;
  PostListIndexMap? _indexMap;
  List<int>? _indexMapOrder;

  // Toggle State
  bool _subscribing = false;

  /// Tracks auth so logout mid-screen clears personal state + reloads.
  String? _lastJwt;

  // One pinned SliverPersistentHeader: text tabs → dots as it reaches pin.
  // ValueNotifier so morph updates do NOT setState the whole screen (posts list).
  late final ScrollController _scrollCtrl;
  final ValueNotifier<double> _morphT = ValueNotifier<double>(0.0);
  final PostListIdlePrecache _idlePrecache = PostListIdlePrecache();

  /// Match [AppBarChrome.height] / post-detail toolbar (was 52).
  static const double _chromeHeight = AppBarChrome.height;
  static const int _pageSize = 20;

  static final _markdownStyle = MarkdownStyleSheet(
    p: const TextStyle(fontSize: 14, color: _textPrimary, height: 1.5),
    a: BluerumMarkdownStyles.link(fontSize: 14),
    code: BluerumMarkdownStyles.code(
      fontSize: 12,
      color: _textPrimary,
    ),
    codeblockDecoration: BluerumMarkdownStyles.codeblockDecoration,
    blockquoteDecoration: const RoundedBorderDecoration(
      color: Color(0xFFE0E0E0),
      width: 3,
      isHorizontal: false,
    ),
    blockquotePadding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
    horizontalRuleDecoration: const RoundedBorderDecoration(
      color: Color(0xFFE0E0E0),
      width: 2,
      isHorizontal: true,
    ),
    h1: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
    ),
    h2: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
    ),
    h3: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
    ),
  );

  @override
  void initState() {
    super.initState();
    _auth = ref.read(authRepositoryProvider);
    _lastJwt = _auth.jwt;
    _tabCtrl = TabController(length: 3, vsync: this);
    _scrollCtrl = ScrollController()..addListener(_onOuterScroll);
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    _postStore.addListener(_onPostStoreChanged);
    _auth.addListener(_onAuthChanged);
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAll();
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _postStore.removeListener(_onPostStoreChanged);
    _loadMoreDebounce?.cancel();
    _phaseController.dispose();
    _scrollPhase.dispose();
    _memoryPolicy.clear();
    _idlePrecache.clear();
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
    if (_pendingLoadMore) {
      _pendingLoadMore = false;
      _requestLoadMoreDebounced();
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
      unawaited(_loadMorePosts());
    });
  }

  void _tryIdlePrecache([ScrollMetrics? metrics]) {
    // Home parity: only warm media when fully idle (not drag / fling).
    if (!mounted || _scrollPhase.value != FeedScrollPhase.idle) return;
    final m = metrics;
    if (m == null) return;
    _idlePrecache.preload(
      context: context,
      posts: _postStore.posts,
      scrollPixels: m.pixels,
      viewportHeight: m.viewportDimension,
      averageCardHeight: _memoryPolicy.averageHeight(),
      isFlinging: false,
    );
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final jwt = _auth.jwt;
    if (jwt == _lastJwt) return;
    _lastJwt = jwt;
    // Reload community + posts so subscribed/votes/saves match session.
    _loadAll(keepExisting: true);
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
      final start = (pos.maxScrollExtent - morphRange).clamp(
        0.0,
        pos.maxScrollExtent,
      );
      final span = (pos.maxScrollExtent - start).clamp(1.0, double.infinity);
      t = ((pos.pixels - start) / span).clamp(0.0, 1.0);
      t = Curves.easeInOut.transform(t);
    }
    if ((t - _morphT.value).abs() < 0.01) return;
    _morphT.value = t;
  }

  /// Revalidates the current community in place when its existing content is
  /// still valid for the same community and sort.
  Future<void> _loadAll({bool keepExisting = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _currentSort = prefs.getString('bluerum_community_sort') ?? 'Active';
        });
      }
    } catch (_) {}

    if (!mounted) return;

    final canKeepExisting = keepExisting && _communityView != null;
    setState(() {
      _isLoadingInfo = !canKeepExisting;
      _isLoadingPosts = !canKeepExisting;
      _infoError = null;
      _postsError = null;
      if (!canKeepExisting) {
        _postStore.clear();
        _memoryPolicy.clear();
        _idlePrecache.clear();
      }
      _currentPage = 1;
      _hasMore = true;
      _pendingLoadMore = false;
    });

    try {
      final commView = await loadCommunity(
        ref.read(communityRepositoryProvider),
        id: widget.communityId,
        name: widget.communityName,
      );

      if (!mounted) return;

      setState(() {
        _communityView = commView;
        _isLoadingInfo = false;
      });

      final instanceUri = Uri.tryParse(commView.community.actorId);
      final instanceDomain = instanceUri?.host;
      if (instanceDomain != null) {
        _loadInstanceInfo(instanceDomain);
      }

      await _loadPosts(keepExisting: canKeepExisting);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInfo = false;
          _isLoadingPosts = false;
          _infoError = canKeepExisting ? null : formatError(e);
        });
      }
    }
  }

  Future<void> _loadInstanceInfo(String domain) async {
    if (!mounted) return;
    if (_loadingInstanceInfo) return;
    setState(() {
      _loadingInstanceInfo = true;
    });

    try {
      final url = Uri.parse('https://$domain/api/v3/site');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final siteViewJson = json['site_view'] as Map<String, dynamic>;
        final adminsJson = json['admins'] as List? ?? [];
        final version = json['version'] as String?;
        if (mounted) {
          setState(() {
            _instanceSiteView = SiteView.fromJson(siteViewJson);
            _instanceAdmins = adminsJson
                .map((a) => PersonView.fromJson(a))
                .toList();
            _instanceVersion = version;
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _loadingInstanceInfo = false;
        });
      }
    }
  }

  Future<void> _loadPosts({bool keepExisting = false}) async {
    if (!mounted) return;
    if (_communityView == null) return;
    final canKeepExisting = keepExisting && _postStore.isNotEmpty;
    setState(() {
      _isLoadingPosts = !canKeepExisting;
      _postsError = null;
    });

    try {
      final posts = await _api.getPosts(
        sort: _currentSort,
        type: 'All',
        limit: _pageSize,
        page: _currentPage,
        communityId: _communityView!.community.id,
      );

      if (mounted) {
        _postStore.replaceAll(posts);
        setState(() {
          _isLoadingPosts = false;
          if (posts.length < _pageSize) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
          _postsError = canKeepExisting ? null : formatError(e);
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore || _communityView == null) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) {
      _pendingLoadMore = true;
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    try {
      final posts = await _api.getPosts(
        sort: _currentSort,
        type: 'All',
        limit: _pageSize,
        page: nextPage,
        communityId: _communityView!.community.id,
      );

      if (mounted) {
        _postStore.append(posts);
        setState(() {
          _currentPage = nextPage;
          _isLoadingMore = false;
          _hasMore = posts.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _toggleSubscription() async {
    if (_communityView == null || _subscribing) return;
    if (!_auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to subscribe to communities')),
      );
      return;
    }

    setState(() {
      _subscribing = true;
    });

    final currentSub = _communityView!.subscribed;
    final isSubscribed = currentSub == 'Subscribed';
    final targetFollow = !isSubscribed;

    try {
      final communityId = _communityView!.community.id;
      final updatedView = await ref
          .read(communityRepositoryProvider)
          .follow(communityId: communityId, follow: targetFollow);

      if (mounted) {
        if (targetFollow &&
            (updatedView.subscribed == 'Subscribed' ||
                updatedView.subscribed == 'Pending')) {
          ref
              .read(sessionSubscribedCommunityIdsProvider.notifier)
              .add(communityId);
        }
        setState(() {
          _communityView = updatedView;
          _subscribing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _subscribing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription failed: ${formatError(e)}')),
        );
      }
    }
  }

  Future<void> _toggleBlockCommunity() async {
    if (_communityView == null || _subscribing) return;
    if (!_auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to block communities')),
      );
      return;
    }

    final currentBlocked = _communityView!.blocked;
    final targetBlock = !currentBlocked;

    try {
      final success = await ref
          .read(communityRepositoryProvider)
          .block(communityId: _communityView!.community.id, block: targetBlock);

      if (success && mounted) {
        setState(() {
          _communityView = _communityView!.copyWith(blocked: targetBlock);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              targetBlock
                  ? 'Blocked community c/${_communityView!.community.name}'
                  : 'Unblocked community c/${_communityView!.community.name}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update block state: ${formatError(e)}'),
          ),
        );
      }
    }
  }

  void _openFullScreenImage(String url) {
    FullScreenMediaViewer.open(
      context,
      mediaItems: [MediaItem(url: url, type: MediaType.image)],
    );
  }

  /// Opens create-post with this community pre-selected, then refreshes the feed
  /// and navigates to the new post when creation succeeds.
  Future<void> _openCreatePost() async {
    final community = _communityView;
    if (community == null) return;
    final result = await context.push<PostView>(
      AppRoutes.createPost,
      extra: community,
    );
    if (!mounted || result == null) return;
    final postView = result;
    _currentPage = 1;
    _hasMore = true;
    await _loadPosts();
    if (!mounted) return;
    // Defer navigation until after create-post route teardown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created'),
          duration: Duration(seconds: 2),
        ),
      );
      context.push('/posts/${postView.post.id}');
    });
  }

  void _showMoreActions() {
    if (_communityView == null) return;
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
                    MingCuteIcons.mgc_pencil_2_line,
                    size: 22,
                    color: Color(0xFF000000),
                  ),
                  title: const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  subtitle: Text(
                    'in c/${_communityView!.community.name}',
                    style: const TextStyle(fontSize: 12, color: _textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openCreatePost();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    MingCuteIcons.mgc_transfer_vertical_line,
                    size: 22,
                    color: Color(0xFF000000),
                  ),
                  title: const Text(
                    'Sort Posts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  trailing: Text(
                    _currentSort,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSortDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    MingCuteIcons.mgc_search_2_line,
                    size: 22,
                    color: Color(0xFF000000),
                  ),
                  title: const Text(
                    'Search Community',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          communityId: _communityView!.community.id,
                          instanceUrl: _api.baseUrl,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    _communityView!.blocked
                        ? MingCuteIcons.mgc_safe_alert_line
                        : MingCuteIcons.mgc_forbid_circle_line,
                    size: 22,
                    color: const Color(0xFF000000),
                  ),
                  title: Text(
                    _communityView!.blocked
                        ? 'Unblock Community'
                        : 'Block Community',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _toggleBlockCommunity();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortDialog() {
    final sorts = ['Active', 'Hot', 'Controversial', 'Scaled', 'New', 'Old'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort posts by',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: sorts.map((s) {
                      final isSelected = s == _currentSort;
                      return ListTile(
                        title: Text(
                          s,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? _accent : _textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                MingCuteIcons.mgc_check_line,
                                color: _accent,
                                size: 18,
                              )
                            : null,
                        onTap: () async {
                          Navigator.pop(context);
                          if (s != _currentSort) {
                            setState(() {
                              _currentSort = s;
                              _currentPage = 1;
                              _postStore.clear();
                              _memoryPolicy.clear();
                              _isLoadingPosts = true;
                              _hasMore = true;
                              _pendingLoadMore = false;
                            });
                            try {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                'bluerum_community_sort',
                                s,
                              );
                            } catch (_) {}
                            _loadPosts();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Vote/Save: global overlays + surface store (no full-list setState) ──
  Future<void> _toggleUpvote(PostView pv) async {
    if (!_auth.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to vote')));
      return;
    }
    final ok = await toggleSurfacePostUpvote(
      ref,
      pv,
      onUpdated: _postStore.upsertSilent,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote failed')),
      );
    }
  }

  Future<void> _toggleDownvote(PostView pv) async {
    if (!_auth.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to vote')));
      return;
    }
    final ok = await toggleSurfacePostDownvote(
      ref,
      pv,
      onUpdated: _postStore.upsertSilent,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote failed')),
      );
    }
  }

  Future<void> _toggleSave(PostView pv) async {
    if (!_auth.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to save posts')));
      return;
    }
    final ok = await toggleSurfacePostSave(
      ref,
      pv,
      onUpdated: _postStore.upsertSilent,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save post')),
      );
    }
  }

  PostListIndexMap _indexMapFor(List<int> order) {
    if (_indexMap != null &&
        _indexMapOrder != null &&
        _listEquals(_indexMapOrder!, order)) {
      return _indexMap!;
    }
    _indexMapOrder = List<int>.from(order);
    _indexMap = PostListIndexMap.fromPostIds(
      order,
      footerSlots: _hasMore ? 1 : 0,
    );
    return _indexMap!;
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildContent());
  }

  Widget _buildContent() {
    if (_isLoadingInfo && _communityView == null) {
      // Mirrors banner + header card + tab chrome + feed cards.
      return SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Skeleton(
                height: 135,
                width: double.infinity,
                borderRadius: 0,
              ),
              // Header card (padding / avatar ring match _buildCommunityHeaderCard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Skeleton.circle(size: 58),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2),
                              Skeleton(height: 16, width: 150, borderRadius: 4),
                              SizedBox(height: 4),
                              Skeleton(height: 13, width: 90, borderRadius: 4),
                            ],
                          ),
                        ),
                        const Skeleton(
                          height: 32,
                          width: 96,
                          borderRadius: 9999,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(
                        4,
                        (_) => const Expanded(
                          child: Column(
                            children: [
                              Skeleton(height: 15, width: 40, borderRadius: 4),
                              SizedBox(height: 3),
                              Skeleton(height: 10, width: 56, borderRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tab chrome (Feed · Information · Moderators)
              const SizedBox(
                height: _chromeHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Skeleton(height: 14, width: 36, borderRadius: 4),
                      Skeleton(height: 14, width: 80, borderRadius: 4),
                      Skeleton(height: 14, width: 72, borderRadius: 4),
                    ],
                  ),
                ),
              ),
              const PostCardSkeleton(showBodyPreview: true, showMedia: true),
              const PostCardSkeleton(showBodyPreview: false, showMedia: true),
            ],
          ),
        ),
      );
    }

    if (_infoError != null && _communityView == null) {
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
                'Could not load community',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _infoError!,
                style: const TextStyle(fontSize: 13, color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadAll,
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

    final community = _communityView!.community;

    // Single pinned bar: text tabs under hero → morphs into dots chrome when sticky.
    return SafeArea(
      top: true,
      bottom: false,
      child: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Banner Image
                  community.banner != null
                      ? GestureDetector(
                          onTap: () => _openFullScreenImage(community.banner!),
                          child: CachedNetworkImage(
                            imageUrl: community.banner!,
                            height: 135,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const ShimmerPlaceholder(
                                  height: 135,
                                  width: double.infinity,
                                ),
                            errorWidget: (context, url, error) =>
                                _buildDefaultBanner(height: 135),
                          ),
                        )
                      : _buildDefaultBanner(height: 135),
                  // Banner dark gradient overlay
                  IgnorePointer(
                    child: Container(
                      height: 135,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Symmetric Back Button (frosted glass, matches profile)
                  if (Navigator.of(context).canPop())
                    Positioned(
                      top: 12,
                      left: 16,
                      child: _buildGlassHeroButton(
                        icon: MingCuteIcons.mgc_left_line,
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  // Symmetric 3-Dots More Menu (frosted glass)
                  Positioned(
                    top: 12,
                    right: 16,
                    child: _buildGlassHeroButton(
                      icon: MingCuteIcons.mgc_more_2_line,
                      tooltip: 'More actions',
                      onPressed: _showMoreActions,
                    ),
                  ),
                ],
              ),
            ),
            // Community Info card
            SliverToBoxAdapter(child: _buildCommunityHeaderCard(community)),
            // Same pinned root: text tabs under hero, becomes dots as it pins.
            // OverlapAbsorber + Injector keep tab bodies flush under the bar when
            // switching tabs with the header already collapsed.
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _MorphingTabChromeDelegate(
                  height: _chromeHeight,
                  morphT: _morphT,
                  expandedChild: _buildTextTabBar(),
                  collapsedChild: _buildFloatingHeader(community),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            Builder(
              builder: (BuildContext context) {
                return RefreshIndicator(
                  onRefresh: () => runWithMediaBudgetRecovery(
                    () => _loadAll(keepExisting: true),
                    isMounted: () => mounted,
                  ),
                  color: _accent,
                  child: _buildPostsFeed(context),
                );
              },
            ),
            Builder(
              builder: (BuildContext context) {
                return _buildCommunityInfoTab(context, community);
              },
            ),
            Builder(
              builder: (BuildContext context) {
                return _buildModeratorsTab(context, community);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTabBar() {
    // Fill the full chrome height so no white strips peek above/below the tabs.
    // No bottom border — matches profile / notifications tab chrome.
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
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(height: _chromeHeight, text: 'Feed'),
          Tab(height: _chromeHeight, text: 'Information'),
          Tab(height: _chromeHeight, text: 'Moderators'),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(Community community) {
    // Same X metrics as post-detail AppBar: height 56, leading ~56, end pad 4.
    return Container(
      height: _chromeHeight,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          // 1. Back — Material leading slot (outer 4 + 48 IconButton).
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

          // 2. Community Avatar
          NetworkAvatar(
            size: 28,
            imageUrl: community.icon,
            name: community.title,
            fallback: _buildLetterAvatar(community.title, 28),
          ),
          const SizedBox(width: 10),

          // 3. Community Slug
          Expanded(
            child: Text(
              'c/${community.name}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // 4. Smooth Sliding Dot Indicators
          _buildSlidingDots(),

          // 5. More — same glyph + size as post-detail AppBar.
          IconButton(
            tooltip: 'More actions',
            iconSize: AppBarChrome.iconSize,
            icon: const Icon(
              MingCuteIcons.mgc_more_2_line,
              color: _textPrimary,
            ),
            onPressed: _showMoreActions,
          ),
          const SizedBox(width: AppBarChrome.leadingOuterPad),
        ],
      ),
    );
  }

  Widget _buildSlidingDots() {
    return SizedBox(
      width: 60,
      height: 30,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 3 Inactive dots
          Positioned(left: 7, top: 12, child: _buildStaticInactiveDot()),
          Positioned(left: 27, top: 12, child: _buildStaticInactiveDot()),
          Positioned(left: 47, top: 12, child: _buildStaticInactiveDot()),
          // 1 Sliding Active Dot with Stretch (Water Droplet) Effect
          AnimatedBuilder(
            animation: _tabCtrl.animation!,
            builder: (context, child) {
              final value =
                  _tabCtrl.animation?.value ?? _tabCtrl.index.toDouble();
              final clampedValue = value.clamp(0.0, 2.0);

              final double leftEdge;
              final double rightEdge;
              if (clampedValue >= 2.0) {
                leftEdge = 50.0 - 4.0;
                rightEdge = 50.0 + 4.0;
              } else {
                final index = clampedValue.floor();
                final fraction = clampedValue - index;
                final xLeft = 10.0 + index * 20.0;

                // Interval curves to stretch right edge early and left edge late
                const rightCurve = Interval(0.0, 0.7, curve: Curves.easeInOut);
                const leftCurve = Interval(0.3, 1.0, curve: Curves.easeInOut);

                final rightFraction = rightCurve.transform(fraction);
                final leftFraction = leftCurve.transform(fraction);

                leftEdge = xLeft - 4.0 + (leftFraction * 20.0);
                rightEdge = xLeft + 4.0 + (rightFraction * 20.0);
              }

              final width = rightEdge - leftEdge;
              // Squish height slightly as the width stretches to simulate surface tension
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
                    borderRadius: BorderRadius.circular(99), // Capsule shape
                  ),
                ),
              );
            },
          ),
          // Tapping overlay targets
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
          Positioned(
            left: 40,
            width: 20,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _tabCtrl.animateTo(2),
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

  /// Frosted glass control over the banner — matches profile hero buttons.
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

  Widget _buildDefaultBanner({double height = 135}) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E659A), Color(0xFF1E4268)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildCommunityHeaderCard(Community community) {
    final hasIcon = community.icon != null;
    final isSubscribed = _communityView!.subscribed == 'Subscribed';
    final isPending = _communityView!.subscribed == 'Pending';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community Title, Icon and Subscribe Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Avatar
              GestureDetector(
                onTap: community.icon != null
                    ? () => _openFullScreenImage(community.icon!)
                    : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    // Solid fill so the banner never bleeds through the ring
                    // while the icon / skeleton is resolving.
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: NetworkAvatar(
                    size: 58,
                    imageUrl: hasIcon ? community.icon : null,
                    name: community.title,
                    fallback: _buildLetterAvatar(community.title, 58),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title and handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      community.title.isNotEmpty
                          ? community.title
                          : community.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'c/${community.name}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Subscribe Button
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: _subscribing ? null : _toggleSubscription,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSubscribed
                        ? Colors.transparent
                        : (isPending ? _borderLight : _accent),
                    side: BorderSide(
                      color: isSubscribed ? _borderLight : Colors.transparent,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: _subscribing
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isSubscribed ? _textSecondary : Colors.white,
                          ),
                        )
                      : Text(
                          isSubscribed
                              ? 'Subscribed'
                              : (isPending ? 'Pending' : 'Subscribe'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSubscribed
                                ? _textSecondary
                                : (isPending ? _textSecondary : Colors.white),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildCommunityInfoTab(BuildContext context, Community community) {
    return CustomScrollView(
      key: const PageStorageKey<String>('community_info_scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Community Info',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              if (community.description != null &&
                  community.description!.trim().isNotEmpty) ...[
                BluerumMarkdown(
                  data: community.description!,
                  onTapLink: (text, href, title) {
                    if (href != null)
                      launchUrl(
                        Uri.parse(href),
                        mode: LaunchMode.externalApplication,
                      );
                  },
                  styleSheet: _markdownStyle,
                ),
              ] else ...[
                const Text(
                  'No description provided.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (_loadingInstanceInfo) ...[
                _buildInstanceInfoSkeleton(),
              ] else if (_instanceSiteView != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Instance Info',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Header Banner of the instance (Flat, full aspect ratio, fitWidth to show entire height)
                if (_instanceSiteView!.site.banner != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _instanceSiteView!.site.banner!,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      placeholder: (context, url) => const ShimmerPlaceholder(
                        height: 110,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Title & Icon
                Row(
                  children: [
                    if (_instanceSiteView!.site.icon != null) ...[
                      NetworkAvatar(
                        size: 32,
                        imageUrl: _instanceSiteView!.site.icon,
                        name: _instanceSiteView!.site.name,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _instanceSiteView!.site.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          if (_instanceVersion != null &&
                              _instanceVersion!.isNotEmpty)
                            Text(
                              'Version: $_instanceVersion',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Short description
                if (_instanceSiteView!.site.description != null &&
                    _instanceSiteView!.site.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _instanceSiteView!.site.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: _textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                // Sidebar rules
                if (_instanceSiteView!.site.sidebar != null &&
                    _instanceSiteView!.site.sidebar!.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'About & Rules',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BluerumMarkdown(
                    data: _instanceSiteView!.site.sidebar!,
                    onTapLink: (text, href, title) {
                      if (href != null)
                        launchUrl(
                          Uri.parse(href),
                          mode: LaunchMode.externalApplication,
                        );
                    },
                    styleSheet: _markdownStyle,
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.users),
                      'users',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.communities),
                      'communities',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.posts),
                      'posts',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.comments),
                      'comments',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.usersActiveDay),
                      'active/day',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.usersActiveWeek),
                      'active/week',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(_instanceSiteView!.counts.usersActiveMonth),
                      'active/month',
                    ),
                    _buildFlatStatInline(
                      _formatNumber(
                        _instanceSiteView!.counts.usersActiveHalfYear,
                      ),
                      'active/6m',
                    ),
                  ],
                ),
                // Site Admins List
                if (_instanceAdmins != null && _instanceAdmins!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Site Administrators',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: _instanceAdmins!.map((adminView) {
                      final admin = adminView.person;
                      final hasAvatar = admin.avatar != null;
                      final adminDisplayName =
                          admin.displayName != null &&
                              admin.displayName!.trim().isNotEmpty
                          ? admin.displayName!
                          : admin.name;
                      final adminDomain =
                          Uri.tryParse(admin.actorId)?.host ?? 'lemmy.world';
                      final federatedUsername = '${admin.name}@$adminDomain';

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(username: federatedUsername),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NetworkAvatar(
                                size: 20,
                                imageUrl: hasAvatar ? admin.avatar : null,
                                name: adminDisplayName,
                                fallback: _buildLetterAvatar(
                                  adminDisplayName,
                                  20,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'u/${admin.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ]),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildFlatStatInline(String value, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: _textPrimary),
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildModeratorsTab(BuildContext context, Community community) {
    final moderators = _communityView?.moderators ?? [];

    if (moderators.isEmpty) {
      return CustomScrollView(
        key: const PageStorageKey<String>('community_mods_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No moderators found.',
                  style: TextStyle(color: _textSecondary),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      key: const PageStorageKey<String>('community_mods_scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final mod = moderators[index].moderator;
            final hasAvatar = mod.avatar != null;
            final displayName =
                mod.displayName != null && mod.displayName!.trim().isNotEmpty
                ? mod.displayName!
                : mod.name;

            return ListTile(
              leading: NetworkAvatar(
                size: 36,
                imageUrl: hasAvatar ? mod.avatar : null,
                name: displayName,
                fallback: _buildLetterAvatar(displayName, 36),
              ),
              title: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _textPrimary,
                ),
              ),
              subtitle: Text(
                'u/${mod.name}',
                style: const TextStyle(fontSize: 12, color: _textSecondary),
              ),
              trailing: const Icon(
                MingCuteIcons.mgc_right_line,
                size: 16,
                color: _textSecondary,
              ),
              onTap: () {
                final modDomain =
                    Uri.tryParse(mod.actorId)?.host ?? 'lemmy.world';
                final federatedUsername = '${mod.name}@$modDomain';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(username: federatedUsername),
                  ),
                );
              },
            );
          }, childCount: moderators.length),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final counts = _communityView!.counts;
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            _formatNumber(counts.subscribers),
            'Subscribers',
          ),
        ),
        Expanded(child: _buildStatItem(_formatNumber(counts.posts), 'Posts')),
        Expanded(
          child: _buildStatItem(
            _formatNumber(counts.usersActiveDay),
            'Active (Day)',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            _formatNumber(counts.usersActiveWeek),
            'Active (Week)',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _textSecondary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLetterAvatar(String title, double size) {
    final initial = title.trim().isNotEmpty
        ? title.trim()[0].toUpperCase()
        : '?';
    final colors = [
      const Color(0xFF3B6073),
      const Color(0xFF8A307F),
      const Color(0xFF0F2027),
      const Color(0xFF1E3C72),
      const Color(0xFF2C5364),
    ];
    final color = colors[title.length % colors.length];

    return Container(
      width: size,
      height: size,
      color: color,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPostsFeed(BuildContext context) {
    if (_isLoadingPosts && _postStore.isEmpty) {
      return CustomScrollView(
        key: const PageStorageKey<String>('community_feed_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCardSkeleton(
                  showBodyPreview: index % 2 == 0,
                  showMedia: index != 1,
                ),
                childCount: 3,
              ),
            ),
          ),
        ],
      );
    }

    if (_postsError != null && _postStore.isEmpty) {
      return CustomScrollView(
        key: const PageStorageKey<String>('community_feed_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      MingCuteIcons.mgc_wifi_off_line,
                      size: 36,
                      color: _textSecondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Could not load posts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _postsError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadPosts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_postStore.isEmpty) {
      return CustomScrollView(
        key: const PageStorageKey<String>('community_feed_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 80, horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MingCuteIcons.mgc_news_line,
                      size: 48,
                      color: _textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Be the first to create a post in this community.',
                      style: TextStyle(fontSize: 13, color: _textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final order = _postStore.order;
    final itemCount = order.length + (_hasMore ? 1 : 0);
    final indexMap = _indexMapFor(order);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        _phaseController.onNotification(scrollInfo);
        if (scrollInfo is ScrollUpdateNotification &&
            _scrollPhase.value == FeedScrollPhase.idle) {
          _tryIdlePrecache(scrollInfo.metrics);
        }
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 400 &&
            !_isLoadingMore &&
            _hasMore &&
            !_isLoadingPosts) {
          if (_scrollPhase.value != FeedScrollPhase.idle) {
            _pendingLoadMore = true;
          } else {
            _requestLoadMoreDebounced();
          }
        }
        return false;
      },
      child: CustomScrollView(
        key: const PageStorageKey<String>('community_feed_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: PostListMemoryPolicy.listCacheExtent,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == order.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    );
                  }

                  final postId = order[index];
                  final pv = _postStore[postId];
                  if (pv == null) return const SizedBox.shrink();
                  return OptimizedPostListTile(
                    key: ValueKey(postId),
                    postView: pv,
                    vmCache: _postStore.vmCache,
                    memoryPolicy: _memoryPolicy,
                    onOpen: (p) {
                      Navigator.of(context).push(
                        postDetailRoute(
                          builder: (_) => PostDetailScreen(postView: p),
                        ),
                      );
                    },
                    onUpvote: _toggleUpvote,
                    onDownvote: _toggleDownvote,
                    onSave: _toggleSave,
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

  Widget _buildInstanceInfoSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Instance Info',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Banner Skeleton
        const Skeleton(height: 110, width: double.infinity, borderRadius: 8),
        const SizedBox(height: 16),
        // Title & Icon Skeleton
        Row(
          children: [
            const Skeleton.circle(size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(height: 16, width: 140),
                  const SizedBox(height: 6),
                  const Skeleton(height: 12, width: 80),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Short description skeleton
        const Skeleton(height: 13, width: double.infinity),
        const SizedBox(height: 8),
        const Skeleton(height: 13, width: 220),
        const SizedBox(height: 24),
        // Statistics header
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Stats wrap skeleton
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(
            6,
            (index) => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Skeleton(height: 13, width: 35),
                SizedBox(width: 4),
                Skeleton(height: 13, width: 45),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Site Admins list header
        const Text(
          'Site Administrators',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Admins wrap skeleton
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: List.generate(
            2,
            (index) => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Skeleton.circle(size: 20),
                SizedBox(width: 6),
                Skeleton(height: 12, width: 60),
              ],
            ),
          ),
        ),
      ],
    );
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
    // Rebuild only this chrome when morphT ticks — not the NestedScroll body.
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
