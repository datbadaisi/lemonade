import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';

import 'inbox_item.dart';

/// One DM conversation row on the Messages tab.
final class ChatThread {
  const ChatThread({
    required this.otherPerson,
    required this.messages,
    required this.unreadCount,
    required this.lastMessageContent,
    required this.lastMessageTime,
  });

  final Person otherPerson;
  final List<PrivateMessageView> messages;
  final int unreadCount;
  final String lastMessageContent;
  final DateTime lastMessageTime;
}

/// Group a flat PM list into threads by the other participant.
///
/// Pure domain — unit-testable without Flutter.
List<ChatThread> groupPrivateMessages(
  Iterable<PrivateMessageView> messages, {
  required int? currentUserId,
}) {
  final grouped = <int, List<PrivateMessageView>>{};
  final persons = <int, Person>{};

  for (final pmv in messages) {
    final pm = pmv.privateMessage;
    final other = pm.creatorId == currentUserId ? pmv.recipient : pmv.creator;
    if (currentUserId != null && other.id == currentUserId) continue;
    grouped.putIfAbsent(other.id, () => []).add(pmv);
    persons[other.id] = other;
  }

  final threads = <ChatThread>[];
  for (final entry in grouped.entries) {
    final list = List<PrivateMessageView>.of(entry.value);
    _sortPmsOldestFirst(list);
    threads.add(_threadFromMessages(persons[entry.key]!, list, currentUserId));
  }
  threads.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  return threads;
}

/// Merge a later PM page into existing threads.
///
/// Returns updated threads and how many brand-new PM rows were added
/// (used for has-more stop when the page only re-sent known messages).
({List<ChatThread> threads, int newPmCount}) mergePrivateMessagePage({
  required List<ChatThread> existing,
  required List<PrivateMessageView> page,
  required int? currentUserId,
}) {
  if (page.isEmpty) {
    return (threads: List<ChatThread>.of(existing), newPmCount: 0);
  }

  final byOther = <int, List<PrivateMessageView>>{
    for (final t in existing) t.otherPerson.id: List.of(t.messages),
  };
  final persons = <int, Person>{
    for (final t in existing) t.otherPerson.id: t.otherPerson,
  };
  final knownIds = <int>{
    for (final t in existing)
      for (final m in t.messages) m.privateMessage.id,
  };

  var newPmCount = 0;
  for (final pmv in page) {
    final pm = pmv.privateMessage;
    final other = pm.creatorId == currentUserId ? pmv.recipient : pmv.creator;
    if (currentUserId != null && other.id == currentUserId) continue;
    persons[other.id] = other;
    final list = byOther.putIfAbsent(other.id, () => []);
    if (knownIds.add(pm.id)) {
      list.add(pmv);
      newPmCount++;
    }
  }

  final threads = <ChatThread>[];
  for (final entry in byOther.entries) {
    final list = entry.value;
    _sortPmsOldestFirst(list);
    threads.add(_threadFromMessages(persons[entry.key]!, list, currentUserId));
  }
  threads.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  return (threads: threads, newPmCount: newPmCount);
}

ChatThread _threadFromMessages(
  Person other,
  List<PrivateMessageView> list,
  int? currentUserId,
) {
  final last = list.last;
  final unread = list.where((pmv) {
    final pm = pmv.privateMessage;
    return !pm.read && pm.creatorId != currentUserId;
  }).length;

  return ChatThread(
    otherPerson: other,
    messages: list,
    unreadCount: unread,
    lastMessageContent: last.privateMessage.content,
    lastMessageTime: InboxItem.parsePublished(last.privateMessage.published),
  );
}

void _sortPmsOldestFirst(List<PrivateMessageView> list) {
  list.sort((a, b) {
    final ta = InboxItem.parsePublished(a.privateMessage.published);
    final tb = InboxItem.parsePublished(b.privateMessage.published);
    return ta.compareTo(tb);
  });
}
