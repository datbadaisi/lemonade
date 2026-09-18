import 'package:bluerum/features/notifications/domain/chat_thread.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const me = 1;
  const other = 2;
  const third = 3;

  group('groupPrivateMessages', () {
    test('groups by other participant, sorts threads by last message', () {
      final messages = [
        _pm(
          id: 1,
          creatorId: other,
          recipientId: me,
          content: 'hey',
          published: '2024-01-01T10:00:00Z',
          read: true,
        ),
        _pm(
          id: 2,
          creatorId: me,
          recipientId: other,
          content: 'hi back',
          published: '2024-01-01T11:00:00Z',
          read: true,
        ),
        _pm(
          id: 3,
          creatorId: third,
          recipientId: me,
          content: 'newer thread',
          published: '2024-01-02T10:00:00Z',
          read: false,
        ),
      ];

      final threads = groupPrivateMessages(messages, currentUserId: me);

      expect(threads.length, 2);
      expect(threads.first.otherPerson.id, third);
      expect(threads.first.unreadCount, 1);
      expect(threads.first.lastMessageContent, 'newer thread');
      expect(threads.last.otherPerson.id, other);
      expect(threads.last.lastMessageContent, 'hi back');
      expect(threads.last.unreadCount, 0);
    });

    test('does not count own outbound as unread', () {
      final messages = [
        _pm(
          id: 1,
          creatorId: me,
          recipientId: other,
          content: 'sent',
          published: '2024-01-01T10:00:00Z',
          read: false,
        ),
      ];
      final threads = groupPrivateMessages(messages, currentUserId: me);
      expect(threads.single.unreadCount, 0);
    });
  });

  group('mergePrivateMessagePage', () {
    test('merges new messages and counts only brand-new pm ids', () {
      final existing = groupPrivateMessages(
        [
          _pm(
            id: 1,
            creatorId: other,
            recipientId: me,
            content: 'old',
            published: '2024-01-01T10:00:00Z',
            read: true,
          ),
        ],
        currentUserId: me,
      );

      final merged = mergePrivateMessagePage(
        existing: existing,
        page: [
          _pm(
            id: 1,
            creatorId: other,
            recipientId: me,
            content: 'old',
            published: '2024-01-01T10:00:00Z',
            read: true,
          ),
          _pm(
            id: 2,
            creatorId: other,
            recipientId: me,
            content: 'new',
            published: '2024-01-01T12:00:00Z',
            read: false,
          ),
        ],
        currentUserId: me,
      );

      expect(merged.newPmCount, 1);
      expect(merged.threads.single.messages.length, 2);
      expect(merged.threads.single.lastMessageContent, 'new');
      expect(merged.threads.single.unreadCount, 1);
    });

    test('creates a new thread when other person is new', () {
      final existing = groupPrivateMessages(
        [
          _pm(
            id: 1,
            creatorId: other,
            recipientId: me,
            content: 'a',
            published: '2024-01-01T10:00:00Z',
          ),
        ],
        currentUserId: me,
      );

      final merged = mergePrivateMessagePage(
        existing: existing,
        page: [
          _pm(
            id: 9,
            creatorId: third,
            recipientId: me,
            content: 'b',
            published: '2024-01-03T10:00:00Z',
            read: false,
          ),
        ],
        currentUserId: me,
      );

      expect(merged.newPmCount, 1);
      expect(merged.threads.length, 2);
      expect(merged.threads.first.otherPerson.id, third);
    });
  });
}

PrivateMessageView _pm({
  required int id,
  required int creatorId,
  required int recipientId,
  required String content,
  required String published,
  bool read = true,
}) {
  return PrivateMessageView(
    privateMessage: PrivateMessage(
      id: id,
      creatorId: creatorId,
      recipientId: recipientId,
      content: content,
      deleted: false,
      read: read,
      published: published,
      apId: '',
      local: true,
    ),
    creator: Person(id: creatorId, name: 'u$creatorId'),
    recipient: Person(id: recipientId, name: 'u$recipientId'),
  );
}
