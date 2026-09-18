import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/shared/models/post.dart';

// ── Overlay maps: null key = no overlay (use server base) ──────────────

/// Optimistic myVote overlays. Key present ⇒ overlay; value is -1 | 0 | 1.
final postMyVoteOverlaysProvider =
    NotifierProvider<PostMyVoteOverlays, Map<int, int>>(PostMyVoteOverlays.new);

final class PostMyVoteOverlays extends Notifier<Map<int, int>> {
  @override
  Map<int, int> build() => const {};

  void setOptimistic(int postId, int score) {
    state = {...state, postId: score};
  }

  void clear(int postId) {
    if (!state.containsKey(postId)) return;
    final next = Map<int, int>.of(state)..remove(postId);
    state = next;
  }

  void clearAll() {
    if (state.isEmpty) return;
    state = const {};
  }

  void retainOnly(Set<int> activeIds) {
    if (state.isEmpty) return;
    final next = <int, int>{
      for (final e in state.entries)
        if (activeIds.contains(e.key)) e.key: e.value,
    };
    if (next.length != state.length) state = next;
  }
}

/// Optimistic saved overlays. Key present ⇒ overlay bool.
final postSavedOverlaysProvider =
    NotifierProvider<PostSavedOverlays, Map<int, bool>>(PostSavedOverlays.new);

final class PostSavedOverlays extends Notifier<Map<int, bool>> {
  @override
  Map<int, bool> build() => const {};

  void setOptimistic(int postId, bool saved) {
    state = {...state, postId: saved};
  }

  void clear(int postId) {
    if (!state.containsKey(postId)) return;
    final next = Map<int, bool>.of(state)..remove(postId);
    state = next;
  }

  void clearAll() {
    if (state.isEmpty) return;
    state = const {};
  }

  void retainOnly(Set<int> activeIds) {
    if (state.isEmpty) return;
    final next = <int, bool>{
      for (final e in state.entries)
        if (activeIds.contains(e.key)) e.key: e.value,
    };
    if (next.length != state.length) state = next;
  }
}

// ── Pure score / effective helpers (single entry points) ───────────────

int effectiveMyVote(PostView base, int? overlay) => overlay ?? base.myVote ?? 0;

bool effectiveSaved(PostView base, bool? overlay) => overlay ?? base.saved;

/// Matches prior `_BottomBar` formula: adjust displayed score from base.
int displayScore(PostView base, int effectiveVote) =>
    base.counts.score + effectiveVote - (base.myVote ?? 0);

// ── Select helpers for cards ───────────────────────────────────────────

/// Overlay for [postId], or null when absent.
int? voteOverlayOf(Map<int, int> map, int postId) => map[postId];

bool? savedOverlayOf(Map<int, bool> map, int postId) => map[postId];
