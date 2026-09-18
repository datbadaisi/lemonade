import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post_list/post_list.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/features/post/presentation/post_detail_screen.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';

const Color _accent = Color(0xFF000000);
const Color _textPrimary = Color(0xFF000000);
const Color _textSecondary = Color(0xFF525252);
const Color _borderLight = Color(0xFFE0E0E0);

class SavedPostsScreen extends ConsumerStatefulWidget {
  final int personId;

  const SavedPostsScreen({
    super.key,
    required this.personId,
  });

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen> {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  AuthService get _auth => ref.read(authRepositoryProvider);
  final SurfacePostStore _postStore = SurfacePostStore();
  /// Pure virtualization (Home parity).
  final PostListMemoryPolicy _memoryPolicy = PostListMemoryPolicy();
  final PostListIdlePrecache _idlePrecache = PostListIdlePrecache();
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;
  Timer? _loadMoreDebounce;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _pendingLoadMore = false;
  int _page = 1;
  static const int _pageSize = 20;
  String? _error;
  PostListIndexMap? _indexMap;
  List<int>? _indexOrder;

  Future<int> _resolvePersonId() async {
    if (widget.personId != 0) return widget.personId;
    final site = await _api.getSite();
    return site.myUser?.person.id ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    _postStore.addListener(_onStoreChanged);
    if (_auth.isLoggedIn) _fetchSaved(reset: true);
  }

  @override
  void dispose() {
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _postStore.removeListener(_onStoreChanged);
    _loadMoreDebounce?.cancel();
    _phaseController.dispose();
    _scrollPhase.dispose();
    _memoryPolicy.clear();
    _idlePrecache.clear();
    _postStore.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
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
      unawaited(_loadMore());
    });
  }

  Future<void> _fetchSaved({required bool reset}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
        _pendingLoadMore = false;
      });
    }

    try {
      final personId = await _resolvePersonId();
      final details = await _api.getPersonDetails(
        personId: personId,
        savedOnly: true,
        page: 1,
        limit: _pageSize,
      );
      if (mounted) {
        _postStore.replaceAll(details.posts);
        _idlePrecache.clear();
        setState(() {
          _isLoading = false;
          _page = 1;
          _hasMore = details.posts.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = formatError(e);
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) {
      _pendingLoadMore = true;
      return;
    }
    setState(() => _isLoadingMore = true);
    try {
      final next = _page + 1;
      final personId = await _resolvePersonId();
      final details = await _api.getPersonDetails(
        personId: personId,
        savedOnly: true,
        page: next,
        limit: _pageSize,
      );
      if (mounted) {
        _postStore.append(details.posts);
        setState(() {
          _page = next;
          _isLoadingMore = false;
          _hasMore = details.posts.length >= _pageSize;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _toggleUpvote(PostView pv) async {
    if (!_auth.isLoggedIn) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to save posts')),
      );
      return;
    }
    final ok = await toggleSurfacePostSave(
      ref,
      pv,
      onUpdated: (updated) {
        if (!updated.saved) {
          _postStore.remove(updated.post.id);
        } else {
          _postStore.upsertSilent(updated);
        }
      },
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update save')),
      );
    }
  }

  PostListIndexMap _indexMapFor(List<int> order) {
    if (_indexMap != null &&
        _indexOrder != null &&
        _indexOrder!.length == order.length) {
      var same = true;
      for (var i = 0; i < order.length; i++) {
        if (_indexOrder![i] != order[i]) {
          same = false;
          break;
        }
      }
      if (same) return _indexMap!;
    }
    _indexOrder = List<int>.from(order);
    _indexMap = PostListIndexMap.fromPostIds(
      order,
      footerSlots: _hasMore ? 1 : 0,
    );
    return _indexMap!;
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your saved posts are waiting');
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Saved',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(MingCuteIcons.mgc_left_line, color: _textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _postStore.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => PostCardSkeleton(
          showBodyPreview: index != 1,
          showMedia: index != 2,
        ),
      );
    }

    if (_error != null && _postStore.isEmpty) {
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
                'Could not load saved posts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 13, color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => _fetchSaved(reset: true),
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

    if (_postStore.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _borderLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                MingCuteIcons.mgc_bookmark_line,
                size: 40,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved posts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Posts you save will appear here.',
              style: TextStyle(fontSize: 14, color: _textSecondary),
            ),
          ],
        ),
      );
    }

    final order = _postStore.order;
    final indexMap = _indexMapFor(order);
    final itemCount = order.length + (_hasMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => runWithMediaBudgetRecovery(
        () => _fetchSaved(reset: true),
        isMounted: () => mounted,
      ),
      color: _accent,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _phaseController.onNotification(n);
          if (n is ScrollUpdateNotification &&
              _scrollPhase.value == FeedScrollPhase.idle) {
            _idlePrecache.preload(
              context: context,
              posts: _postStore.posts,
              scrollPixels: n.metrics.pixels,
              viewportHeight: n.metrics.viewportDimension,
              averageCardHeight: _memoryPolicy.averageHeight(),
              isFlinging: false,
            );
          }
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 400 &&
              !_isLoadingMore &&
              _hasMore) {
            if (_scrollPhase.value != FeedScrollPhase.idle) {
              _pendingLoadMore = true;
            } else {
              _requestLoadMoreDebounced();
            }
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          cacheExtent: PostListMemoryPolicy.secondaryCacheExtent,
          itemCount: itemCount,
          addAutomaticKeepAlives: false,
          separatorBuilder: (_, i) =>
              i < order.length - 1 ? const SizedBox(height: 8) : const SizedBox.shrink(),
          findChildIndexCallback: (Key key) {
            if (key is ValueKey) return indexMap.indexForKeyValue(key.value);
            return null;
          },
          itemBuilder: (context, i) {
            if (i == order.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
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
              );
            }
            final postId = order[i];
            final postView = _postStore[postId];
            if (postView == null) return const SizedBox.shrink();
            return OptimizedPostListTile(
              key: ValueKey(postId),
              postView: postView,
              vmCache: _postStore.vmCache,
              memoryPolicy: _memoryPolicy,
              onOpen: (p) => Navigator.of(context).push(
                postDetailRoute(
                  builder: (_) => PostDetailScreen(postView: p),
                ),
              ),
              onUpvote: _toggleUpvote,
              onDownvote: _toggleDownvote,
              onSave: _toggleSave,
            );
          },
        ),
      ),
    );
  }
}
