import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_bar_chrome.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';

// Chat design system — matched to feed PostCard / post-detail / profile / inbox:
// Spacing: 4 micro · 8 section · 12 shell-Y · 16 shell-X
// Type: 10 label · 12 meta · 13 body · 16 title
// Color: #000 primary · #525252 meta
const Color _accent = AppColors.accent;
const Color _textPrimary = AppColors.textPrimary;
/// Meta secondary — same as PostCard / post-detail (not AppColors.textSecondary).
const Color _textSecondary = Color(0xFF525252);
const Color _surfaceMuted = Color(0xFFE8E8E8);
const Color _securityBg = Color(0xFFFFF5F5);
const Color _securityBorder = Color(0xFFFFD8D8);

class ChatDetailScreen extends ConsumerStatefulWidget {
  final Person otherPerson;
  final List<PrivateMessageView> initialMessages;

  const ChatDetailScreen({
    super.key,
    required this.otherPerson,
    required this.initialMessages,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  late final LemmyApiService _api;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PrivateMessageView> _messages = [];
  /// True on open when there is no seed data so the first frame is skeleton,
  /// not a blank chat body.
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _api = ref.read(lemmyApiClientProvider);

    if (!ref.read(authRepositoryProvider).isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log in to send messages')));
        Navigator.of(context).pop();
      });
      return;
    }

    // Sort initial messages descending (newest to oldest for reverse list)
    _messages = List.from(widget.initialMessages);
    _messages.sort(
      (a, b) => DateTime.parse(
        b.privateMessage.published).compareTo(DateTime.parse(a.privateMessage.published)));

    // No seed messages → show skeleton on the first frame (not empty UI).
    _isLoading = _messages.isEmpty;

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory(page: 1);
      _markAllAsRead();
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _loadMoreHistory();
      }
    }
  }

  Future<void> _fetchHistory({required int page}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allPms = await _api.getPrivateMessages(page: page, limit: 50);

      // Filter for messages between current user and otherPerson
      final convoPms = allPms.where((pmv) {
        final pm = pmv.privateMessage;
        return (pm.creatorId == widget.otherPerson.id) ||
            (pm.recipientId == widget.otherPerson.id);
      }).toList();

      convoPms.sort(
        (a, b) => DateTime.parse(
          b.privateMessage.published).compareTo(DateTime.parse(a.privateMessage.published)));

      if (mounted) {
        setState(() {
          _messages = convoPms;
          _currentPage = page;
          _hasMore = allPms.length == 50;
          _isLoading = false;
        });
        unawaited(_markAllAsRead());
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

  Future<void> _loadMoreHistory() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Inbox is global; many pages may contain zero messages for this
      // conversation. Advance pages in one load until we gain history or
      // exhaust the inbox — avoids a forever-spinner of empty merges.
      // Cap pages per gesture so a huge inbox does not block the UI.
      const maxPagesPerLoad = 10;
      var page = _currentPage;
      var inboxHasMore = true;
      var newCount = 0;
      var pagesFetched = 0;
      final existingIds = _messages.map((m) => m.privateMessage.id).toSet();
      final added = <PrivateMessageView>[];

      while (inboxHasMore &&
          newCount == 0 &&
          pagesFetched < maxPagesPerLoad) {
        page += 1;
        pagesFetched += 1;
        final allPms = await _api.getPrivateMessages(page: page, limit: 50);
        inboxHasMore = allPms.length == 50;

        final convoPms = allPms.where((pmv) {
          final pm = pmv.privateMessage;
          return (pm.creatorId == widget.otherPerson.id) ||
              (pm.recipientId == widget.otherPerson.id);
        });

        for (final pmv in convoPms) {
          if (existingIds.add(pmv.privateMessage.id)) {
            added.add(pmv);
            newCount++;
          }
        }
      }

      if (mounted) {
        setState(() {
          if (added.isNotEmpty) {
            _messages.addAll(added);
            // Sort descending (newest first)
            _messages.sort(
              (a, b) => DateTime.parse(b.privateMessage.published)
                  .compareTo(DateTime.parse(a.privateMessage.published)),
            );
          }
          _currentPage = page;
          // Keep paging if the global inbox still has pages (even when this
          // batch only skipped empty conversation slices).
          _hasMore = inboxHasMore;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    int readCount = 0;
    for (var pmv in _messages) {
      final pm = pmv.privateMessage;
      if (!pm.read && pm.creatorId == widget.otherPerson.id) {
        try {
          await _api.markPrivateMessageAsRead(
            privateMessageId: pm.id,
            read: true);
          readCount++;
        } catch (_) {}
      }
    }

    if (readCount > 0 && mounted) {
      ref.read(authRepositoryProvider).decrementPrivateMessages(readCount);
    }
  }

  Future<void> _sendMessage() async {
    if (!ref.read(authRepositoryProvider).isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to send messages')));
      return;
    }
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    try {
      final sentPmv = await _api.createPrivateMessage(
        content: text,
        recipientId: widget.otherPerson.id);

      if (mounted) {
        setState(() {
          _messages.insert(0, sentPmv);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context).showSnackBar(SnackBar(content: Text('Failed to send message: ${formatError(e)}')));
      }
    }
  }

  String _formatTime(String published) {
    try {
      final local = DateTime.parse(published).toLocal();
      final minute = local.minute.toString().padLeft(2, '0');
      final hour = local.hour.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  Widget _buildSecurityWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _securityBg,
        border: Border.all(color: _securityBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Warning: Lemmy private messages are not secure.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.danger,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSkeletonChat() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? _surfaceMuted : _surfaceMuted.withValues(alpha: 0.7),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16))),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Skeleton(
                  height: 13,
                  width: (index == 0 || index == 3)
                      ? 120
                      : (index == 1 || index == 4)
                      ? 180
                      : 80,
                  borderRadius: 6),
                const SizedBox(height: 4),
                const Skeleton(height: 10, width: 40, borderRadius: 4),
              ])));
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your messages are waiting');
    }
    final otherAvatar = widget.otherPerson.avatar;
    final otherName = widget.otherPerson.displayNameOrName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppBarChrome.height,
        iconTheme: const IconThemeData(
          size: AppBarChrome.iconSize,
          color: _textPrimary,
        ),
        actionsIconTheme: const IconThemeData(
          size: AppBarChrome.iconSize,
          color: _textPrimary,
        ),
        actionsPadding: AppBarChrome.actionsPadding,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  personId: widget.otherPerson.id)));
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              NetworkAvatar(
                size: 32,
                imageUrl: otherAvatar,
                name: otherName,
                backgroundColor: _surfaceMuted,
                foregroundColor: _textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'u/$otherName',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            iconSize: AppBarChrome.iconSize,
            icon: const Icon(MingCuteIcons.mgc_refresh_1_line),
            onPressed: () => _fetchHistory(page: 1),
            color: _textPrimary,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat history
            Expanded(
              child: _isLoading && _messages.isEmpty
                  ? _buildSkeletonChat()
                  : _error != null && _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading messages: $_error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textSecondary)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _fetchHistory(page: 1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.white,
                                elevation: 0),
                              child: const Text('Retry')),
                          ])))
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      cacheExtent: 600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16),
                      itemCount: _messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildSecurityWarning();
                        }
                        final pmv = _messages[index];
                        final pm = pmv.privateMessage;
                        final isMe = pm.creatorId != widget.otherPerson.id;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? _accent : _surfaceMuted,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16))),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pm.content,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : _textPrimary,
                                    fontSize: 13,
                                    height: 1.5)),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(pm.published),
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : _textSecondary,
                                    fontSize: 10)),
                              ])));
                      })),

            // Bottom Message Composer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8),
                      decoration: BoxDecoration(
                        color: _surfaceMuted,
                        borderRadius: BorderRadius.circular(20)),
                      child: TextField(
                        controller: _msgController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(
                            color: _textSecondary,
                            fontSize: 13)),
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 13)))),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle),
                      child: InkWell(
                        onTap: _sendMessage,
                        customBorder: const CircleBorder(),
                        splashColor: Colors.white24,
                        highlightColor: Colors.white10,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            MingCuteIcons.mgc_send_plane_line,
                            color: Colors.white,
                            size: 18))))),
                ])),
          ])));
  }
}
