import 'package:bluerum/shared/models/comment.dart';

abstract interface class CommentRepository {
  Future<List<CommentView>> listForPost({
    required int postId,
    required String sort,
    int? maxDepth,
    int? parentId,
    int page,
    int limit,
  });

  Future<CommentView> get(int commentId);

  Future<CommentView> create({
    required String content,
    required int postId,
    int? parentId,
  });

  Future<CommentView> edit({
    required int commentId,
    required String content,
  });

  Future<CommentView> vote({required int commentId, required int score});

  Future<CommentView> delete({
    required int commentId,
    required bool deleted,
  });

  Future<void> report({
    required int commentId,
    required String reason,
  });

  Future<void> blockPerson({
    required int personId,
    required bool block,
  });
}
