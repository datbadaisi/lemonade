import 'package:bluerum/features/post/data/comment_page_cache.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

CommentView _fakeComment(int id) {
  return CommentView(
    comment: Comment(
      id: id,
      creatorId: 1,
      postId: 10,
      content: 'c$id',
      path: '0.$id',
      languageId: 0,
    ),
    creator: const Person(id: 1, name: 'u', instanceId: 1),
    community: const Community(id: 1, name: 'c', title: 'C'),
    post: const Post(id: 10, name: 'p', creatorId: 1, communityId: 1),
    counts: CommentAggregates(
      commentId: id,
      score: 1,
      upvotes: 1,
      downvotes: 0,
    ),
  );
}

void main() {
  test('read returns written page and promotes LRU', () {
    final cache = CommentPageCache();
    final full = [
      _fakeComment(1),
      _fakeComment(2),
      _fakeComment(3),
      _fakeComment(4),
    ];

    cache.write(
      postId: 10,
      threadRootId: null,
      sort: CommentSortType.hot,
      sessionId: 0,
      comments: full,
      parentComment: null,
      hasMore: false,
    );

    final entry = cache.read(
      postId: 10,
      threadRootId: null,
      sort: CommentSortType.hot,
      sessionId: 0,
    );
    expect(entry, isNotNull);
    expect(entry!.comments.length, 4);
    expect(entry.hasMore, isFalse);
  });

  test('has returns false after clear', () {
    final cache = CommentPageCache();
    cache.write(
      postId: 1,
      threadRootId: null,
      sort: CommentSortType.hot,
      sessionId: 1,
      comments: [_fakeComment(1)],
      parentComment: null,
      hasMore: true,
    );
    expect(
      cache.has(
        postId: 1,
        threadRootId: null,
        sort: CommentSortType.hot,
        sessionId: 1,
      ),
      isTrue,
    );
    cache.clear();
    expect(
      cache.has(
        postId: 1,
        threadRootId: null,
        sort: CommentSortType.hot,
        sessionId: 1,
      ),
      isFalse,
    );
  });
}
