import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/comment_card.dart';
import 'package:bluerum/features/post/presentation/comment_thread_chrome.dart';
import 'package:bluerum/features/post/presentation/comment_thread_flatten.dart';
import 'package:bluerum/features/post/presentation/post_detail_theme.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

/// Nested comment row with thread lines + optional swipe-to-parent.
class PostDetailCommentRow extends StatelessWidget {
  const PostDetailCommentRow({
    super.key,
    required this.row,
    required this.bodyVm,
    required this.voteListenable,
    required this.hasParent,
    required this.isCollapsed,
    required this.authService,
    required this.highlighted,
    required this.onUpvote,
    required this.onDownvote,
    required this.onReply,
    required this.onLinkTap,
    required this.onToggleCollapse,
    required this.onRevealParent,
    required this.onContinueThread,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onBlock,
    this.onHighlightComplete,
  });

  final CommentFlatRow row;
  final CommentBodyVm bodyVm;
  final ValueListenable<int?> voteListenable;
  final bool hasParent;
  final bool isCollapsed;
  final AuthService authService;
  final bool highlighted;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onReply;
  final ValueChanged<String?> onLinkTap;
  final VoidCallback onToggleCollapse;
  final VoidCallback onRevealParent;
  final VoidCallback onContinueThread;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onHighlightComplete;

  @override
  Widget build(BuildContext context) {
    final depth = row.depth;
    final visibleAncestors = depth <= 1
        ? const <bool>[]
        : row.ancestorContinues.take(depth - 1).toList(growable: false);
    final connectorColor = depth > 0
        ? PostDetailTokens.threadColorAt(depth - 1)
        : PostDetailTokens.threadColorAt(0);
    final connectorContinues = !row.isLastSibling;
    final ancestorCount = depth > 0 ? depth - 1 : 0;

    return RepaintBoundary(
      child: Stack(
        children: [
          if (ancestorCount > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(width: PostDetailTokens.threadGutter),
                    ...List.generate(ancestorCount, (i) {
                      final level = i + 1;
                      final color = PostDetailTokens.threadColorAt(level - 1);
                      return SizedBox(
                        width: PostDetailTokens.threadIndent,
                        child: CustomPaint(
                          painter: ThreadLinePainter(
                            color: color,
                            continues: visibleAncestors[i],
                            isConnector: false,
                          ),
                        ),
                      );
                    }),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          if (depth > 0 && !hasParent)
            Positioned.fill(
              child: IgnorePointer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(width: PostDetailTokens.threadGutter),
                    ...List.generate(
                      ancestorCount,
                      (_) =>
                          const SizedBox(width: PostDetailTokens.threadIndent),
                    ),
                    SizedBox(
                      width: PostDetailTokens.threadIndent,
                      child: CustomPaint(
                        painter: ThreadLinePainter(
                          color: connectorColor,
                          continues: connectorContinues,
                          isConnector: true,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          Builder(
            builder: (ctx) {
              final content = Padding(
                padding: EdgeInsets.only(
                  left: depth * PostDetailTokens.threadIndent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CommentCard(
                      commentView: row.cv,
                      authService: authService,
                      bodyVm: bodyVm,
                      voteListenable: voteListenable,
                      isCollapsed: isCollapsed,
                      onUpvote: onUpvote,
                      onDownvote: onDownvote,
                      onReply: onReply,
                      onLinkTap: onLinkTap,
                      onToggleCollapse: onToggleCollapse,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onReport: onReport,
                      onBlock: onBlock,
                      highlighted: highlighted,
                      onHighlightComplete: onHighlightComplete,
                    ),
                    if (row.isContinueThread)
                      _ContinueThreadButton(onPressed: onContinueThread),
                  ],
                ),
              );

              if (!hasParent) return content;

              return SwipeableCommentRow(
                commentView: row.cv,
                onRevealParent: onRevealParent,
                threadColor: connectorColor,
                threadContinues: connectorContinues,
                connectorLeft: PostDetailTokens.threadGutter +
                    ancestorCount * PostDetailTokens.threadIndent,
                child: content,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContinueThreadButton extends StatelessWidget {
  const _ContinueThreadButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PostDetailTokens.spaceLg,
          0,
          PostDetailTokens.spaceLg,
          PostDetailTokens.spaceSm,
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.action,
            padding: const EdgeInsets.symmetric(
              horizontal: PostDetailTokens.spaceSm,
              vertical: PostDetailTokens.spaceSm,
            ),
            minimumSize: const Size(0, PostDetailTokens.pillH),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(
            MingCuteIcons.mgc_corner_down_right_line,
            size: PostDetailTokens.iconMd,
          ),
          label: const Text(
            'Continue thread',
            style: TextStyle(
              fontSize: PostDetailTokens.fontMeta,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton comment rows that mirror live thread geometry.
class CommentRowSkeleton extends StatelessWidget {
  const CommentRowSkeleton({
    super.key,
    required this.depth,
    required this.bodyLines,
  });

  final int depth;
  final int bodyLines;

  @override
  Widget build(BuildContext context) {
    final ancestorCount = depth > 0 ? depth - 1 : 0;
    final connectorColor = depth > 0
        ? PostDetailTokens.threadColorAt(depth - 1)
        : PostDetailTokens.threadColorAt(0);

    return Stack(
      children: [
        if (ancestorCount > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(width: PostDetailTokens.threadGutter),
                  ...List.generate(ancestorCount, (i) {
                    final color = PostDetailTokens.threadColorAt(i);
                    return SizedBox(
                      width: PostDetailTokens.threadIndent,
                      child: CustomPaint(
                        painter: ThreadLinePainter(
                          color: color,
                          continues: true,
                          isConnector: false,
                        ),
                      ),
                    );
                  }),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        if (depth > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(width: PostDetailTokens.threadGutter),
                  ...List.generate(
                    ancestorCount,
                    (_) => const SizedBox(width: PostDetailTokens.threadIndent),
                  ),
                  SizedBox(
                    width: PostDetailTokens.threadIndent,
                    child: CustomPaint(
                      painter: ThreadLinePainter(
                        color: connectorColor,
                        continues: false,
                        isConnector: true,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(left: depth * PostDetailTokens.threadIndent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  PostDetailTokens.spaceLg,
                  PostDetailTokens.spaceSm,
                  PostDetailTokens.spaceLg,
                  0,
                ),
                child: Row(
                  children: [
                    Skeleton.circle(size: PostDetailTokens.avatar),
                    SizedBox(width: PostDetailTokens.spaceXs),
                    Skeleton(width: 70, height: 12, borderRadius: 4),
                    SizedBox(width: PostDetailTokens.spaceXs),
                    Skeleton(width: 40, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PostDetailTokens.spaceLg,
                  PostDetailTokens.spaceSm,
                  PostDetailTokens.spaceLg,
                  PostDetailTokens.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(bodyLines, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < bodyLines - 1
                              ? PostDetailTokens.spaceXs
                              : 0,
                        ),
                        child: Skeleton(
                          width: index == bodyLines - 1
                              ? 160.0 + (index * 40)
                              : double.infinity,
                          height: 13,
                          borderRadius: 4,
                        ),
                      );
                    }),
                    const SizedBox(height: PostDetailTokens.spaceSm),
                    const SizedBox(
                      height: PostDetailTokens.pillH,
                      child: Row(
                        children: [
                          Skeleton(
                            width: 52,
                            height: PostDetailTokens.pillH,
                            borderRadius: 9999,
                          ),
                          SizedBox(width: PostDetailTokens.spaceSm),
                          Skeleton(
                            width: 96,
                            height: PostDetailTokens.pillH,
                            borderRadius: 9999,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Default loading placeholder for the comment tree.
class CommentTreeLoadingState extends StatelessWidget {
  const CommentTreeLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CommentRowSkeleton(depth: 0, bodyLines: 2),
        CommentRowSkeleton(depth: 1, bodyLines: 3),
        CommentRowSkeleton(depth: 2, bodyLines: 1),
        CommentRowSkeleton(depth: 1, bodyLines: 2),
        CommentRowSkeleton(depth: 0, bodyLines: 3),
        CommentRowSkeleton(depth: 1, bodyLines: 2),
        CommentRowSkeleton(depth: 0, bodyLines: 1),
      ],
    );
  }
}

class CommentTreeErrorState extends StatelessWidget {
  const CommentTreeErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(
              MingCuteIcons.mgc_warning_line,
              size: 32,
              color: Color(0xFF525252),
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load comments',
              style: TextStyle(fontSize: 13, color: Color(0xFF525252)),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class CommentTreeEmptyState extends StatelessWidget {
  const CommentTreeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              MingCuteIcons.mgc_chat_1_line,
              size: 32,
              color: Color(0xFF525252),
            ),
            SizedBox(height: 8),
            Text(
              'No comments yet',
              style: TextStyle(fontSize: 13, color: Color(0xFF525252)),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentLoadMoreIndicator extends StatelessWidget {
  const CommentLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF525252),
          ),
        ),
      ),
    );
  }
}

class CommentLoadMoreError extends StatelessWidget {
  const CommentLoadMoreError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Text(
              'Could not load more comments',
              style: TextStyle(fontSize: 13, color: Color(0xFF525252)),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class CommentEndMarker extends StatelessWidget {
  const CommentEndMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          '— end of comments —',
          style: TextStyle(fontSize: 12, color: Color(0xFF525252)),
        ),
      ),
    );
  }
}

/// Bottom composer chrome that slides with scroll.
class PostDetailCommentBar extends StatelessWidget {
  const PostDetailCommentBar({
    super.key,
    required this.hidePixels,
    required this.contentHeight,
    required this.onTap,
  });

  final ValueNotifier<double> hidePixels;
  final double contentHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ValueListenableBuilder<double>(
        valueListenable: hidePixels,
        builder: (context, hideRaw, child) {
          final hide = hideRaw.clamp(0.0, contentHeight);
          final t = (hide / contentHeight).clamp(0.0, 1.0);
          final fullyHidden = t >= 1.0 - 0.01;
          return IgnorePointer(
            ignoring: fullyHidden,
            child: Transform.translate(
              offset: Offset(0, hide),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  10 + bottom * (1.0 - t),
                ),
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: PostDetailTokens.fieldBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PostDetailTokens.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    MingCuteIcons.mgc_chat_1_line,
                    size: PostDetailTokens.iconMd,
                    color: PostDetailTokens.textSecondary,
                  ),
                  const SizedBox(width: PostDetailTokens.spaceSm),
                  Expanded(
                    child: Text(
                      'Add a comment…',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: PostDetailTokens.textSecondary.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
