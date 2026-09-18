import 'package:bluerum/shared/models/comment.dart';

import 'comment_repository.dart';

/// Create-or-edit entry used by [CommentComposeScreen] submit.
///
/// Keeps presentation free of raw LemmyApiService write calls.
Future<CommentView> submitComment({
  required CommentRepository repository,
  required String content,
  required int postId,
  int? parentId,
  int? editingCommentId,
}) {
  if (editingCommentId != null) {
    return repository.edit(commentId: editingCommentId, content: content);
  }
  return repository.create(
    content: content,
    postId: postId,
    parentId: parentId,
  );
}
