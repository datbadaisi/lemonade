import 'package:bluerum/features/comment/domain/comment_repository.dart';
import 'package:bluerum/features/comment/domain/submit_comment.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('submitComment create path hits CommentRepository.create', () async {
    final repo = _RecordingCommentRepo();
    final cv = await submitComment(
      repository: repo,
      content: 'hello',
      postId: 5,
      parentId: 2,
    );
    expect(repo.created, isTrue);
    expect(repo.edited, isFalse);
    expect(repo.lastPostId, 5);
    expect(repo.lastContent, 'hello');
    expect(repo.lastParentId, 2);
    expect(cv.comment.content, 'hello');
  });

  test('submitComment edit path hits CommentRepository.edit', () async {
    final repo = _RecordingCommentRepo();
    final cv = await submitComment(
      repository: repo,
      content: 'updated',
      postId: 5,
      editingCommentId: 99,
    );
    expect(repo.edited, isTrue);
    expect(repo.created, isFalse);
    expect(repo.lastCommentId, 99);
    expect(repo.lastContent, 'updated');
    expect(cv.comment.id, 99);
  });
}

final class _RecordingCommentRepo implements CommentRepository {
  bool created = false;
  bool edited = false;
  int? lastPostId;
  int? lastParentId;
  int? lastCommentId;
  String? lastContent;

  @override
  Future<List<CommentView>> listForPost({
    required int postId,
    required String sort,
    int? maxDepth,
    int? parentId,
    int page = 1,
    int limit = 50,
  }) => throw UnimplementedError();

  @override
  Future<CommentView> get(int commentId) => throw UnimplementedError();

  @override
  Future<CommentView> create({
    required String content,
    required int postId,
    int? parentId,
  }) async {
    created = true;
    lastContent = content;
    lastPostId = postId;
    lastParentId = parentId;
    return _stub(id: 1, content: content);
  }

  @override
  Future<CommentView> edit({
    required int commentId,
    required String content,
  }) async {
    edited = true;
    lastCommentId = commentId;
    lastContent = content;
    return _stub(id: commentId, content: content);
  }

  @override
  Future<CommentView> vote({required int commentId, required int score}) =>
      throw UnimplementedError();

  @override
  Future<CommentView> delete({
    required int commentId,
    required bool deleted,
  }) => throw UnimplementedError();

  @override
  Future<void> report({
    required int commentId,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<void> blockPerson({
    required int personId,
    required bool block,
  }) => throw UnimplementedError();
}

CommentView _stub({required int id, required String content}) {
  return CommentView(
    comment: Comment(
      id: id,
      creatorId: 1,
      postId: 5,
      content: content,
      path: '0.$id',
      languageId: 0,
    ),
    creator: const Person(id: 1, name: 'u', instanceId: 1),
    community: const Community(id: 1, name: 'c', title: 'C'),
    post: const Post(id: 5, name: 'p', creatorId: 1, communityId: 1),
    counts: const CommentAggregates(
      commentId: 0,
      score: 0,
      upvotes: 0,
      downvotes: 0,
      published: '',
      childCount: 0,
    ),
  );
}
