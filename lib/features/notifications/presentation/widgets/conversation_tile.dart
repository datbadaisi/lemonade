import 'package:flutter/material.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/time_ago.dart';
import 'package:bluerum/features/notifications/domain/chat_thread.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';

const Color _avatarBg = Color(0xFFE8E8E8);

/// One Messages-tab conversation row.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.thread,
    required this.onOpen,
  });

  final ChatThread thread;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final name = thread.otherPerson.displayNameOrName;
    final unread = thread.unreadCount;
    final lastPublished = thread.messages.isNotEmpty
        ? thread.messages.last.privateMessage.published
        : '';
    final time = formatCommentTimeAgo(lastPublished);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              NetworkAvatar.forList(
                size: 40,
                imageUrl: thread.otherPerson.avatar,
                name: name,
                backgroundColor: _avatarBg,
                foregroundColor: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'u/$name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            unread > 0 ? FontWeight.bold : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.lastMessageContent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            unread > 0 ? FontWeight.w600 : FontWeight.normal,
                        color: unread > 0
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
