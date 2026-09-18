import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_bar_chrome.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/chat/presentation/chat_detail_screen.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/features/notifications/data/notification_repository_impl.dart';
import 'package:bluerum/features/notifications/domain/chat_thread.dart';
import 'package:bluerum/features/notifications/domain/inbox_item.dart';
import 'package:bluerum/features/notifications/domain/inbox_merge.dart';
import 'package:bluerum/features/notifications/domain/notification_repository.dart';
import 'package:bluerum/features/notifications/presentation/widgets/conversation_tile.dart';
import 'package:bluerum/features/notifications/presentation/widgets/inbox_list_states.dart';
import 'package:bluerum/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/post_detail_route.dart';
import 'package:bluerum/features/post/presentation/post_detail_screen.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';
import 'package:bluerum/shared/widgets/list/list_index_map.dart';
import 'package:bluerum/shared/widgets/media/comment_list_still_thumb.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/post_list/post_list.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

/// Inbox: Notifications (replies/mentions) + Messages tabs.
///
/// Orchestration only — domain merge/mark-read and tiles live elsewhere.
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);
  late final AuthService _auth;
  late final TabController _tabController;

  final ScrollController _notifyScrollController = ScrollController();
  final ScrollController _convoScrollController = ScrollController();

  List<InboxItem> _notifications = [];
  List<ChatThread> _convos = [];

  late bool _isLoadingNotifications;
  late bool _isLoadingMessages;
  String? _notificationError;
  String? _messageError;

  // Independent stream cursors (replies vs mentions).
  int _replyPage = 0;
  int _mentionPage = 0;
  bool _hasMoreReplies = true;
  bool _hasMoreMentions = true;
  bool _isLoadingMoreNotifications = false;
  bool _pendingLoadMoreNotifications = false;

  int _messagesPage = 1;
  bool _hasMoreMessages = true;
  bool _isLoadingMoreMessages = false;

  String? _lastJwt;
  String? _lastInstanceUrl;

  final CommentBodyVmStore _commentBodyVms = CommentBodyVmStore();
  final PostListIdlePrecache _commentIdlePrecache = PostListIdlePrecache();
  late final ValueNotifier<FeedScrollPhase> _scrollPhase;
  late final FeedScrollPhaseController _phaseController;
  Timer? _loadMoreNotifyDebounce;
  ListIndexMap? _notifyIndexMap;
  ListIndexMap? _convoIndexMap;

  bool get _hasMoreNotifications => _hasMoreReplies || _hasMoreMentions;

  int? get _currentUserId => _auth.personId;

  void _rebuildNotifyIndex() {
    _notifyIndexMap = ListIndexMap.fromStringKeys([
      for (final item in _notifications) item.listKey,
    ]);
  }

  void _rebuildConvoIndex() {
    _convoIndexMap = ListIndexMap.fromIds([
      for (final c in _convos) c.otherPerson.id,
    ]);
  }

  @override
  void initState() {
    super.initState();
    _auth = ref.read(authRepositoryProvider);
    _tabController = TabController(length: 2, vsync: this);
    _scrollPhase = ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);
    _phaseController = FeedScrollPhaseController(listenable: _scrollPhase);
    _scrollPhase.addListener(_onScrollPhaseChanged);
    _lastJwt = _auth.jwt;
    _lastInstanceUrl = _auth.activeInstanceUrl;

    final loggedIn = _auth.isLoggedIn;
    _isLoadingNotifications = loggedIn;
    _isLoadingMessages = loggedIn;

    _auth.addListener(_onAuthChanged);
    _notifyScrollController.addListener(_onNotifyScroll);
    _convoScrollController.addListener(_onConvoScroll);

    if (loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadAll());
      });
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _scrollPhase.removeListener(_onScrollPhaseChanged);
    _loadMoreNotifyDebounce?.cancel();
    _phaseController.dispose();
    _scrollPhase.dispose();
    _commentBodyVms.clear();
    _commentIdlePrecache.clear();
    _tabController.dispose();
    _notifyScrollController.removeListener(_onNotifyScroll);
    _notifyScrollController.dispose();
    _convoScrollController.removeListener(_onConvoScroll);
    _convoScrollController.dispose();
    super.dispose();
  }

  void _onScrollPhaseChanged() {
    if (!mounted) return;
    if (_scrollPhase.value != FeedScrollPhase.idle) return;
    if (_pendingLoadMoreNotifications) {
      _pendingLoadMoreNotifications = false;
      _requestLoadMoreNotificationsDebounced();
    }
    _tryIdlePrecacheComments();
  }

  void _cancelPendingNotificationLoadMore() {
    _loadMoreNotifyDebounce?.cancel();
    _pendingLoadMoreNotifications = false;
    _isLoadingMoreNotifications = false;
  }

  void _requestLoadMoreNotificationsDebounced() {
    _loadMoreNotifyDebounce?.cancel();
    _loadMoreNotifyDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_scrollPhase.value != FeedScrollPhase.idle) {
        _pendingLoadMoreNotifications = true;
        return;
      }
      if (_isLoadingMoreNotifications ||
          _isLoadingNotifications ||
          !_hasMoreNotifications) {
        return;
      }
      unawaited(_loadMoreNotifications());
    });
  }

  void _warmCommentBodyVms(Iterable<InboxItem> items) {
    for (final item in items) {
      final c = item.comment;
      _commentBodyVms.obtain(commentId: c.id, content: c.content);
    }
  }

  void _tryIdlePrecacheComments() {
    if (!mounted || _scrollPhase.value != FeedScrollPhase.idle) return;
    if (_notifications.isEmpty) return;
    if (!_notifyScrollController.hasClients) return;
    final pos = _notifyScrollController.position;
    _commentIdlePrecache.preloadStillUrls(
      context: context,
      itemCount: _notifications.length,
      stillUrlAt: (i) {
        final c = _notifications[i].comment;
        final vm = _commentBodyVms.obtain(
          commentId: c.id,
          content: c.content,
        );
        if (!vm.hasMedia) return null;
        return CommentListStillThumb.stillUrl(vm.media.first);
      },
      scrollPixels: pos.pixels,
      viewportHeight: pos.viewportDimension,
      averageRowHeight: CommentListStillThumb.height + 100,
      isFlinging: false,
    );
  }

  void _onNotifyScroll() {
    if (!_notifyScrollController.hasClients) return;
    _phaseController.onScrollMetrics(_notifyScrollController.position);
    if (_notifyScrollController.position.pixels >=
        _notifyScrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMoreNotifications &&
          _hasMoreNotifications &&
          !_isLoadingNotifications) {
        if (_scrollPhase.value != FeedScrollPhase.idle) {
          _pendingLoadMoreNotifications = true;
        } else {
          _requestLoadMoreNotificationsDebounced();
        }
      }
    }
  }

  void _onConvoScroll() {
    if (!_convoScrollController.hasClients) return;
    if (_convoScrollController.position.pixels >=
        _convoScrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMoreMessages && _hasMoreMessages && !_isLoadingMessages) {
        unawaited(_loadMoreMessages());
      }
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final newUrl = _auth.activeInstanceUrl;
    final newJwt = _auth.jwt;

    if (newUrl == _lastInstanceUrl && newJwt == _lastJwt) return;
    _lastInstanceUrl = newUrl;
    _lastJwt = newJwt;

    _commentBodyVms.clear();
    _commentIdlePrecache.clear();
    _cancelPendingNotificationLoadMore();

    if (_auth.isLoggedIn) {
      setState(() {
        _notifications = [];
        _convos = [];
        _notificationError = null;
        _messageError = null;
        _isLoadingNotifications = true;
        _isLoadingMessages = true;
        _replyPage = 0;
        _mentionPage = 0;
        _hasMoreReplies = true;
        _hasMoreMentions = true;
        _messagesPage = 1;
        _hasMoreMessages = true;
      });
      unawaited(_loadAll());
    } else {
      setState(() {
        _notifications = [];
        _convos = [];
        _isLoadingNotifications = false;
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _fetchNotifications(),
      _fetchMessages(),
    ]);
  }

  Future<void> _fetchNotifications() async {
    if (!_auth.isLoggedIn) return;
    _cancelPendingNotificationLoadMore();
    setState(() {
      _isLoadingNotifications = true;
      _isLoadingMoreNotifications = false;
      _notificationError = null;
      _replyPage = 0;
      _mentionPage = 0;
      _hasMoreReplies = true;
      _hasMoreMentions = true;
    });

    try {
      final (replies, mentions) = await (
        _repo.getReplies(page: 1, limit: kInboxPageSize),
        _repo.getMentions(page: 1, limit: kInboxPageSize),
      ).wait;
      final merged = mergeInboxPage1(replies: replies, mentions: mentions);

      if (!mounted) return;
      _commentBodyVms.clear();
      _commentIdlePrecache.clear();
      _warmCommentBodyVms(merged.items);
      setState(() {
        _notifications = merged.items;
        _rebuildNotifyIndex();
        _replyPage = 1;
        _mentionPage = 1;
        _hasMoreReplies = merged.hasMoreReplies;
        _hasMoreMentions = merged.hasMoreMentions;
        _isLoadingNotifications = false;
      });
      // Keep badge in sync; loading inbox must never mark items read.
      await _syncUnreadBadgesFromServerAndList();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notificationError = formatError(e);
        _isLoadingNotifications = false;
      });
    }
  }

  /// Refresh badge counts from server, then floor by unread items visible
  /// in the current list (guards brief server desync / local wipe).
  Future<void> _syncUnreadBadgesFromServerAndList() async {
    if (!_auth.isLoggedIn) return;
    await _auth.fetchUnreadCounts(ref.read(lemmyApiClientProvider));
    if (!mounted) return;

    final counts = countUnreadInList(_notifications);
    if (counts.replies > _auth.unreadReplies ||
        counts.mentions > _auth.unreadMentions) {
      _auth.setUnreadCounts(
        replies: counts.replies > _auth.unreadReplies
            ? counts.replies
            : _auth.unreadReplies,
        mentions: counts.mentions > _auth.unreadMentions
            ? counts.mentions
            : _auth.unreadMentions,
        privateMessages: _auth.unreadPrivateMessages,
      );
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMoreNotifications ||
        _isLoadingNotifications ||
        !_hasMoreNotifications) {
      return;
    }
    if (_scrollPhase.value != FeedScrollPhase.idle) {
      _pendingLoadMoreNotifications = true;
      return;
    }
    if (!_auth.isLoggedIn) return;

    final fetchReplies = _hasMoreReplies;
    final fetchMentions = _hasMoreMentions;
    if (!fetchReplies && !fetchMentions) return;

    setState(() => _isLoadingMoreNotifications = true);

    try {
      final nextReplyPage = _replyPage + 1;
      final nextMentionPage = _mentionPage + 1;

      final (replies, mentions) = await (
        fetchReplies
            ? _repo.getReplies(page: nextReplyPage, limit: kInboxPageSize)
            : Future.value(const <CommentReplyView>[]),
        fetchMentions
            ? _repo.getMentions(page: nextMentionPage, limit: kInboxPageSize)
            : Future.value(const <PersonMentionView>[]),
      ).wait;

      if (!mounted) return;

      final appended = appendInboxPage(
        existing: _notifications,
        replies: replies,
        mentions: mentions,
        previousHasMoreReplies: _hasMoreReplies,
        previousHasMoreMentions: _hasMoreMentions,
        fetchedReplies: fetchReplies,
        fetchedMentions: fetchMentions,
      );

      // append rebuilds full list — warm only brand-new rows by key.
      final existingKeys = {for (final i in _notifications) i.listKey};
      final toWarm = [
        for (final i in appended.items)
          if (!existingKeys.contains(i.listKey)) i,
      ];
      _warmCommentBodyVms(toWarm);

      setState(() {
        _notifications = appended.items;
        _rebuildNotifyIndex();
        if (fetchReplies) _replyPage = nextReplyPage;
        if (fetchMentions) _mentionPage = nextMentionPage;
        _hasMoreReplies = appended.hasMoreReplies;
        _hasMoreMentions = appended.hasMoreMentions;
        // If both streams returned only duplicates, stop.
        if (appended.appendedCount == 0) {
          if (fetchReplies) _hasMoreReplies = false;
          if (fetchMentions) _hasMoreMentions = false;
        }
        _isLoadingMoreNotifications = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMoreNotifications = false);
      }
    }
  }

  Future<void> _fetchMessages() async {
    if (!_auth.isLoggedIn) return;
    setState(() {
      _isLoadingMessages = true;
      _messageError = null;
      _messagesPage = 1;
      _hasMoreMessages = true;
    });

    try {
      final messages = await _repo.getPrivateMessages(page: 1, limit: 50);
      final threads = groupPrivateMessages(
        messages,
        currentUserId: _currentUserId,
      );

      if (!mounted) return;
      setState(() {
        _convos = threads;
        _rebuildConvoIndex();
        _hasMoreMessages = messages.length >= 50;
        _isLoadingMessages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messageError = formatError(e);
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMoreMessages || _isLoadingMessages || !_hasMoreMessages) {
      return;
    }
    if (!_auth.isLoggedIn) return;

    setState(() => _isLoadingMoreMessages = true);

    try {
      final nextPage = _messagesPage + 1;
      final messages = await _repo.getPrivateMessages(page: nextPage, limit: 50);
      if (!mounted) return;

      final merged = mergePrivateMessagePage(
        existing: _convos,
        page: messages,
        currentUserId: _currentUserId,
      );

      setState(() {
        _convos = merged.threads;
        _rebuildConvoIndex();
        _messagesPage = nextPage;
        _hasMoreMessages = messages.length >= 50 && merged.newPmCount > 0;
        _isLoadingMoreMessages = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMoreMessages = false);
      }
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    if (!_auth.isLoggedIn) return;
    try {
      await _repo.markAllAsRead();
      await _auth.fetchUnreadCounts(ref.read(lemmyApiClientProvider));
      await _loadAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked all notifications as read')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  Future<void> _markAsRead(InboxItem item) async {
    if (item.isRead) return;

    final previous = item;
    final optimistic = item.markRead();
    setState(() {
      _notifications = replaceInboxItem(_notifications, optimistic);
    });

    try {
      switch (item) {
        case InboxReply(:final view):
          final updated = await _repo.markCommentReplyAsRead(
            commentReplyId: view.commentReply.id,
          );
          if (!mounted) return;
          setState(() {
            _notifications = replaceInboxItem(
              _notifications,
              InboxItem.reply(updated).markRead(),
            );
          });
          _auth.decrementReplies();
        case InboxMention(:final view):
          final updated = await _repo.markPersonMentionAsRead(
            personMentionId: view.personMention.id,
          );
          if (!mounted) return;
          setState(() {
            _notifications = replaceInboxItem(
              _notifications,
              InboxItem.mention(updated).markRead(),
            );
          });
          _auth.decrementMentions();
      }
      unawaited(_auth.fetchUnreadCounts(ref.read(lemmyApiClientProvider)));
    } catch (e) {
      if (!mounted) return;
      // Roll list + badge back toward truth.
      setState(() {
        _notifications = replaceInboxItem(_notifications, previous);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as read: $e')),
      );
      unawaited(_auth.fetchUnreadCounts(ref.read(lemmyApiClientProvider)));
    }
  }

  Future<void> _openNotification(InboxItem item) async {
    final commentView = item.toCommentView();

    // Notification payloads only include Post shell — hydrate PostView first
    // so detail never opens with score/comments/vote at 0 then jumps.
    try {
      final postView = await _repo.getPost(item.post.id);
      if (!mounted) return;

      final markFuture = _markAsRead(item);

      await Navigator.of(context).push(
        postDetailRoute(
          builder: (_) => PostDetailScreen(
            postView: postView,
            threadRoot: commentView,
          ),
        ),
      );
      await markFuture;
      // Optimistic list already correct — only reconcile badges, no full refetch.
      if (mounted) await _syncUnreadBadgesFromServerAndList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open post: ${formatError(e)}')),
      );
    }
  }

  Future<void> _openConvo(ChatThread convo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          otherPerson: convo.otherPerson,
          initialMessages: convo.messages,
        ),
      ),
    );
    if (mounted) await _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isLoggedIn) {
      return const LoginRequiredScaffold(
        title: 'Your notifications are waiting',
      );
    }

    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        final totalNotifyCount = _auth.totalUnreadNotifications;
        final totalMsgCount = _auth.unreadPrivateMessages;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      TabBar(
                        controller: _tabController,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        labelColor: AppColors.accent,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Notifications'),
                                if (totalNotifyCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Badge(
                                    label: Text('$totalNotifyCount'),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Messages'),
                                if (totalMsgCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Badge(
                                    label: Text('$totalMsgCount'),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: AppBarChrome.leadingOuterPad,
                        ),
                        child: IconButton(
                          iconSize: AppBarChrome.iconSize,
                          icon: const Icon(
                            MingCuteIcons.mgc_checks_line,
                            color: AppColors.textPrimary,
                          ),
                          tooltip: 'Mark all as read',
                          onPressed: _markAllNotificationsAsRead,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsTab(),
                      _buildMessagesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    return RefreshIndicator(
      onRefresh: () => runWithMediaBudgetRecovery(
        _fetchNotifications,
        isMounted: () => mounted,
      ),
      color: AppColors.accent,
      child: _isLoadingNotifications && _notifications.isEmpty
          ? const NotificationSkeletonList()
          : _notificationError != null && _notifications.isEmpty
              ? InboxErrorView(
                  error: _notificationError!,
                  onRetry: () => unawaited(_fetchNotifications()),
                )
              : _notifications.isEmpty
                  ? const InboxEmptyView(title: 'No notifications')
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        _phaseController.onNotification(n);
                        return false;
                      },
                      child: ListView.builder(
                        controller: _notifyScrollController,
                        cacheExtent: PostListMemoryPolicy.secondaryCacheExtent,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _notifications.length +
                            (_isLoadingMoreNotifications ? 1 : 0),
                        findChildIndexCallback: (Key key) {
                          if (key is! ValueKey) return null;
                          return _notifyIndexMap?.indexForKeyValue(key.value);
                        },
                        itemBuilder: (context, index) {
                          if (index == _notifications.length) {
                            return const NotificationTileSkeleton();
                          }
                          final item = _notifications[index];
                          final c = item.comment;
                          final bodyVm = _commentBodyVms.obtain(
                            commentId: c.id,
                            content: c.content,
                          );
                          return RepaintBoundary(
                            key: ValueKey(item.listKey),
                            child: NotificationTile(
                              item: item,
                              bodyVm: bodyVm,
                              onOpen: () => unawaited(_openNotification(item)),
                              onMarkRead: () => unawaited(_markAsRead(item)),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildMessagesTab() {
    return RefreshIndicator(
      onRefresh: () => runWithMediaBudgetRecovery(
        _fetchMessages,
        isMounted: () => mounted,
      ),
      color: AppColors.accent,
      child: _isLoadingMessages && _convos.isEmpty
          ? const ConversationSkeletonList()
          : _messageError != null && _convos.isEmpty
              ? InboxErrorView(
                  error: _messageError!,
                  onRetry: () => unawaited(_fetchMessages()),
                )
              : _convos.isEmpty
                  ? const InboxEmptyView(title: 'No messages')
                  : ListView.builder(
                      controller: _convoScrollController,
                      cacheExtent: 240,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount:
                          _convos.length + (_isLoadingMoreMessages ? 1 : 0),
                      findChildIndexCallback: (Key key) {
                        if (key is! ValueKey) return null;
                        return _convoIndexMap?.indexForKeyValue(key.value);
                      },
                      itemBuilder: (context, index) {
                        if (index == _convos.length) {
                          return const ConversationTileSkeleton();
                        }
                        final convo = _convos[index];
                        return KeyedSubtree(
                          key: ValueKey<int>(convo.otherPerson.id),
                          child: ConversationTile(
                            thread: convo,
                            onOpen: () => unawaited(_openConvo(convo)),
                          ),
                        );
                      },
                    ),
    );
  }
}
