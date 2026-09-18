import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/post/presentation/post_detail_theme.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/post/vote_bounce_button.dart';

/// Post action bar on the detail header (comment / vote / share).
class PostDetailPostActions extends StatelessWidget {
  const PostDetailPostActions({
    super.key,
    required this.postView,
    required this.effectiveVote,
    required this.onUpvote,
    required this.onDownvote,
    required this.onShare,
    required this.onComment,
  });

  final PostView postView;
  final int effectiveVote;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onShare;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final score =
        postView.counts.score + effectiveVote - (postView.myVote ?? 0);
    return SizedBox(
      height: PostDetailTokens.actionBarH,
      child: Row(
        children: [
          InkWell(
            onTap: onComment,
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: PostDetailTokens.pillH,
              padding: const EdgeInsets.symmetric(
                horizontal: PostDetailTokens.pillPadH,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: PostDetailTokens.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    MingCuteIcons.mgc_chat_1_line,
                    size: PostDetailTokens.iconMd,
                    color: PostDetailTokens.actionIdle,
                  ),
                  if (formatCompactCount(postView.counts.comments)
                      .isNotEmpty) ...[
                    const SizedBox(width: PostDetailTokens.spaceXs),
                    Text(
                      formatCompactCount(postView.counts.comments),
                      style: const TextStyle(
                        fontSize: PostDetailTokens.fontMeta,
                        fontWeight: FontWeight.w600,
                        color: PostDetailTokens.actionIdle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: PostDetailTokens.spaceSm),
          Container(
            height: PostDetailTokens.pillH,
            padding: const EdgeInsets.symmetric(
              horizontal: PostDetailTokens.pillPadH,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: PostDetailTokens.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VoteBounceButton(
                  onPressed: onUpvote,
                  tooltip: effectiveVote == 1 ? 'Remove upvote' : 'Upvote',
                  width: PostDetailTokens.voteBtnW,
                  height: PostDetailTokens.pillH,
                  direction: 1,
                  child: Icon(
                    effectiveVote == 1
                        ? MingCuteIcons.mgc_large_arrow_up_fill
                        : MingCuteIcons.mgc_large_arrow_up_line,
                    size: PostDetailTokens.iconMd,
                    color: effectiveVote == 1
                        ? AppColors.action
                        : PostDetailTokens.actionIdle,
                  ),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: PostDetailTokens.fontMeta,
                    fontWeight: FontWeight.w700,
                    color: PostDetailTokens.actionIdle,
                  ),
                ),
                VoteBounceButton(
                  onPressed: onDownvote,
                  tooltip:
                      effectiveVote == -1 ? 'Remove downvote' : 'Downvote',
                  width: PostDetailTokens.voteBtnW,
                  height: PostDetailTokens.pillH,
                  direction: 1,
                  child: Icon(
                    effectiveVote == -1
                        ? MingCuteIcons.mgc_large_arrow_down_fill
                        : MingCuteIcons.mgc_large_arrow_down_line,
                    size: PostDetailTokens.iconMd,
                    color: effectiveVote == -1
                        ? AppColors.downvote
                        : PostDetailTokens.actionIdle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PostDetailTokens.spaceSm),
          const Spacer(),
          Tooltip(
            message: 'Copy post link',
            child: InkWell(
              onTap: onShare,
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                height: PostDetailTokens.pillH,
                padding: const EdgeInsets.symmetric(
                  horizontal: PostDetailTokens.pillPadH,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: PostDetailTokens.border),
                ),
                child: const Icon(
                  MingCuteIcons.mgc_share_2_line,
                  size: PostDetailTokens.iconMd,
                  color: PostDetailTokens.actionIdle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
