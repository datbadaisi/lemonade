import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Community preserves Lemmy coercions and defaults', () {
    final community = Community.fromJson(const {
      'id': '9',
      'name': 'tech',
      'title': 'Technology',
      'instance_id': '3',
      'posting_restricted_to_mods': true,
    });

    expect(community.id, 9);
    expect(community.name, 'tech');
    expect(community.title, 'Technology');
    expect(community.instanceId, 3);
    expect(community.postingRestrictedToMods, isTrue);
    expect(community.local, isTrue);
    expect(community.nsfw, isFalse);
    expect(community.actorId, '');
  });

  test('PostView nests Freezed entities and coerces my_vote', () {
    final view = PostView.fromJson(const {
      'post': {
        'id': '1',
        'name': 'Hello',
        'creator_id': '2',
        'community_id': '3',
      },
      'creator': {'id': '2', 'name': 'bob', 'instance_id': '1'},
      'community': {
        'id': '3',
        'name': 'news',
        'title': 'News',
        'instance_id': '1',
      },
      'counts': {
        'post_id': '1',
        'comments': '4',
        'score': '10',
        'upvotes': '12',
        'downvotes': '2',
        'published': '2024-01-01T00:00:00Z',
        'newest_comment_time': '2024-01-02T00:00:00Z',
      },
      'my_vote': '1',
      'unread_comments': '5',
    });

    expect(view.post.id, 1);
    expect(view.creator.name, 'bob');
    expect(view.community.name, 'news');
    expect(view.counts.comments, 4);
    expect(view.myVote, 1);
    expect(view.unreadComments, 5);
    expect(view.subscribed, 'NotSubscribed');
    expect(view.saved, isFalse);
  });
}
