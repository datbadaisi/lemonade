import 'package:flutter/foundation.dart';

/// Per-screen vote/save overlays for [PostDetailScreen].
///
/// Comment votes use **per-id** [ValueNotifier]s so a single upvote only
/// rebuilds that comment tile — not the whole ListView parent.
final class PostDetailVoteStore {
  PostDetailVoteStore({
    required int postVote,
    required bool postSaved,
    Map<int, int>? seedCommentVotes,
  })  : postVote = ValueNotifier<int>(postVote),
        postSaved = ValueNotifier<bool>(postSaved) {
    if (seedCommentVotes != null) {
      for (final e in seedCommentVotes.entries) {
        commentVoteListenable(e.key).value = e.value;
      }
    }
  }

  final ValueNotifier<int> postVote;
  final ValueNotifier<bool> postSaved;
  final Map<int, ValueNotifier<int?>> _commentVotes = {};

  ValueNotifier<int?> commentVoteListenable(int commentId) =>
      _commentVotes.putIfAbsent(commentId, () => ValueNotifier<int?>(null));

  int effectiveCommentVote(int commentId, int? baseMyVote) =>
      commentVoteListenable(commentId).value ?? baseMyVote ?? 0;

  void setCommentVote(int commentId, int score) {
    commentVoteListenable(commentId).value = score;
  }

  /// Snapshot of absolute overlays for nested thread screens.
  Map<int, int> snapshotCommentVotes() {
    final out = <int, int>{};
    for (final e in _commentVotes.entries) {
      final v = e.value.value;
      if (v != null) out[e.key] = v;
    }
    return out;
  }

  void clearCommentVotes() {
    for (final n in _commentVotes.values) {
      n.value = null;
    }
  }

  void dispose() {
    for (final n in _commentVotes.values) {
      n.dispose();
    }
    _commentVotes.clear();
    postVote.dispose();
    postSaved.dispose();
  }
}
