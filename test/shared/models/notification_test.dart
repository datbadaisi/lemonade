import 'package:bluerum/shared/models/notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GetUnreadCountResponse coerces ints and totals', () {
    final counts = GetUnreadCountResponse.fromJson(const {
      'replies': '2',
      'mentions': 3,
      'private_messages': '1',
    });

    expect(counts.replies, 2);
    expect(counts.mentions, 3);
    expect(counts.privateMessages, 1);
    expect(counts.totalNotifications, 5);
    expect(counts.totalAll, 6);
  });

  test('CommentReplyView nests Freezed entities', () {
    final view = CommentReplyView.fromJson(const {
      'comment_reply': {
        'id': '1',
        'recipient_id': '9',
        'comment_id': '10',
        'read': false,
        'published': '2024-01-01T00:00:00Z',
      },
      'comment': {
        'id': '10',
        'creator_id': '2',
        'post_id': '5',
        'content': 'Hi',
        'path': '0.10',
        'language_id': '1',
      },
      'creator': {'id': '2', 'name': 'bob', 'instance_id': '1'},
      'post': {
        'id': '5',
        'name': 'Hello',
        'creator_id': '2',
        'community_id': '3',
      },
      'community': {
        'id': '3',
        'name': 'news',
        'title': 'News',
        'instance_id': '1',
      },
      'recipient': {'id': '9', 'name': 'alice', 'instance_id': '1'},
      'counts': {
        'comment_id': '10',
        'score': '1',
        'upvotes': '1',
        'downvotes': '0',
        'published': '2024-01-01T00:00:00Z',
        'child_count': '0',
      },
      'my_vote': '1',
    });

    expect(view.commentReply.id, 1);
    expect(view.comment.content, 'Hi');
    expect(view.creator.name, 'bob');
    expect(view.recipient.name, 'alice');
    expect(view.myVote, 1);
    expect(view.subscribed, 'NotSubscribed');
  });
}
