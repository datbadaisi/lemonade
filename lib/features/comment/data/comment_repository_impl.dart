import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/shared/models/comment.dart';
import '../domain/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => LemmyCommentRepository(ref.watch(lemmyApiClientProvider)),
);

final class LemmyCommentRepository implements CommentRepository {
  const LemmyCommentRepository(this._client);

  final LemmyApiService _client;

  @override
  Future<List<CommentView>> listForPost({
    required int postId,
    required String sort,
    int? maxDepth,
    int? parentId,
    int page = 1,
    int limit = 50,
  }) {
    final sortType = CommentSortType.values.firstWhere(
      (s) => s.value == sort,
      orElse: () => CommentSortType.hot,
    );
    return _client.getComments(
      postId: postId,
      parentId: parentId,
      sort: sortType,
      maxDepth: maxDepth,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<CommentView> get(int commentId) => _client.getComment(commentId);

  @override
  Future<CommentView> create({
    required String content,
    required int postId,
    int? parentId,
  }) => _client.createComment(
    content: content,
    postId: postId,
    parentId: parentId,
  );

  @override
  Future<CommentView> edit({
    required int commentId,
    required String content,
  }) => _client.editComment(commentId: commentId, content: content);

  @override
  Future<CommentView> vote({required int commentId, required int score}) =>
      _client.likeComment(commentId: commentId, score: score);

  @override
  Future<CommentView> delete({
    required int commentId,
    required bool deleted,
  }) => _client.deleteComment(commentId: commentId, deleted: deleted);

  @override
  Future<void> report({
    required int commentId,
    required String reason,
  }) async {
    await _client.createCommentReport(commentId: commentId, reason: reason);
  }

  @override
  Future<void> blockPerson({
    required int personId,
    required bool block,
  }) async {
    await _client.blockPerson(personId: personId, block: block);
  }
}
