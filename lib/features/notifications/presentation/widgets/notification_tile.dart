import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/notifications/domain/inbox_item.dart';
import 'package:bluerum/features/post/presentation/comment_body_paint.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/core/utils/time_ago.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';
import 'package:bluerum/shared/widgets/media/comment_list_still_thumb.dart';

/// Subtle unread row tint (inbox-only).
const Color kNotificationUnreadBg = Color(0xFFE8E8E8);
const Color _avatarBg = Color(0xFFE8E8E8);

final MarkdownStyleSheet kNotificationCommentMarkdownStyle = MarkdownStyleSheet(
  p: const TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
    height: 1.5,
  ),
  a: BluerumMarkdownStyles.link(fontSize: 13),
  code: BluerumMarkdownStyles.code(
    fontSize: 12,
    color: AppColors.textPrimary,
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
);

/// One notifications-tab row (secondary comment-list kit).
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.item,
    required this.bodyVm,
    required this.onOpen,
    required this.onMarkRead,
  });

  final InboxItem item;
  final CommentBodyVm bodyVm;
  final VoidCallback onOpen;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final creatorName = item.creator.displayNameOrName;
    final publishedRaw = switch (item) {
      InboxReply(:final view) => view.commentReply.published,
      InboxMention(:final view) => view.personMention.published,
    };
    final timeLabel = formatCommentTimeAgo(publishedRaw);
    final isUnread = !item.isRead;
    final comment = item.comment;

    return Material(
      color: isUnread ? kNotificationUnreadBg : Colors.white,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.post.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  NetworkAvatar.forList(
                    size: 24,
                    imageUrl: item.creator.avatar,
                    name: creatorName,
                    backgroundColor: _avatarBg,
                    foregroundColor: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'u/$creatorName · $timeLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.typeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (comment.deleted || comment.removed)
                Text(
                  comment.deleted ? '[deleted]' : '[removed]',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                )
              else ...[
                if (bodyVm.hasText) ...[
                  if (bodyVm.paintKind == CommentBodyPaintKind.fullRich)
                    Text(
                      bodyVm.listPlain.isNotEmpty
                          ? bodyVm.listPlain
                          : bodyVm.markdownSource.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    )
                  else
                    CommentBodyPaint(
                      vm: bodyVm,
                      styleSheet: kNotificationCommentMarkdownStyle,
                      maxPlainLines: 3,
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textPrimary,
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
              if (isUnread) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onMarkRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'Mark as read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
