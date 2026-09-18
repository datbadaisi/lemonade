import 'package:bluerum/shared/models/notification.dart';

import 'inbox_item.dart';

/// Default Lemmy page size used by the notifications inbox.
const int kInboxPageSize = 30;

/// Result of merging one replies page + one mentions page into a sorted list.
final class InboxMergeResult {
  const InboxMergeResult({
    required this.items,
    required this.hasMoreReplies,
    required this.hasMoreMentions,
  });

  final List<InboxItem> items;
  final bool hasMoreReplies;
  final bool hasMoreMentions;

  bool get hasMore => hasMoreReplies || hasMoreMentions;
}

/// Result of appending later pages onto an existing inbox list.
final class InboxAppendResult {
  const InboxAppendResult({
    required this.items,
    required this.appendedCount,
    required this.hasMoreReplies,
    required this.hasMoreMentions,
  });

  final List<InboxItem> items;
  final int appendedCount;
  final bool hasMoreReplies;
  final bool hasMoreMentions;

  bool get hasMore => hasMoreReplies || hasMoreMentions;
}

/// Merge page-1 replies + mentions, newest first.
InboxMergeResult mergeInboxPage1({
  required List<CommentReplyView> replies,
  required List<PersonMentionView> mentions,
  int pageSize = kInboxPageSize,
}) {
  final items = <InboxItem>[
    for (final r in replies) InboxItem.reply(r),
    for (final m in mentions) InboxItem.mention(m),
  ];
  sortInboxNewestFirst(items);
  return InboxMergeResult(
    items: items,
    hasMoreReplies: replies.length >= pageSize,
    hasMoreMentions: mentions.length >= pageSize,
  );
}

/// Append later stream pages with independent cursors and id dedupe.
///
/// Only streams that still have more should be fetched by the caller; empty
/// [replies]/[mentions] with [fetchedReplies]/[fetchedMentions] false means
/// that stream was skipped (already exhausted).
InboxAppendResult appendInboxPage({
  required List<InboxItem> existing,
  required List<CommentReplyView> replies,
  required List<PersonMentionView> mentions,
  required bool previousHasMoreReplies,
  required bool previousHasMoreMentions,
  required bool fetchedReplies,
  required bool fetchedMentions,
  int pageSize = kInboxPageSize,
}) {
  final replyIds = <int>{
    for (final item in existing)
      if (item is InboxReply) item.notificationId,
  };
  final mentionIds = <int>{
    for (final item in existing)
      if (item is InboxMention) item.notificationId,
  };

  final appended = <InboxItem>[];
  for (final r in replies) {
    if (replyIds.add(r.commentReply.id)) {
      appended.add(InboxItem.reply(r));
    }
  }
  for (final m in mentions) {
    if (mentionIds.add(m.personMention.id)) {
      appended.add(InboxItem.mention(m));
    }
  }

  final items = List<InboxItem>.of(existing)..addAll(appended);
  sortInboxNewestFirst(items);

  // Stop a stream when its page is short, or when a full page only re-sent
  // ids already in the list (no new rows for that stream).
  final hasMoreReplies = fetchedReplies
      ? replies.length >= pageSize && appended.any((e) => e is InboxReply)
      : previousHasMoreReplies;
  final hasMoreMentions = fetchedMentions
      ? mentions.length >= pageSize && appended.any((e) => e is InboxMention)
      : previousHasMoreMentions;

  return InboxAppendResult(
    items: items,
    appendedCount: appended.length,
    hasMoreReplies: hasMoreReplies,
    hasMoreMentions: hasMoreMentions,
  );
}

void sortInboxNewestFirst(List<InboxItem> items) {
  items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
}

/// Replace a single row by [listKey], or return [items] unchanged.
List<InboxItem> replaceInboxItem(
  List<InboxItem> items,
  InboxItem updated,
) {
  final index = items.indexWhere((e) => e.listKey == updated.listKey);
  if (index < 0) return items;
  final next = List<InboxItem>.of(items);
  next[index] = updated;
  return next;
}

/// Count unread replies / mentions currently in the list (badge floor).
({int replies, int mentions}) countUnreadInList(List<InboxItem> items) {
  var replies = 0;
  var mentions = 0;
  for (final item in items) {
    if (item.isRead) continue;
    if (item is InboxReply) {
      replies++;
    } else if (item is InboxMention) {
      mentions++;
    }
  }
  return (replies: replies, mentions: mentions);
}
