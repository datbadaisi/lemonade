import 'package:bluerum/shared/models/comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comment preserves Lemmy defaults and path helpers', () {
    final topLevel = Comment.fromJson(const {
      'id': '10',
      'creator_id': '2',
      'post_id': '5',
      'content': 'Top',
      'path': '0.10',
      'language_id': '1',
    });

    expect(topLevel.id, 10);
    expect(topLevel.creatorId, 2);
    expect(topLevel.postId, 5);
    expect(topLevel.local, isTrue);
    expect(topLevel.depth, 1);
    expect(topLevel.parentId, isNull);
    expect(topLevel.absoluteParentId, 10);

    final reply = Comment.fromJson(const {
      'id': '20',
      'creator_id': '3',
      'post_id': '5',
      'content': 'Reply',
      'path': '0.10.20',
      'language_id': '1',
    });

    expect(reply.depth, 2);
    expect(reply.parentId, 10);
    expect(reply.absoluteParentId, 10);
  });

  test('CommentView nests Freezed entities and coerces my_vote', () {
    final view = CommentView.fromJson(const {
      'comment': {
        'id': '10',
        'creator_id': '2',
        'post_id': '5',
        'content': 'Hi',
        'path': '0.10',
        'language_id': '1',
      },
      'creator': {'id': '2', 'name': 'bob', 'instance_id': '1'},
      'community': {
        'id': '3',
        'name': 'news',
        'title': 'News',
        'instance_id': '1',
      },
      'post': {
        'id': '5',
        'name': 'Hello',
        'creator_id': '2',
        'community_id': '3',
      },
      'counts': {
        'comment_id': '10',
        'score': '3',
        'upvotes': '4',
        'downvotes': '1',
        'published': '2024-01-01T00:00:00Z',
        'child_count': '0',
      },
      'my_vote': '-1',
    });

    expect(view.comment.content, 'Hi');
    expect(view.creator.name, 'bob');
    expect(view.community.name, 'news');
    expect(view.post.id, 5);
    expect(view.counts.score, 3);
    expect(view.myVote, -1);
    expect(view.subscribed, 'NotSubscribed');
    expect(view.saved, isFalse);
  });
}
