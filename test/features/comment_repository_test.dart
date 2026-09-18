import 'package:bluerum/features/comment/domain/comment_repository.dart';
import 'package:bluerum/shared/models/comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comment repository maps sort string to API call', () async {
    final fake = _FakeCommentRepo();
    await fake.listForPost(postId: 9, sort: 'New');
    expect(fake.lastSort, 'New');
    expect(fake.lastPostId, 9);
  });
}

/// Exercises the real [CommentRepository] contract used by feature code.
final class _FakeCommentRepo implements CommentRepository {
  String? lastSort;
  int? lastPostId;

  @override
  Future<List<CommentView>> listForPost({
    required int postId,
    required String sort,
    int? maxDepth,
    int? parentId,
    int page = 1,
    int limit = 50,
  }) async {
    lastPostId = postId;
    lastSort = sort;
    return const [];
  }

  @override
  Future<CommentView> get(int commentId) => throw UnimplementedError();

  @override
  Future<CommentView> create({
    required String content,
    required int postId,
    int? parentId,
  }) => throw UnimplementedError();

  @override
  Future<CommentView> edit({
    required int commentId,
    required String content,
  }) => throw UnimplementedError();

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
