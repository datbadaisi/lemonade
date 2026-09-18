import 'package:bluerum/features/notifications/domain/inbox_item.dart';
import 'package:bluerum/features/notifications/domain/inbox_merge.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeInboxPage1', () {
    test('merges replies and mentions sorted newest first', () {
      final replies = [
        _reply(id: 1, published: '2024-01-01T10:00:00Z'),
        _reply(id: 2, published: '2024-01-03T10:00:00Z'),
      ];
      final mentions = [
        _mention(id: 10, published: '2024-01-02T10:00:00Z'),
      ];

      final result = mergeInboxPage1(replies: replies, mentions: mentions);

      expect(result.items.map((e) => e.listKey).toList(), [
        'r_2',
        'm_10',
        'r_1',
      ]);
      expect(result.hasMoreReplies, isFalse);
      expect(result.hasMoreMentions, isFalse);
    });

    test('hasMore when a stream returns a full page', () {
      final replies = [
        for (var i = 0; i < 30; i++)
          _reply(id: i, published: '2024-01-01T10:00:00Z'),
      ];
      final result = mergeInboxPage1(
        replies: replies,
        mentions: const [],
        pageSize: 30,
      );
      expect(result.hasMoreReplies, isTrue);
      expect(result.hasMoreMentions, isFalse);
      expect(result.hasMore, isTrue);
    });
  });

  group('appendInboxPage', () {
    test('dedupes by notification id and advances only fetched streams', () {
      final existing = mergeInboxPage1(
        replies: [_reply(id: 1, published: '2024-01-05T10:00:00Z')],
        mentions: [_mention(id: 10, published: '2024-01-04T10:00:00Z')],
      ).items;

      final result = appendInboxPage(
        existing: existing,
        replies: [
          _reply(id: 1, published: '2024-01-05T10:00:00Z'), // dup
          _reply(id: 3, published: '2024-01-06T10:00:00Z'),
        ],
        mentions: const [],
        previousHasMoreReplies: true,
        previousHasMoreMentions: false,
        fetchedReplies: true,
        fetchedMentions: false,
        pageSize: 30,
      );

      expect(result.appendedCount, 1);
      expect(result.items.map((e) => e.listKey).toList(), [
        'r_3',
        'r_1',
        'm_10',
      ]);
      expect(result.hasMoreReplies, isFalse); // short page
      expect(result.hasMoreMentions, isFalse); // not fetched, was already false
    });

    test('full page of only duplicates stops that stream', () {
      final existing = [
        InboxItem.reply(_reply(id: 1, published: '2024-01-01T10:00:00Z')),
      ];
      final fullDupPage = [
        for (var i = 0; i < 30; i++)
          _reply(id: 1, published: '2024-01-01T10:00:00Z'),
      ];

      final result = appendInboxPage(
        existing: existing,
        replies: fullDupPage,
        mentions: const [],
        previousHasMoreReplies: true,
        previousHasMoreMentions: true,
        fetchedReplies: true,
        fetchedMentions: false,
        pageSize: 30,
      );

      expect(result.appendedCount, 0);
      expect(result.hasMoreReplies, isFalse);
      expect(result.hasMoreMentions, isTrue); // untouched
    });
  });

  group('replaceInboxItem / markRead / countUnread', () {
    test('markRead + replace updates a single row', () {
      final items = [
        InboxItem.reply(
          _reply(id: 1, published: '2024-01-01T10:00:00Z', read: false),
        ),
        InboxItem.mention(
          _mention(id: 2, published: '2024-01-02T10:00:00Z', read: false),
        ),
      ];

      final updated = items.first.markRead();
      final next = replaceInboxItem(items, updated);

      expect(next[0].isRead, isTrue);
      expect(next[1].isRead, isFalse);
      expect(countUnreadInList(next), (replies: 0, mentions: 1));
    });
  });

  group('InboxItem type labels', () {
    test('reply to post vs comment', () {
      final postReply = InboxItem.reply(
        _reply(id: 1, published: '2024-01-01T10:00:00Z', parentId: null),
      );
      final commentReply = InboxItem.reply(
        _reply(id: 2, published: '2024-01-01T10:00:00Z', parentId: 99),
      );
      expect(postReply.typeLabel, 'replied to your post');
      expect(commentReply.typeLabel, 'replied to your comment');
      expect(
        InboxItem.mention(
          _mention(id: 3, published: '2024-01-01T10:00:00Z'),
        ).typeLabel,
        'mentioned you in a comment',
      );
    });
  });
}

CommentReplyView _reply({
  required int id,
  required String published,
  bool read = false,
  int? parentId,
}) {
  final commentId = id * 10;
  // parentId is derived from path: "0.id" top-level, "0.parent.id" reply.
  final path =
      parentId == null ? '0.$commentId' : '0.$parentId.$commentId';
  return CommentReplyView(
    commentReply: CommentReply(
      id: id,
      recipientId: 1,
      commentId: commentId,
      read: read,
      published: published,
    ),
    comment: Comment(
      id: commentId,
      creatorId: 2,
      postId: 5,
      content: 'hello',
      removed: false,
      published: published,
      deleted: false,
      apId: '',
      local: true,
      path: path,
      distinguished: false,
      languageId: 0,
    ),
    creator: const Person(id: 2, name: 'alice'),
    post: const Post(id: 5, name: 'Post', creatorId: 2, communityId: 1),
    community: const Community(id: 1, name: 'c', title: 'C'),
    recipient: const Person(id: 1, name: 'bob'),
    counts: CommentAggregates(commentId: commentId),
  );
}

PersonMentionView _mention({
  required int id,
  required String published,
  bool read = false,
}) {
  final commentId = id * 10;
  return PersonMentionView(
    personMention: PersonMention(
      id: id,
      recipientId: 1,
      commentId: commentId,
      read: read,
      published: published,
    ),
    comment: Comment(
      id: commentId,
      creatorId: 2,
      postId: 5,
      content: 'hi @bob',
      removed: false,
      published: published,
      deleted: false,
      apId: '',
      local: true,
      path: '0.$commentId',
      distinguished: false,
      languageId: 0,
    ),
    creator: const Person(id: 2, name: 'alice'),
    post: const Post(id: 5, name: 'Post', creatorId: 2, communityId: 1),
    community: const Community(id: 1, name: 'c', title: 'C'),
    recipient: const Person(id: 1, name: 'bob'),
    counts: CommentAggregates(commentId: commentId),
  );
}
