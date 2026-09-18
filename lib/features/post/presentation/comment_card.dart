import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/time_ago.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/chat/presentation/chat_detail_screen.dart';
import 'package:bluerum/features/post/presentation/comment_body_paint.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/comment_thread_chrome.dart';
import 'package:bluerum/features/post/presentation/post_detail_theme.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/post.dart' show Person;
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/media/comment_media_widget.dart';
import 'package:bluerum/shared/widgets/post/vote_bounce_button.dart';

/// Single comment tile body (author / body / vote) for post-detail lists.
class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.commentView,
    this.authService,
    required this.bodyVm,
    required this.voteListenable,
    this.isCollapsed = false,
    this.showTopBorder = true,
    this.onUpvote,
    this.onDownvote,
    this.onReply,
    this.onLinkTap,
    this.onToggleCollapse,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onBlock,
    this.highlighted = false,
    this.onHighlightComplete,
  });

  final CommentView commentView;
  final AuthService? authService;
  final CommentBodyVm bodyVm;
  final ValueListenable<int?> voteListenable;
  final bool isCollapsed;
  final bool showTopBorder;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onReply;
  final ValueChanged<String?>? onLinkTap;
  final VoidCallback? onToggleCollapse;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final bool highlighted;
  final VoidCallback? onHighlightComplete;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  Widget _bodySubtreeFor(BuildContext context, Comment c) {
    final vm = widget.bodyVm;
    final media = vm.media;
    final hasMedia = vm.hasMedia;
    final hasText = vm.hasText;

    final Widget? textWidget = hasText
        ? CommentBodyPaint(
            vm: vm,
            styleSheet: commentMarkdownStyle,
            onLinkTap: widget.onLinkTap,
            fontSize: PostDetailTokens.fontBody,
            height: 1.35,
            color: PostDetailTokens.textPrimary,
          )
        : null;

    if (hasMedia) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?textWidget,
          if (textWidget != null)
            const SizedBox(height: PostDetailTokens.spaceSm),
          CommentMediaWidget(
            item: media.first,
            allMedia: media,
            depth: c.depth.toDouble(),
            extraCount: media.length > 1 ? media.length - 1 : 0,
          ),
        ],
      );
    }

    if (textWidget != null) return textWidget;
    return const SizedBox.shrink();
  }

  void _showMyCommentBottomSheet(BuildContext context) {
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
                _sheetHandle(),
                if (widget.onEdit != null &&
                    !widget.commentView.comment.deleted) ...[
                  ListTile(
                    leading: const Icon(
                      MingCuteIcons.mgc_pencil_2_line,
                      size: 22,
                      color: Color(0xFF000000),
                    ),
                    title: const Text(
                      'Edit comment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onEdit!();
                    },
                  ),
                ],
                if (widget.onDelete != null) ...[
                  ListTile(
                    leading: Icon(
                      widget.commentView.comment.deleted
                          ? MingCuteIcons.mgc_refresh_2_line
                          : MingCuteIcons.mgc_delete_2_line,
                      size: 22,
                      color: widget.commentView.comment.deleted
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    ),
                    title: Text(
                      widget.commentView.comment.deleted
                          ? 'Undelete comment'
                          : 'Delete comment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.commentView.comment.deleted
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onDelete!();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOtherCommentBottomSheet(BuildContext context, Person creator) {
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
                _sheetHandle(),
                ListTile(
                  leading: const Icon(
                    MingCuteIcons.mgc_comment_line,
                    size: 22,
                    color: Color(0xFF000000),
                  ),
                  title: Text(
                    'Message u/${creator.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (!(widget.authService?.isLoggedIn ?? false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Log in to send messages'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          otherPerson: creator,
                          initialMessages: const [],
                        ),
                      ),
                    );
                  },
                ),
                if (widget.onReport != null) ...[
                  ListTile(
                    leading: const Icon(
                      MingCuteIcons.mgc_flag_1_line,
                      size: 22,
                      color: Color(0xFF000000),
                    ),
                    title: const Text(
                      'Report comment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onReport!();
                    },
                  ),
                ],
                if (widget.onBlock != null) ...[
                  ListTile(
                    leading: const Icon(
                      MingCuteIcons.mgc_user_remove_line,
                      size: 22,
                      color: Color(0xFFD93939),
                    ),
                    title: Text(
                      'Block u/${creator.name}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD93939),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onBlock!();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _sheetHandle() {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.commentView.comment;
    final creator = widget.commentView.creator;
    final isRemoved = c.removed || c.deleted;
    final isOp = creator.id == widget.commentView.post.creatorId;

    Widget shell = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggleCollapse,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PostDetailTokens.spaceLg,
              PostDetailTokens.spaceSm,
              PostDetailTokens.spaceLg,
              0,
            ),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(personId: creator.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: PostDetailTokens.spaceXs,
                    ),
                    child: NetworkAvatar.forList(
                      size: PostDetailTokens.avatar,
                      imageUrl: creator.avatar,
                      name: creator.displayName?.isNotEmpty == true
                          ? creator.displayName!
                          : creator.name,
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(personId: creator.id),
                        ),
                      );
                    },
                    child: Text(
                      'u/${creator.name}',
                      style: TextStyle(
                        fontSize: PostDetailTokens.fontMeta,
                        fontWeight: FontWeight.w700,
                        color: isOp ? AppColors.op : PostDetailTokens.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: PostDetailTokens.spaceXs),
                Text(
                  '· ${formatCommentTimeAgo(c.published)}',
                  style: const TextStyle(
                    fontSize: PostDetailTokens.fontMeta,
                    color: PostDetailTokens.textSecondary,
                  ),
                ),
                if (widget.commentView.creatorIsAdmin) ...[
                  const SizedBox(width: PostDetailTokens.spaceXs),
                  const DetailRoleBadge(
                    label: 'ADMIN',
                    color: Color(0xFFFF4500),
                  ),
                ],
                if (widget.commentView.creatorIsModerator) ...[
                  const SizedBox(width: PostDetailTokens.spaceXs),
                  const DetailRoleBadge(
                    label: 'MOD',
                    color: PostDetailTokens.textPrimary,
                  ),
                ],
                if (widget.commentView.creator.banned) ...[
                  const SizedBox(width: PostDetailTokens.spaceXs),
                  const DetailRoleBadge(
                    label: 'BANNED',
                    color: AppColors.danger,
                  ),
                ],
                if (widget.commentView.creatorBannedFromCommunity) ...[
                  const SizedBox(width: PostDetailTokens.spaceXs),
                  const DetailRoleBadge(
                    label: 'COMMUNITY BANNED',
                    color: AppColors.danger,
                  ),
                ],
                if (widget.commentView.creator.deleted) ...[
                  const SizedBox(width: PostDetailTokens.spaceXs),
                  const DetailRoleBadge(
                    label: 'DELETED',
                    color: PostDetailTokens.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: widget.isCollapsed
              ? null
              : () {
                  final isMyComment =
                      widget.authService?.isMe(
                        personId: creator.id,
                        username: creator.name,
                      ) ??
                      false;
                  if (isMyComment) {
                    if (widget.onEdit == null && widget.onDelete == null) {
                      return;
                    }
                    _showMyCommentBottomSheet(context);
                  } else {
                    _showOtherCommentBottomSheet(context, creator);
                  }
                },
          onTap: widget.isCollapsed ? widget.onToggleCollapse : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PostDetailTokens.spaceLg,
              PostDetailTokens.spaceSm,
              PostDetailTokens.spaceLg,
              PostDetailTokens.spaceSm,
            ),
            child: widget.isCollapsed
                ? const Padding(
                    padding: EdgeInsets.only(bottom: PostDetailTokens.spaceXs),
                    child: Text(
                      '(collapsed)',
                      style: TextStyle(
                        fontSize: PostDetailTokens.fontMeta,
                        fontStyle: FontStyle.italic,
                        color: PostDetailTokens.textSecondary,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isRemoved)
                        Text(
                          c.deleted ? '[deleted]' : '[removed]',
                          style: const TextStyle(
                            fontSize: PostDetailTokens.fontBody,
                            fontStyle: FontStyle.italic,
                            color: PostDetailTokens.textSecondary,
                          ),
                        )
                      else
                        _bodySubtreeFor(context, c),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: PostDetailTokens.spaceSm,
                        ),
                        child: SizedBox(
                          height: PostDetailTokens.actionBarH,
                          child: Row(
                            children: [
                              Container(
                                height: PostDetailTokens.pillH,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PostDetailTokens.pillPadH,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: PostDetailTokens.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.onReply != null) ...[
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: widget.onReply,
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                          child: const SizedBox(
                                            height: PostDetailTokens.pillH,
                                            width: PostDetailTokens.voteBtnW,
                                            child: Icon(
                                              MingCuteIcons.mgc_chat_1_line,
                                              size: PostDetailTokens.iconMd,
                                              color: PostDetailTokens.actionIdle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: PostDetailTokens.iconMd,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: PostDetailTokens.spaceXs,
                                        ),
                                        color: PostDetailTokens.border,
                                      ),
                                    ],
                                    ValueListenableBuilder<int?>(
                                      valueListenable: widget.voteListenable,
                                      builder: (context, voteOverlay, _) {
                                        final effectiveVote =
                                            voteOverlay ??
                                            widget.commentView.myVote ??
                                            0;
                                        final displayScore =
                                            widget.commentView.counts.score +
                                            effectiveVote -
                                            (widget.commentView.myVote ?? 0);
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            VoteBounceButton(
                                              onPressed: widget.onUpvote,
                                              tooltip: effectiveVote == 1
                                                  ? 'Remove upvote'
                                                  : 'Upvote comment',
                                              width: PostDetailTokens.voteBtnW,
                                              height: PostDetailTokens.pillH,
                                              direction: 1,
                                              child: Icon(
                                                effectiveVote == 1
                                                    ? MingCuteIcons
                                                        .mgc_large_arrow_up_fill
                                                    : MingCuteIcons
                                                        .mgc_large_arrow_up_line,
                                                size: PostDetailTokens.iconMd,
                                                color: effectiveVote == 1
                                                    ? AppColors.action
                                                    : PostDetailTokens
                                                        .actionIdle,
                                              ),
                                            ),
                                            Text(
                                              '$displayScore',
                                              style: const TextStyle(
                                                fontSize:
                                                    PostDetailTokens.fontMeta,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    PostDetailTokens.actionIdle,
                                              ),
                                            ),
                                            VoteBounceButton(
                                              onPressed: widget.onDownvote,
                                              tooltip: effectiveVote == -1
                                                  ? 'Remove downvote'
                                                  : 'Downvote comment',
                                              width: PostDetailTokens.voteBtnW,
                                              height: PostDetailTokens.pillH,
                                              direction: 1,
                                              child: Icon(
                                                effectiveVote == -1
                                                    ? MingCuteIcons
                                                        .mgc_large_arrow_down_fill
                                                    : MingCuteIcons
                                                        .mgc_large_arrow_down_line,
                                                size: PostDetailTokens.iconMd,
                                                color: effectiveVote == -1
                                                    ? AppColors.downvote
                                                    : PostDetailTokens
                                                        .actionIdle,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );

    if (widget.highlighted) {
      shell = TargetCommentHighlight(
        onComplete: widget.onHighlightComplete,
        child: shell,
      );
    }

    return Semantics(
      label: widget.isCollapsed ? 'Collapsed comment by ${creator.name}' : null,
      button: widget.isCollapsed,
      child: shell,
    );
  }
}

/// One-shot blue flash for the deep-linked / focused comment.
class TargetCommentHighlight extends StatefulWidget {
  const TargetCommentHighlight({
    super.key,
    required this.child,
    this.onComplete,
  });

  final Widget child;
  final VoidCallback? onComplete;

  @override
  State<TargetCommentHighlight> createState() => _TargetCommentHighlightState();
}

class _TargetCommentHighlightState extends State<TargetCommentHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _color =
        ColorTween(
          begin: AppColors.action.withValues(alpha: 0.12),
          end: Colors.transparent,
        ).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (context, child) {
        return ColoredBox(
          color: _color.value ?? Colors.transparent,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
