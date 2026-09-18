import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_bar_chrome.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/ads/domain/ads_placement.dart';
import 'package:bluerum/features/ads/presentation/in_feed_native_ad.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/comment/data/comment_repository_impl.dart';
import 'package:bluerum/features/comment/presentation/comment_compose_screen.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/features/create_post/presentation/create_post_screen.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/features/post/data/comment_page_cache.dart';
import 'package:bluerum/features/post/data/post_repository_impl.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/comment_card.dart';
import 'package:bluerum/features/post/presentation/comment_list_extents.dart';
import 'package:bluerum/features/post/presentation/comment_list_memory.dart';
import 'package:bluerum/features/post/presentation/comment_thread_controller.dart';
import 'package:bluerum/features/post/presentation/comment_thread_flatten.dart';
import 'package:bluerum/features/post/presentation/comment_thread_provider.dart';
import 'package:bluerum/features/post/presentation/open_settle_gate.dart';
import 'package:bluerum/features/post/presentation/post_detail_comment_row.dart';
import 'package:bluerum/features/post/presentation/post_detail_dialogs.dart';
import 'package:bluerum/features/post/presentation/post_detail_header.dart';
import 'package:bluerum/features/post/presentation/post_detail_interaction.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/features/post/presentation/post_detail_sheets.dart';
import 'package:bluerum/features/post/presentation/post_detail_theme.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/media/media_aspect_cache.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/nav_perf_log.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const int _kPageSize = 50;
const int _kApiMaxDepth = 8;

CommentPageCache get _commentPageCache => sharedCommentPageCache;

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostView postView;
  final CommentView? threadRoot;
  final CommentSortType initialCommentSort;
  final Map<int, int>? commentVoteState;
  final int? initialVote;
  final bool? initialSaved;
  final Future<bool> Function()? onUpvote;
  final Future<bool> Function()? onDownvote;
  final Future<bool> Function()? onSave;
  final int? initialCommentId;

  const PostDetailScreen({
    super.key,
    required this.postView,
    this.threadRoot,
    this.initialCommentId,
    this.initialCommentSort = CommentSortType.hot,
    this.commentVoteState,
    this.initialVote,
    this.initialSaved,
    this.onUpvote,
    this.onDownvote,
    this.onSave,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late final AuthService _authService;

  final ScrollController _scrollCtrl = ScrollController();
  Timer? _scrollDebounce;

  late final ValueNotifier<FeedScrollPhase> _detailScrollPhase;
  late final FeedScrollPhaseController _phaseController;
  late final PostDetailVoteStore _votes;
  final CommentListMemoryPolicy _memory = CommentListMemoryPolicy();

  static const double _commentBarContentHeight = 60.0;
  double _lastScrollPos = 0;
  final ValueNotifier<double> _barHidePixels = ValueNotifier<double>(0);

  late CommentSortType _sort;
  double? _resolvedPostImageRatio;
  bool _postImageRatioSettled = false;
  bool _postImageRatioProbeStarted = false;
  bool _isLoading = true;
  String? _loadError;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _loadMoreError;
  int _page = 1;
  int _generation = 0;
  int? _highlightCommentId;
  bool _didRunTargetScroll = false;

  late PostView _postView;
  ImageStream? _ratioStream;
  ImageStreamListener? _ratioListener;
  final OpenSettleGate _openGate = OpenSettleGate();
  bool _page1Resolved = false;
  PostView? _deferredUpdatedPost;
  String? _deferredLoadError;

  String? _headerMemoKey;
  List<MediaItem> _headerMedia = const [];
  String? _headerMarkdownBody;
  String? _lastJwt;
  final GlobalKey _listKey = GlobalKey();
  final Set<String> _prefetchedMediaUrls = {};

  CommentThreadScope get _threadScope => CommentThreadScope(
    postId: widget.postView.post.id,
    threadRootId: widget.threadRoot?.comment.id,
  );

  CommentThreadController get _thread =>
      ref.read(commentThreadControllerProvider(_threadScope));

  Map<int, CommentView> get _commentMap => _thread.comments;
  List<CommentFlatRow> get _rows => _thread.rows;
  CommentBodyVmStore get _bodyVms => _thread.bodyVms;
  Map<int, int> get _rowIndexById => _thread.rowIndexById;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void _resolvePostImageRatio({bool allowNetworkProbe = true}) {
    if (_postImageRatioSettled) return;

    final firstMedia = extractPostMedia(_postView).firstOrNull;
    if (firstMedia == null) return;

    if (firstMedia.isVideo && firstMedia.videoType == VideoType.youtube) {
      _applyPostImageRatio(16 / 9, settle: true);
      return;
    }

    final details = _postView.imageDetails;
    if (details != null && details.width > 0 && details.height > 0) {
      final url = firstMedia.type == MediaType.image
          ? firstMedia.url
          : (firstMedia.thumbnailUrl ?? firstMedia.url);
      putMediaAspect(url, details.aspectRatio);
      _applyPostImageRatio(details.aspectRatio, settle: true);
      return;
    }

    final displayUrl = firstMedia.type == MediaType.image
        ? firstMedia.url
        : firstMedia.thumbnailUrl;
    final cached = cachedMediaAspect(displayUrl) ??
        cachedMediaAspect(firstMedia.url) ??
        cachedMediaAspect(firstMedia.thumbnailUrl);
    if (cached != null) {
      _applyPostImageRatio(cached, settle: true);
      return;
    }

    if (_resolvedPostImageRatio == null) {
      _applyPostImageRatio(16 / 9, settle: false);
    }
    if (displayUrl == null || displayUrl.isEmpty) {
      _postImageRatioSettled = true;
      return;
    }
    if (!allowNetworkProbe || !_openGate.settled) return;
    _probePostImageRatio(displayUrl);
  }

  void _probePostImageRatio(String url) {
    if (_postImageRatioProbeStarted || _postImageRatioSettled) return;
    _postImageRatioProbeStarted = true;

    _cancelRatioProbe();
    final image = CachedNetworkImageProvider(url);
    final stream = image.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        _detachRatioProbe(stream, listener);
        final w = info.image.width;
        final h = info.image.height;
        if (w <= 0 || h <= 0 || !mounted) return;
        final ratio = w / h;
        putMediaAspect(url, ratio);
        _applyPostImageRatio(ratio, settle: true);
      },
      onError: (_, _) {
        _detachRatioProbe(stream, listener);
        _postImageRatioSettled = true;
      },
    );
    _ratioStream = stream;
    _ratioListener = listener;
    stream.addListener(listener);
  }

  void _detachRatioProbe(ImageStream stream, ImageStreamListener listener) {
    stream.removeListener(listener);
    if (identical(_ratioStream, stream)) {
      _ratioStream = null;
      _ratioListener = null;
    }
  }

  void _cancelRatioProbe() {
    final stream = _ratioStream;
    final listener = _ratioListener;
    _ratioStream = null;
    _ratioListener = null;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
  }

  void _applyPostImageRatio(double ratio, {required bool settle}) {
    final next = ratio.clamp(0.2, 5.0);
    final prev = _resolvedPostImageRatio;
    if (settle) _postImageRatioSettled = true;
    if (prev != null && (prev - next).abs() < 0.01) return;
    _resolvedPostImageRatio = next;
    if (mounted) setState(() {});
  }

  void _ensureHeaderMemo() {
    final post = _postView.post;
    final key =
        '${post.id}|${post.body}|${post.updated}|${post.url}|${post.embedVideoUrl}|${post.thumbnailUrl}|${post.embedTitle}';
    if (_headerMemoKey == key) return;
    _headerMemoKey = key;
    _headerMedia = List<MediaItem>.unmodifiable(extractPostMedia(_postView));
    final body = post.body;
    if (body == null || body.isEmpty) {
      _headerMarkdownBody = null;
    } else if (_headerMedia.isEmpty) {
      _headerMarkdownBody = body;
    } else {
      final stripped = stripMarkdownMedia(body, _headerMedia);
      _headerMarkdownBody = stripped.trim().isEmpty ? null : stripped;
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = ref.read(authRepositoryProvider);
    _postView = widget.postView;
    _detailScrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(
      listenable: _detailScrollPhase,
    );
    _votes = PostDetailVoteStore(
      postVote: widget.initialVote ?? _postView.myVote ?? 0,
      postSaved: widget.initialSaved ?? _postView.saved,
      seedCommentVotes: widget.commentVoteState,
    );
    _resolvePostImageRatio(allowNetworkProbe: false);
    _sort = widget.initialCommentSort;
    _lastJwt = _authService.jwt;
    _highlightCommentId =
        widget.initialCommentId ?? widget.threadRoot?.comment.id;

    _scrollCtrl.addListener(_onScroll);
    _detailScrollPhase.addListener(_onScrollPhaseForPagination);
    _authService.addListener(_onAuthChanged);

    MediaBudgetEpoch.cancelDeferredBump();
    CommentListMemoryPolicy.boostImageCache();

    final hasCached = _seedCachedCommentsQuiet();
    unawaited(_loadPage(1, keepExisting: hasCached));
    unawaited(_markPostAsReadIfNeeded());
    _openGate.schedule(
      isMounted: () => mounted,
      onSettled: _revealAfterOpenSettle,
    );
  }

  bool _seedCachedCommentsQuiet() {
    final cached = _commentPageCache.read(
      postId: _postView.post.id,
      threadRootId: widget.threadRoot?.comment.id,
      sort: _sort,
      sessionId: _commentCacheSessionId,
    );
    if (cached == null) return false;
    _seedPage1Quiet(
      comments: cached.comments,
      contextParent: cached.parentComment,
      hasMore: cached.hasMore,
    );
    _isLoading = true;
    return true;
  }

  void _seedPage1Quiet({
    required List<CommentView> comments,
    CommentView? contextParent,
    required bool hasMore,
  }) {
    _memory.clear();
    _prefetchedMediaUrls.clear();
    _thread.seedQuiet(
      pageComments: comments,
      contextParent: contextParent,
      threadRoot: widget.threadRoot,
    );
    _syncThreadDisplayRoot();
    _thread.rebuild(notify: false);
    _page = 1;
    _hasMore = hasMore;
  }

  void _revealAfterOpenSettle() {
    if (!mounted) return;
    _resolvePostImageRatio(allowNetworkProbe: true);

    final updatedPost = _deferredUpdatedPost;
    _deferredUpdatedPost = null;
    final deferredError = _deferredLoadError;
    _deferredLoadError = null;

    setState(() {
      if (updatedPost != null) {
        _postView = updatedPost;
        _votes.postVote.value = updatedPost.myVote ?? 0;
        _votes.postSaved.value = updatedPost.saved;
        _headerMemoKey = null;
        _resolvePostImageRatio(allowNetworkProbe: true);
      }
      if (deferredError != null) {
        _loadError = deferredError;
        _isLoading = false;
      } else if (_rows.isNotEmpty || _page1Resolved) {
        _isLoading = false;
        _loadError = null;
      }
    });

    if (!_isLoading) {
      final targetId = widget.initialCommentId ?? widget.threadRoot?.comment.id;
      if (targetId != null && !_didRunTargetScroll) {
        unawaited(_scrollToTargetComment(targetId, _generation));
      }
      if (_hasMore) _checkBufferAfterFrame();
    }

    NavPerfLog.endSession(reason: 'open_settled');
  }

  Future<void> _markPostAsReadIfNeeded() async {
    if (!_authService.isLoggedIn) return;
    final postId = _postView.post.id;
    if (postId <= 0) return;
    if (_postView.read) {
      ref.read(sessionReadPostIdsProvider.notifier).add(postId);
      return;
    }

    ref.read(sessionReadPostIdsProvider.notifier).add(postId);
    try {
      await ref
          .read(postRepositoryProvider)
          .markAsRead(postIds: [postId], read: true);
      if (!mounted) return;
      if (!_postView.read) {
        await _openGate.whenSettled;
        if (!mounted || _postView.read) return;
        setState(() => _postView = _postView.copyWith(read: true));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    final postId = widget.postView.post.id;
    _openGate.dispose();
    _deferredUpdatedPost = null;
    _deferredLoadError = null;
    _authService.removeListener(_onAuthChanged);
    _detailScrollPhase.removeListener(_onScrollPhaseForPagination);
    _scrollDebounce?.cancel();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _barHidePixels.dispose();
    _phaseController.dispose();
    _detailScrollPhase.dispose();
    _cancelRatioProbe();
    _memory.clear();
    _votes.dispose();
    _prefetchedMediaUrls.clear();
    final lastDetail = CommentListMemoryPolicy.restoreImageCache();
    if (lastDetail) {
      softRecoverMediaBudgets(reArmFeedWhenIdle: true);
    } else {
      recoverMediaBudgets(notify: false, abandonInFlight: false);
    }
    if (NavPerfLog.enabled) {
      Future<void>.delayed(mediaRouteTransitionQuiet, () {
        NavPerfLog.endSession(reason: 'pop_settled_$postId');
      });
    }
    super.dispose();
  }

  void _onScrollPhaseForPagination() {
    if (_detailScrollPhase.value != FeedScrollPhase.idle) return;
    if (_scrollCtrl.hasClients &&
        _scrollCtrl.position.isScrollingNotifier.value) {
      return;
    }
    _checkBufferAfterFrame();
    _precacheNearbyCommentMedia();
  }

  void _precacheNearbyCommentMedia() {
    if (!mounted || !_scrollCtrl.hasClients || _rows.isEmpty) return;
    if (_detailScrollPhase.value != FeedScrollPhase.idle) return;
    if (_scrollCtrl.position.isScrollingNotifier.value) return;

    final pos = _scrollCtrl.position;
    final avgH = _memory.averageHeight(fallback: 130);
    final contentPixels = (pos.pixels - 280).clamp(0.0, double.infinity);
    final first = (contentPixels / avgH).floor().clamp(0, _rows.length - 1);
    final last = ((contentPixels + pos.viewportDimension) / avgH).ceil().clamp(
      0,
      _rows.length - 1,
    );
    final start = (first - 2).clamp(0, _rows.length - 1);
    final end = (last + 5).clamp(0, _rows.length);
    final cacheW = inPageMediaMemCacheWidth(context);

    var scheduled = 0;
    const maxPerIdle = 3;
    for (var i = start; i < end && scheduled < maxPerIdle; i++) {
      final cv = _rows[i].cv;
      final vm = _bodyVms.obtain(
        commentId: cv.comment.id,
        content: cv.comment.content,
      );
      if (!vm.hasMedia) continue;
      for (final m in vm.media) {
        if (scheduled >= maxPerIdle) break;
        final url = m.isImage ? m.url : (m.thumbnailUrl ?? '');
        if (url.isEmpty || !_prefetchedMediaUrls.add(url)) continue;
        scheduled++;
        final captured = url;
        ImageDecodeBudget.schedule((done) {
          if (!mounted) {
            done();
            return;
          }
          precacheMediaImage(
            context,
            captured,
            cacheWidth: cacheW,
          ).whenComplete(done);
        });
      }
    }
    if (_prefetchedMediaUrls.length > 160) {
      _prefetchedMediaUrls.removeAll(
        _prefetchedMediaUrls.take(_prefetchedMediaUrls.length - 160),
      );
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final jwt = _authService.jwt;
    if (jwt == _lastJwt) return;
    final wasLoggedIn = _lastJwt != null && _lastJwt!.isNotEmpty;
    final nowLoggedIn = jwt != null && jwt.isNotEmpty;
    _lastJwt = jwt;
    _commentPageCache.clear();

    if (wasLoggedIn && !nowLoggedIn) {
      _votes.clearCommentVotes();
      _votes.postVote.value = 0;
      _votes.postSaved.value = false;
      setState(() {
        _postView = _postView.copyWith(
          myVote: null,
          saved: false,
          subscribed: 'NotSubscribed',
        );
      });
      _loadPage(1);
    } else if (!wasLoggedIn && nowLoggedIn) {
      _loadPage(1);
    }
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  int get _commentCacheSessionId => (_authService.jwt ?? '').hashCode;

  void _addFirstPageComments(
    List<CommentView> comments,
    CommentView? contextParent,
  ) {
    _thread.seedQuiet(
      pageComments: comments,
      contextParent: contextParent,
      threadRoot: widget.threadRoot,
    );
    _syncThreadDisplayRoot();
    _thread.rebuild(notify: true);
  }

  void _syncThreadDisplayRoot() {
    if (widget.threadRoot == null) {
      _thread.threadDisplayRootId = null;
      return;
    }
    final focused = widget.threadRoot!.comment;
    final directParentId = focused.parentId;
    _thread.threadDisplayRootId =
        (directParentId != null && _thread.contains(directParentId))
        ? directParentId
        : focused.id;
  }

  void _writePage1Cache(
    List<CommentView> comments,
    CommentView? contextParent,
  ) {
    _commentPageCache.write(
      postId: _postView.post.id,
      threadRootId: widget.threadRoot?.comment.id,
      sort: _sort,
      sessionId: _commentCacheSessionId,
      comments: comments,
      parentComment: contextParent,
      hasMore: comments.length >= _kPageSize,
    );
  }

  Future<void> _loadPage(int page, {bool keepExisting = false}) async {
    final gen = page == 1 ? ++_generation : _generation;
    final commentsRepo = ref.read(commentRepositoryProvider);
    final postsRepo = ref.read(postRepositoryProvider);

    if (page == 1) {
      _page1Resolved = false;
      _deferredLoadError = null;
      if (!_openGate.settled) {
        if (!keepExisting) {
          _thread.clear(notify: false);
          _memory.clear();
          _prefetchedMediaUrls.clear();
        }
        _isLoading = true;
        _isLoadingMore = false;
        _loadError = null;
        _loadMoreError = null;
      } else {
        setState(() {
          _isLoading = !keepExisting;
          _isLoadingMore = false;
          _loadError = null;
          _loadMoreError = null;
          if (!keepExisting) {
            _thread.clear(notify: false);
            _memory.clear();
            _prefetchedMediaUrls.clear();
          }
        });
      }
    } else {
      if (_isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
        _loadMoreError = null;
      });
    }

    try {
      final commentsFuture = commentsRepo.listForPost(
        postId: _postView.post.id,
        parentId: widget.threadRoot?.comment.id,
        sort: _sort.value,
        page: page,
        limit: _kPageSize,
        maxDepth: _kApiMaxDepth,
      );

      Future<PostView?> postFuture = Future.value(null);
      if (page == 1) {
        postFuture = postsRepo
            .getPost(_postView.post.id)
            .then<PostView?>((post) => post, onError: (_) => null);
      }

      Future<CommentView?> parentCommentFuture = Future.value(null);
      if (page == 1 && widget.threadRoot != null) {
        final directParentId = widget.threadRoot!.comment.parentId;
        if (directParentId != null) {
          parentCommentFuture = commentsRepo
              .get(directParentId)
              .then<CommentView?>((c) => c, onError: (_) => null);
        }
      }

      final results = await Future.wait([
        commentsFuture,
        postFuture,
        parentCommentFuture,
      ]);

      final fetched = results[0] as List<CommentView>;
      final updatedPost = results[1] as PostView?;
      final contextParent = results[2] as CommentView?;

      if (!mounted) return;
      if (gen != _generation) return;

      if (page == 1 && !_openGate.settled) {
        _seedPage1Quiet(
          comments: fetched,
          contextParent: contextParent,
          hasMore: fetched.length >= _kPageSize,
        );
        _writePage1Cache(fetched, contextParent);
        _page1Resolved = true;
        _deferredLoadError = null;
        if (updatedPost != null) _deferredUpdatedPost = updatedPost;
        return;
      }

      if (page > 1 && _scrollBusy) {
        await _waitUntilScrollIdle();
        if (!mounted || gen != _generation) return;
      }

      if (page == 1) {
        _commitPage1(
          fetched: fetched,
          updatedPost: updatedPost,
          contextParent: contextParent,
          gen: gen,
        );
        return;
      }

      final anchor = _captureScrollAnchor();
      final newCount = _thread.mergeComments(fetched);

      setState(() {
        _page = page;
        _hasMore = fetched.length >= _kPageSize && newCount > 0;
        _isLoadingMore = false;
        _loadMoreError = null;
      });

      if (anchor != null) _restoreScrollAnchor(anchor);
      if (_hasMore) _checkBufferAfterFrame();
    } catch (e) {
      if (!mounted || gen != _generation) return;
      if (page == 1 && !_openGate.settled) {
        _page1Resolved = true;
        if (_commentMap.isEmpty) {
          _deferredLoadError = formatError(e);
        }
        return;
      }
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (page == 1 && !keepExisting && _commentMap.isEmpty) {
          _loadError = formatError(e);
        } else {
          _loadMoreError = page > 1 ? formatError(e) : null;
        }
      });
    }
  }

  void _commitPage1({
    required List<CommentView> fetched,
    PostView? updatedPost,
    CommentView? contextParent,
    required int gen,
  }) {
    if (!mounted || gen != _generation) return;
    _memory.clear();
    _prefetchedMediaUrls.clear();
    _addFirstPageComments(fetched, contextParent);
    _page1Resolved = true;
    _deferredLoadError = null;
    _deferredUpdatedPost = null;

    setState(() {
      if (updatedPost != null) {
        _postView = updatedPost;
        _votes.postVote.value = updatedPost.myVote ?? 0;
        _votes.postSaved.value = updatedPost.saved;
        _headerMemoKey = null;
        _resolvePostImageRatio(allowNetworkProbe: true);
      }
      _page = 1;
      _hasMore = fetched.length >= _kPageSize;
      _isLoading = false;
      _isLoadingMore = false;
      _loadError = null;
      _loadMoreError = null;
    });
    _writePage1Cache(fetched, contextParent);

    if (_hasMore) _checkBufferAfterFrame();

    final targetId = widget.initialCommentId ?? widget.threadRoot?.comment.id;
    if (targetId != null && !_didRunTargetScroll) {
      unawaited(_scrollToTargetComment(targetId, gen));
    }
  }

  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    await runWithMediaBudgetRecovery(
      () async {
        _prefetchedMediaUrls.clear();
        await _loadPage(1, keepExisting: _commentMap.isNotEmpty);
      },
      isMounted: () => mounted,
    );
  }

  void _loadMore() {
    if (!_hasMore || _isLoading || _isLoadingMore) return;
    _loadPage(_page + 1);
  }

  // ── Scroll helpers ────────────────────────────────────────────────────────

  Future<void> _scrollToTargetComment(int targetId, int gen) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || gen != _generation) return;

    for (var attempt = 0; attempt < 30; attempt++) {
      if (!mounted || gen != _generation) return;

      final ctx = _findCommentContext(targetId);
      if (ctx != null && ctx.mounted) {
        await Scrollable.ensureVisible(
          ctx,
          alignment: 0.12,
          duration: Duration(milliseconds: attempt == 0 ? 480 : 320),
          curve: Curves.easeOutCubic,
        );
        _didRunTargetScroll = true;
        return;
      }

      final rowIdx = _rowIndexById[targetId];
      if (rowIdx == null) {
        _didRunTargetScroll = true;
        return;
      }
      if (!_scrollCtrl.hasClients) {
        await WidgetsBinding.instance.endOfFrame;
        continue;
      }

      final pos = _scrollCtrl.position;
      final showAds =
          ref.read(adsSettingsProvider).showAds && widget.threadRoot == null;
      final body = _thread.bodyEntries(showAds: showAds);
      final displayIdx = _thread.displayIndexForRow(rowIdx, showAds: showAds) ??
          rowIdx;
      final listIndex = displayIdx + 1;
      final contentW = MediaQuery.sizeOf(context).width - 32;
      final maxMediaH = MediaQuery.sizeOf(context).height * 0.55;
      final estimated =
          estimateListOffsetForIndex(
            listIndex: listIndex,
            leadingCount: 1,
            body: body,
            rows: _rows,
            bodyVms: _bodyVms,
            memory: _memory,
            contentWidth: contentW,
            headerHeight: _memory.headerHeight ?? kCommentListHeaderFallback,
            maxMediaHeight: maxMediaH,
          ) +
          attempt * 40.0;
      final next = estimated
          .clamp(pos.minScrollExtent, pos.maxScrollExtent)
          .toDouble();

      if ((pos.pixels - next).abs() < 2 &&
          pos.pixels >= pos.maxScrollExtent - 2) {
        _didRunTargetScroll = true;
        return;
      }

      _scrollCtrl.jumpTo(next);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    _didRunTargetScroll = true;
  }

  void _onTargetHighlightComplete(int commentId) {
    if (!mounted) return;
    if (_highlightCommentId == commentId) {
      setState(() => _highlightCommentId = null);
    }
  }

  void _onScroll() {
    if (!mounted) return;
    final pos = _scrollCtrl.position.pixels;
    final delta = pos - _lastScrollPos;
    _lastScrollPos = pos;

    if (delta != 0) {
      final metrics = _scrollCtrl.position;
      final atEdge =
          pos < metrics.minScrollExtent || pos > metrics.maxScrollExtent;
      if (!atEdge) {
        double next;
        if (pos <= 0) {
          next = 0;
        } else {
          next = (_barHidePixels.value + delta).clamp(
            0.0,
            _commentBarContentHeight,
          );
          if (next > pos) {
            next = pos.clamp(0.0, _commentBarContentHeight);
          }
        }
        if (next != _barHidePixels.value) {
          _barHidePixels.value = next;
        }
      }
    }

    if (_scrollCtrl.hasClients) {
      _phaseController.onScrollMetrics(_scrollCtrl.position);
    }

    if (!_hasMore || !_scrollCtrl.hasClients) return;
    if (_detailScrollPhase.value != FeedScrollPhase.idle) return;
    if (_scrollCtrl.position.isScrollingNotifier.value) return;
    final vp = _scrollCtrl.position.viewportDimension;
    final buffer = math.max(900.0, vp * 2.0);
    if (_scrollCtrl.position.extentAfter <= buffer) {
      _scrollDebounce?.cancel();
      _scrollDebounce = Timer(const Duration(milliseconds: 200), () {
        if (!mounted || !_hasMore || !_scrollCtrl.hasClients) return;
        if (_detailScrollPhase.value != FeedScrollPhase.idle) return;
        if (_scrollCtrl.position.isScrollingNotifier.value) return;
        final ext = _scrollCtrl.position.extentAfter;
        final b = math.max(
          800.0,
          _scrollCtrl.position.viewportDimension * 1.75,
        );
        if (ext <= b) _loadMore();
      });
    }
  }

  void _checkBufferAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollCtrl.hasClients || !_hasMore) return;
      if (_detailScrollPhase.value != FeedScrollPhase.idle) return;
      if (_scrollCtrl.position.isScrollingNotifier.value) return;
      final b = math.max(800.0, _scrollCtrl.position.viewportDimension * 1.75);
      if (!_isLoadingMore && _scrollCtrl.position.extentAfter <= b) {
        _loadMore();
      }
    });
  }

  bool get _scrollBusy {
    if (_detailScrollPhase.value != FeedScrollPhase.idle) return true;
    if (_scrollCtrl.hasClients &&
        _scrollCtrl.position.isScrollingNotifier.value) {
      return true;
    }
    return false;
  }

  Future<void> _waitUntilScrollIdle() async {
    if (!_scrollBusy) return;
    final completer = Completer<void>();
    void tryComplete() {
      if (!mounted) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      if (!_scrollBusy && !completer.isCompleted) {
        completer.complete();
      }
    }

    void onPhase() => tryComplete();
    void onScroll() => tryComplete();

    _detailScrollPhase.addListener(onPhase);
    _scrollCtrl.addListener(onScroll);
    Timer? poll;
    poll = Timer.periodic(const Duration(milliseconds: 32), (_) {
      tryComplete();
      if (completer.isCompleted) poll?.cancel();
    });
    try {
      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    } finally {
      poll.cancel();
      _detailScrollPhase.removeListener(onPhase);
      _scrollCtrl.removeListener(onScroll);
    }
  }

  _CommentScrollAnchor? _captureScrollAnchor() {
    if (!_scrollCtrl.hasClients) return null;
    return _CommentScrollAnchor(pixels: _scrollCtrl.position.pixels);
  }

  void _restoreScrollAnchor(_CommentScrollAnchor anchor) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollCtrl.hasClients) return;
      final p = _scrollCtrl.position;
      final target = anchor.pixels.clamp(p.minScrollExtent, p.maxScrollExtent);
      if ((p.pixels - target).abs() < 0.5) return;
      _scrollCtrl.jumpTo(target);
    });
  }

  Key _keyFor(int id) => _thread.keyFor(id);

  BuildContext? _findCommentContext(int id) {
    final target = ValueKey<int>(id);
    final root = _listKey.currentContext as Element?;
    if (root == null) return null;
    BuildContext? found;
    void visitor(Element element) {
      if (found != null) return;
      if (element.widget.key == target) {
        found = element;
        return;
      }
      element.visitChildren(visitor);
    }

    root.visitChildren(visitor);
    return found;
  }

  int? _findChildIndex(Key key) {
    final id =
        _thread.idsByKey[key] ?? (key is ValueKey<int> ? key.value : null);
    if (id == null) return null;
    final rowIdx = _rowIndexById[id];
    if (rowIdx == null) return null;
    final showAds =
        ref.read(adsSettingsProvider).showAds && widget.threadRoot == null;
    if (!showAds) return rowIdx;
    return _thread.displayIndexForRow(rowIdx, showAds: true);
  }

  // ── Vote / save ───────────────────────────────────────────────────────────

  int _effectiveVote(CommentView cv) =>
      _votes.effectiveCommentVote(cv.comment.id, cv.myVote);

  Future<void> _toggleCommentUpvote(CommentView cv) async {
    if (!mounted) return;
    if (!_authService.isLoggedIn) {
      _showSnack('Log in to vote');
      return;
    }
    final cur = _effectiveVote(cv);
    final next = cur == 1 ? 0 : 1;
    _votes.setCommentVote(cv.comment.id, next);
    try {
      await ref
          .read(commentRepositoryProvider)
          .vote(commentId: cv.comment.id, score: next);
    } catch (e) {
      if (mounted) {
        _showSnack('Vote failed: $e');
        if (_votes.commentVoteListenable(cv.comment.id).value == next) {
          _votes.setCommentVote(cv.comment.id, cur);
        }
      }
    }
  }

  Future<void> _toggleCommentDownvote(CommentView cv) async {
    if (!mounted) return;
    if (!_authService.isLoggedIn) {
      _showSnack('Log in to vote');
      return;
    }
    final cur = _effectiveVote(cv);
    final next = cur == -1 ? 0 : -1;
    _votes.setCommentVote(cv.comment.id, next);
    try {
      await ref
          .read(commentRepositoryProvider)
          .vote(commentId: cv.comment.id, score: next);
    } catch (e) {
      if (mounted) {
        _showSnack('Vote failed: $e');
        if (_votes.commentVoteListenable(cv.comment.id).value == next) {
          _votes.setCommentVote(cv.comment.id, cur);
        }
      }
    }
  }

  Future<void> _togglePostVote({required bool upvote}) async {
    if (!_authService.isLoggedIn &&
        widget.onUpvote == null &&
        widget.onDownvote == null) {
      _showSnack('Log in to vote');
      return;
    }
    final cur = _votes.postVote.value;
    final next = upvote ? (cur == 1 ? 0 : 1) : (cur == -1 ? 0 : -1);
    _votes.postVote.value = next;

    if (widget.onUpvote != null || widget.onDownvote != null) {
      final cb = upvote ? widget.onUpvote : widget.onDownvote;
      if (cb != null) {
        final ok = await cb();
        if (!ok && mounted && _votes.postVote.value == next) {
          _votes.postVote.value = cur;
        }
      }
      return;
    }
    try {
      await ref
          .read(postRepositoryProvider)
          .vote(postId: _postView.post.id, score: next);
    } catch (e) {
      if (mounted && _votes.postVote.value == next) {
        _votes.postVote.value = cur;
      }
    }
  }

  Future<void> _togglePostSave() async {
    if (!_authService.isLoggedIn && widget.onSave == null) {
      _showSnack('Log in to save post');
      return;
    }
    final cur = _votes.postSaved.value;
    final next = !cur;
    _votes.postSaved.value = next;
    if (widget.onSave != null) {
      final ok = await widget.onSave!();
      if (!ok && mounted && _votes.postSaved.value == next) {
        _votes.postSaved.value = cur;
      } else if (ok && mounted) {
        _showSnack(next ? 'Post saved' : 'Post unsaved');
      }
      return;
    }
    try {
      await ref
          .read(postRepositoryProvider)
          .save(postId: _postView.post.id, save: next);
      _showSnack(next ? 'Post saved' : 'Post unsaved');
    } catch (e) {
      if (mounted && _votes.postSaved.value == next) {
        _votes.postSaved.value = cur;
      }
      _showSnack(
        'Failed to ${next ? "save" : "unsave"} post: ${formatError(e)}',
      );
    }
  }

  // ── Navigation / mutations ────────────────────────────────────────────────

  Future<void> _openCommentComposer({CommentView? parentComment}) async {
    if (_authService.jwt == null) {
      _showSnack('Log in to post a comment');
      return;
    }
    final result = await Navigator.of(context).push<CommentView>(
      MaterialPageRoute(
        builder: (_) => CommentComposeScreen(
          postView: _postView,
          parentComment: parentComment,
        ),
      ),
    );
    if (result != null && mounted) {
      _thread.upsertComment(result, preferFront: parentComment == null);
      _showSnack(parentComment != null ? 'Reply posted' : 'Comment posted');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = _findCommentContext(result.comment.id);
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _openCommentEditor(CommentView commentView) async {
    if (_authService.jwt == null) {
      _showSnack('Log in to edit comment');
      return;
    }
    final result = await Navigator.of(context).push<CommentView>(
      MaterialPageRoute(
        builder: (_) => CommentComposeScreen(
          postView: _postView,
          editingComment: commentView,
        ),
      ),
    );
    if (result != null && mounted) {
      _thread.upsertComment(result);
      _showSnack('Comment updated');
    }
  }

  bool get _isMyPost =>
      _authService.isMe(
        personId: _postView.creator.id,
        username: _postView.creator.name,
      );

  bool _isMyComment(CommentView cv) =>
      _authService.isMe(personId: cv.creator.id, username: cv.creator.name);

  Future<void> _openPostEditor() async {
    if (_authService.jwt == null) {
      _showSnack('Log in to edit post');
      return;
    }
    if (_postView.post.deleted) {
      _showSnack('Restore the post before editing');
      return;
    }
    final result = await Navigator.of(context).push<PostView>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(editingPost: _postView),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _postView = result;
        _votes.postVote.value = result.myVote ?? _votes.postVote.value;
        _votes.postSaved.value = result.saved;
        _resolvePostImageRatio();
      });
      _showSnack('Post updated');
    }
  }

  Future<void> _openCrossPost() async {
    if (_authService.jwt == null) {
      _showSnack('Log in to cross-post');
      return;
    }
    final result = await Navigator.of(context).push<PostView>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(crossPostFrom: _postView),
      ),
    );
    if (result != null && mounted) {
      Navigator.of(context).push(
        postDetailRoute(builder: (_) => PostDetailScreen(postView: result)),
      );
    }
  }

  Future<void> _deletePost() async {
    final isDeleted = _postView.post.deleted;
    if (_authService.jwt == null) {
      _showSnack(
        isDeleted ? 'Log in to restore post' : 'Log in to delete post',
      );
      return;
    }
    final confirm = await showPostDetailConfirmDialog(
      context: context,
      title: isDeleted ? 'Restore post?' : 'Delete post?',
      body: isDeleted
          ? 'Are you sure you want to restore this post?'
          : 'Are you sure you want to delete this post? You can restore it later.',
      confirmLabel: isDeleted ? 'Restore' : 'Delete',
      confirmColor: isDeleted
          ? const Color(0xFF4CAF50)
          : const Color(0xFFE53935),
    );
    if (!confirm) return;
    try {
      final updated = await ref
          .read(postRepositoryProvider)
          .deletePost(postId: _postView.post.id, deleted: !isDeleted);
      if (!mounted) return;
      setState(() {
        _postView = updated;
        _votes.postVote.value = updated.myVote ?? _votes.postVote.value;
        _votes.postSaved.value = updated.saved;
      });
      _showSnack(isDeleted ? 'Post restored' : 'Post deleted');
    } catch (e) {
      if (mounted) {
        _showSnack(
          'Failed to ${isDeleted ? "restore" : "delete"} post: ${formatError(e)}',
        );
      }
    }
  }

  Future<void> _deleteComment(CommentView commentView) async {
    final isDeleted = commentView.comment.deleted;
    if (_authService.jwt == null) {
      _showSnack(
        isDeleted ? 'Log in to restore comment' : 'Log in to delete comment',
      );
      return;
    }
    final confirm = await showPostDetailConfirmDialog(
      context: context,
      title: isDeleted ? 'Restore comment?' : 'Delete comment?',
      body: isDeleted
          ? 'Are you sure you want to restore this comment?'
          : 'Are you sure you want to delete this comment? This action cannot be undone.',
      confirmLabel: isDeleted ? 'Restore' : 'Delete',
      confirmColor: isDeleted
          ? const Color(0xFF4CAF50)
          : const Color(0xFFE53935),
    );
    if (!confirm) return;
    try {
      final updated = await ref.read(commentRepositoryProvider).delete(
            commentId: commentView.comment.id,
            deleted: !isDeleted,
          );
      if (mounted) {
        _thread.upsertComment(updated);
        _showSnack(isDeleted ? 'Comment restored' : 'Comment deleted');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          'Failed to ${isDeleted ? "restore" : "delete"} comment: ${formatError(e)}',
        );
      }
    }
  }

  Future<void> _reportComment(CommentView commentView) async {
    if (_authService.jwt == null) {
      _showSnack('Log in to report comment');
      return;
    }
    final reason = await showPostDetailReportDialog(
      context: context,
      title: 'Report comment',
      prompt: 'Why are you reporting this comment?',
    );
    if (reason == null) return;
    if (reason.isEmpty) {
      _showSnack('Reason cannot be empty');
      return;
    }
    try {
      await ref.read(commentRepositoryProvider).report(
            commentId: commentView.comment.id,
            reason: reason,
          );
      _showSnack('Comment reported successfully');
    } catch (e) {
      _showSnack('Failed to report comment: ${formatError(e)}');
    }
  }

  Future<void> _blockUser(Person creator) async {
    if (_authService.jwt == null) {
      _showSnack('Log in to block user');
      return;
    }
    final confirm = await showPostDetailConfirmDialog(
      context: context,
      title: 'Block u/${creator.name}?',
      body:
          'Are you sure you want to block u/${creator.name}? You will no longer see their comments or posts.',
      confirmLabel: 'Block',
    );
    if (!confirm) return;
    try {
      await ref.read(commentRepositoryProvider).blockPerson(
            personId: creator.id,
            block: true,
          );
      _showSnack('Blocked u/${creator.name}');
      _loadPage(1);
    } catch (e) {
      _showSnack('Failed to block user: ${formatError(e)}');
    }
  }

  Future<void> _openThreadScreen(CommentView root) async {
    await Navigator.of(context).push<void>(
      postDetailRoute(
        builder: (_) => PostDetailScreen(
          postView: _postView,
          threadRoot: root,
          initialCommentSort: _sort,
          commentVoteState: _votes.snapshotCommentVotes(),
          initialVote: _votes.postVote.value,
          initialSaved: _votes.postSaved.value,
        ),
      ),
    );
  }

  void _showParentComment(CommentView cv) {
    final parentId = cv.comment.parentId;
    if (parentId == null) return;
    final parent = _commentMap[parentId];
    if (parent == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final sheetCommentId = parent.comment.id;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: CommentCard(
                    commentView: parent,
                    authService: _authService,
                    bodyVm: _bodyVms.obtain(
                      commentId: parent.comment.id,
                      content: parent.comment.content,
                    ),
                    voteListenable: _votes.commentVoteListenable(
                      sheetCommentId,
                    ),
                    isCollapsed: false,
                    showTopBorder: false,
                    onUpvote: () => _toggleCommentUpvote(parent),
                    onDownvote: () => _toggleCommentDownvote(parent),
                    onReply: () {
                      Navigator.pop(ctx);
                      _openCommentComposer(parentComment: parent);
                    },
                    onLinkTap: _openLink,
                    onToggleCollapse: () {},
                    onEdit: (_isMyComment(parent) && !parent.comment.removed)
                        ? () {
                            Navigator.pop(ctx);
                            _openCommentEditor(parent);
                          }
                        : null,
                    onDelete: (_isMyComment(parent) && !parent.comment.removed)
                        ? () {
                            Navigator.pop(ctx);
                            _deleteComment(parent);
                          }
                        : null,
                    onReport: () {
                      Navigator.pop(ctx);
                      _reportComment(parent);
                    },
                    onBlock: () {
                      Navigator.pop(ctx);
                      _blockUser(parent.creator);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openLink(String? link) async {
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack('Could not open link');
    }
  }

  Future<void> _copyLink(String? link) async {
    if (link == null || link.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: link));
    _showSnack('Link copied');
  }

  int _decodedImageWidth(BuildContext context) =>
      inPageMediaMemCacheWidth(context);

  int _bodyChildCount(List<CommentDisplayEntry> body) {
    if (_isLoading || _loadError != null) return 1;
    if (_rows.isEmpty) return 1;
    final hasFooter = _isLoadingMore || _loadMoreError != null || !_hasMore;
    return body.length + (hasFooter ? 1 : 0);
  }

  Widget _buildCommentRow(CommentFlatRow row, {CommentBodyVm? bodyVm}) {
    final parentId = row.cv.comment.parentId;
    final hasParent = parentId != null && _commentMap.containsKey(parentId);
    final commentId = row.cv.comment.id;
    final resolvedVm =
        bodyVm ??
        _bodyVms.obtain(
          commentId: row.cv.comment.id,
          content: row.cv.comment.content,
        );

    return PostDetailCommentRow(
      row: row,
      bodyVm: resolvedVm,
      voteListenable: _votes.commentVoteListenable(commentId),
      hasParent: hasParent,
      isCollapsed: _thread.isCollapsed(commentId),
      authService: _authService,
      highlighted: commentId == _highlightCommentId,
      onUpvote: () => _toggleCommentUpvote(row.cv),
      onDownvote: () => _toggleCommentDownvote(row.cv),
      onReply: () => _openCommentComposer(parentComment: row.cv),
      onLinkTap: _openLink,
      onToggleCollapse: () => _thread.toggleCollapse(commentId),
      onRevealParent: () => _showParentComment(row.cv),
      onContinueThread: () => _openThreadScreen(row.cv),
      onEdit: (_isMyComment(row.cv) && !row.cv.comment.removed)
          ? () => _openCommentEditor(row.cv)
          : null,
      onDelete: (_isMyComment(row.cv) && !row.cv.comment.removed)
          ? () => _deleteComment(row.cv)
          : null,
      onReport: () => _reportComment(row.cv),
      onBlock: () => _blockUser(row.cv.creator),
      onHighlightComplete: commentId == _highlightCommentId
          ? () => _onTargetHighlightComplete(commentId)
          : null,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isThreadView = widget.threadRoot != null;
    final showAds = ref.watch(adsSettingsProvider.select((s) => s.showAds));
    final thread = ref.watch(commentThreadControllerProvider(_threadScope));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isThreadView),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _phaseController.onNotification,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                key: _listKey,
                controller: _scrollCtrl,
                cacheExtent: CommentListMemoryPolicy.listCacheExtent,
                slivers: [
                  SliverToBoxAdapter(
                    child: HeaderKeepAlive(
                      policy: _memory,
                      child: RepaintBoundary(
                        child: _buildPostHeader(),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SliverToBoxAdapter(child: CommentTreeLoadingState())
                  else if (_loadError != null)
                    SliverToBoxAdapter(
                      child: CommentTreeErrorState(onRetry: _refresh),
                    )
                  else if (_rows.isEmpty)
                    const SliverToBoxAdapter(child: CommentTreeEmptyState())
                  else
                    ListenableBuilder(
                      listenable: thread,
                      builder: (context, _) {
                        final effectiveShow =
                            showAds && widget.threadRoot == null;
                        final body =
                            thread.bodyEntries(showAds: effectiveShow);
                        final bottomPad =
                            MediaQuery.of(context).padding.bottom + 64;
                        return SliverPadding(
                          padding: EdgeInsets.only(bottom: bottomPad),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, index) {
                                if (index >= body.length) {
                                  if (_isLoadingMore) {
                                    return const CommentLoadMoreIndicator();
                                  }
                                  if (_loadMoreError != null) {
                                    return CommentLoadMoreError(
                                      onRetry: _loadMore,
                                    );
                                  }
                                  return const CommentEndMarker();
                                }
                                final entry = body[index];
                                if (entry.isAd) {
                                  return RepaintBoundary(
                                    child: InFeedNativeAd(
                                      key: ValueKey(
                                        'comment-ad-slot-${entry.adSlot}',
                                      ),
                                      placement: InFeedAdPlacement.commentList,
                                      slot: entry.adSlot!,
                                      deferUntilNearViewport: true,
                                      scrollPhaseListenable: _detailScrollPhase,
                                      keepHeightOnFailure: true,
                                      farDisposeWhenOffscreen: true,
                                    ),
                                  );
                                }
                                final row = _rows[entry.rowIndex!];
                                final bodyVm = _thread.bodyVmFor(row.cv);
                                return KeyedSubtree(
                                  key: _keyFor(row.cv.comment.id),
                                  child: CommentKeepAlive(
                                    commentId: row.cv.comment.id,
                                    hasMedia: bodyVm.hasMedia,
                                    policy: _memory,
                                    child: _buildCommentRow(
                                      row,
                                      bodyVm: bodyVm,
                                    ),
                                  ),
                                );
                              },
                              childCount: _bodyChildCount(body),
                              findChildIndexCallback: _findChildIndex,
                              addAutomaticKeepAlives: true,
                              addRepaintBoundaries: true,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          PostDetailCommentBar(
            hidePixels: _barHidePixels,
            contentHeight: _commentBarContentHeight,
            onTap: () => _openCommentComposer(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool isThreadView) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: AppBarChrome.height,
      leadingWidth: AppBarChrome.leadingWidth,
      actionsPadding: AppBarChrome.actionsPadding,
      leading: IconButton(
        iconSize: AppBarChrome.iconSize,
        icon: const Icon(
          MingCuteIcons.mgc_left_line,
          color: PostDetailTokens.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: isThreadView
          ? const Text(
              'Comment thread',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PostDetailTokens.textPrimary,
              ),
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommunityDetailScreen(
                      communityId: _postView.community.id,
                      communityName: _postView.community.name,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NetworkAvatar(
                    size: PostDetailTokens.avatar,
                    imageUrl: _postView.community.icon,
                    name: _postView.community.title.isNotEmpty
                        ? _postView.community.title
                        : _postView.community.name,
                  ),
                  const SizedBox(width: PostDetailTokens.spaceXs),
                  Flexible(
                    child: Text(
                      'c/${_postView.community.name}',
                      style: const TextStyle(
                        fontSize: PostDetailTokens.fontMeta,
                        fontWeight: FontWeight.w700,
                        color: PostDetailTokens.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
      actions: isThreadView
          ? [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    postDetailRoute(
                      builder: (_) => PostDetailScreen(postView: _postView),
                    ),
                  );
                },
                child: const Text(
                  'Full Post',
                  style: TextStyle(
                    color: AppColors.action,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ]
          : [
              IconButton(
                tooltip: 'More',
                iconSize: AppBarChrome.iconSize,
                icon: const Icon(
                  MingCuteIcons.mgc_more_2_line,
                  color: PostDetailTokens.textPrimary,
                ),
                onPressed: () => _showMoreSheet(context),
              ),
            ],
    );
  }

  Widget _buildPostHeader() {
    _ensureHeaderMemo();
    return PostDetailHeader(
      postView: _postView,
      mediaItems: _headerMedia,
      markdownBody: _headerMarkdownBody,
      resolvedImageRatio: _resolvedPostImageRatio,
      decodedImageWidth: _decodedImageWidth,
      postVoteListenable: _votes.postVote,
      onUpvote: () => _togglePostVote(upvote: true),
      onDownvote: () => _togglePostVote(upvote: false),
      onShare: () => _copyLink(
        _postView.post.apId.isNotEmpty
            ? _postView.post.apId
            : _postView.post.url,
      ),
      onComment: _openCommentComposer,
      onLinkTap: _openLink,
    );
  }

  void _showMoreSheet(BuildContext context) {
    showPostDetailMoreSheet(
      context: context,
      isMyPost: _isMyPost,
      isDeleted: _postView.post.deleted,
      isSaved: _votes.postSaved.value,
      sortLabel: _sort.value,
      onEdit: _openPostEditor,
      onDeleteOrRestore: _deletePost,
      onToggleSave: _togglePostSave,
      onCrossPost: _openCrossPost,
      onCopyLink: () => _copyLink(
        _postView.post.apId.isNotEmpty
            ? _postView.post.apId
            : _postView.post.url,
      ),
      onSort: () => _showSortSheet(context),
    );
  }

  void _showSortSheet(BuildContext context) {
    showPostDetailSortSheet(
      context: context,
      current: _sort,
      onSelected: (s) {
        setState(() => _sort = s);
        _loadPage(1);
      },
    );
  }
}

class _CommentScrollAnchor {
  final double pixels;
  const _CommentScrollAnchor({required this.pixels});
}
