import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/post/presentation/comment_thread_controller.dart';

/// Identity for a comment-thread controller instance.
///
/// [threadRootId] null = full post thread; non-null = continue-thread / focus.
@immutable
final class CommentThreadScope {
  const CommentThreadScope({
    required this.postId,
    this.threadRootId,
  });

  final int postId;
  final int? threadRootId;

  @override
  bool operator ==(Object other) =>
      other is CommentThreadScope &&
      other.postId == postId &&
      other.threadRootId == threadRootId;

  @override
  int get hashCode => Object.hash(postId, threadRootId);
}

/// Riverpod SSOT for [CommentThreadController] (Wave 7).
///
/// Auto-dispose when no screen watches the scope. Nested "Continue thread"
/// routes use a different [CommentThreadScope.threadRootId] so they do not
/// share collapse state with the parent list.
final commentThreadControllerProvider = Provider.autoDispose
    .family<CommentThreadController, CommentThreadScope>((ref, scope) {
  final controller = CommentThreadController();
  ref.onDispose(controller.dispose);
  return controller;
});
