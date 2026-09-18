import 'package:bluerum/app/providers.dart';
import 'package:bluerum/features/feed/presentation/feed_controller.dart';
import 'package:bluerum/features/feed/presentation/post_interaction_providers.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vote/save for **any** surface post list — does not require the post to live
/// in home [feedPostsByIdProvider]. Still bridges into the feed map when present
/// and uses global optimistic overlays so tiles rebuild in isolation.
///
/// This is the **canonical** mutation path for Home and secondary surfaces.
Future<bool> toggleSurfacePostUpvote(
  WidgetRef ref,
  PostView base, {
  void Function(PostView updated)? onUpdated,
}) =>
    _toggleVote(ref, base, targetWhenNot: 1, onUpdated: onUpdated);

Future<bool> toggleSurfacePostDownvote(
  WidgetRef ref,
  PostView base, {
  void Function(PostView updated)? onUpdated,
}) =>
    _toggleVote(ref, base, targetWhenNot: -1, onUpdated: onUpdated);

/// Home convenience: resolve [postId] from the feed entity map then vote.
Future<bool> togglePostUpvote(WidgetRef ref, int postId) async {
  final base = ref.read(feedPostsByIdProvider)[postId];
  if (base == null) return false;
  return toggleSurfacePostUpvote(ref, base);
}

Future<bool> togglePostDownvote(WidgetRef ref, int postId) async {
  final base = ref.read(feedPostsByIdProvider)[postId];
  if (base == null) return false;
  return toggleSurfacePostDownvote(ref, base);
}

Future<bool> togglePostSave(WidgetRef ref, int postId) async {
  final base = ref.read(feedPostsByIdProvider)[postId];
  if (base == null) return false;
  return toggleSurfacePostSave(ref, base);
}

Future<bool> toggleSurfacePostSave(
  WidgetRef ref,
  PostView base, {
  void Function(PostView updated)? onUpdated,
  bool removeWhenUnsaved = false,
}) async {
  final postId = base.post.id;
  final overlay = ref.read(postSavedOverlaysProvider)[postId];
  final current = effectiveSaved(base, overlay);
  final next = !current;
  ref.read(postSavedOverlaysProvider.notifier).setOptimistic(postId, next);
  try {
    final api = ref.read(lemmyApiClientProvider);
    await api.savePost(postId: postId, save: next);
    // API may not return full PostView — synthesize base with saved flipped.
    final updated = _withSaved(base, next);
    _bridgeFeed(ref, updated);
    // Silent base update + keep overlay so list parents need not rebuild.
    // Overlay already matches server; tile rebuilds via select(postId) only.
    onUpdated?.call(updated);
    return true;
  } catch (_) {
    ref.read(postSavedOverlaysProvider.notifier).clear(postId);
    return false;
  }
}

Future<bool> _toggleVote(
  WidgetRef ref,
  PostView base, {
  required int targetWhenNot,
  void Function(PostView updated)? onUpdated,
}) async {
  final postId = base.post.id;
  final overlay = ref.read(postMyVoteOverlaysProvider)[postId];
  final current = effectiveMyVote(base, overlay);
  final next = current == targetWhenNot ? 0 : targetWhenNot;
  ref.read(postMyVoteOverlaysProvider.notifier).setOptimistic(postId, next);
  try {
    final api = ref.read(lemmyApiClientProvider);
    await api.likePost(postId: postId, score: next);
    final updated = _withMyVote(base, next);
    _bridgeFeed(ref, updated);
    onUpdated?.call(updated);
    // Keep overlay on success — avoids full list rebuild when surface store
    // only updates silently; tile already shows correct vote via overlay.
    return true;
  } catch (_) {
    ref.read(postMyVoteOverlaysProvider.notifier).clear(postId);
    return false;
  }
}

void _bridgeFeed(WidgetRef ref, PostView updated) {
  final map = ref.read(feedPostsByIdProvider);
  if (map.containsKey(updated.post.id)) {
    ref.read(feedPostsByIdProvider.notifier).upsert(updated.post.id, updated);
  }
}

PostView _withMyVote(PostView base, int myVote) {
  final prev = base.myVote ?? 0;
  final scoreDelta = myVote - prev;
  return base.copyWith(
    myVote: myVote,
    counts: base.counts.copyWith(score: base.counts.score + scoreDelta),
  );
}

PostView _withSaved(PostView base, bool saved) => base.copyWith(saved: saved);
