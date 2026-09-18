import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/shared/models/post.dart';
import '../data/feed_repository_impl.dart';
import 'post_interaction_providers.dart';

// ── Entity store (new Map instance on every mutation) ──────────────────

final feedPostsByIdProvider =
    NotifierProvider<FeedPostsById, Map<int, PostView>>(FeedPostsById.new);

final class FeedPostsById extends Notifier<Map<int, PostView>> {
  @override
  Map<int, PostView> build() => const {};

  void replaceAll(Map<int, PostView> next) =>
      state = Map<int, PostView>.unmodifiable(next);

  void upsert(int id, PostView pv) {
    state = Map<int, PostView>.unmodifiable({...state, id: pv});
  }

  /// Merge [additions] keeping existing instances for unchanged ids.
  void mergeKeeping(Map<int, PostView> additions) {
    if (additions.isEmpty) return;
    state = Map<int, PostView>.unmodifiable({...state, ...additions});
  }

  void clear() {
    if (state.isEmpty) return;
    state = const {};
  }
}

/// Soft lookup — cards select by id so only that entry rebuilds.
final postViewProvider = Provider.family<PostView?, int>((ref, id) {
  return ref.watch(feedPostsByIdProvider.select((m) => m[id]));
});

// ── List chrome state (ids + flags only) ───────────────────────────────

final feedControllerProvider =
    NotifierProvider<FeedController, FeedListState>(FeedController.new);

/// List-watch surface: identity is [postIds] + chrome flags — not entities.
final class FeedListState {
  const FeedListState({
    this.postIds = const [],
    this.sort = 'Active',
    this.type = 'All',
    this.page = 1,
    this.loadEpoch = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.loadMoreError,
  });

  final List<int> postIds;
  final String sort;
  final String type;
  final int page;
  final int loadEpoch;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
  final Object? loadMoreError;

  FeedListState copyWith({
    List<int>? postIds,
    String? sort,
    String? type,
    int? page,
    int? loadEpoch,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error = _unset,
    Object? loadMoreError = _unset,
  }) =>
      FeedListState(
        postIds: postIds ?? this.postIds,
        sort: sort ?? this.sort,
        type: type ?? this.type,
        page: page ?? this.page,
        loadEpoch: loadEpoch ?? this.loadEpoch,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: identical(error, _unset) ? this.error : error,
        loadMoreError:
            identical(loadMoreError, _unset) ? this.loadMoreError : loadMoreError,
      );
}

const _unset = Object();

final class FeedController extends Notifier<FeedListState> {
  static const _pageSize = 20;
  static const _prefSort = 'bluerum_home_sort';
  static const _prefType = 'bluerum_home_type';

  @override
  FeedListState build() => const FeedListState();

  FeedPostsById get _entities => ref.read(feedPostsByIdProvider.notifier);

  /// Load sort/type from prefs then fetch page 1.
  Future<void> bootstrap({bool canUseSubscribed = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var type = prefs.getString(_prefType) ?? 'All';
      if (type == 'Subscribed' && !canUseSubscribed) {
        type = 'All';
        await prefs.setString(_prefType, 'All');
      }
      final sort = prefs.getString(_prefSort) ?? 'Active';
      state = state.copyWith(sort: sort, type: type);
    } catch (_) {
      // Keep defaults.
    }
    await load();
  }

  Future<void> load({bool keepExisting = false}) async {
    final epoch = state.loadEpoch + 1;
    final hadPosts = state.postIds.isNotEmpty;
    final canKeep = keepExisting && hadPosts;

    state = state.copyWith(
      loadEpoch: epoch,
      isLoading: !canKeep,
      isLoadingMore: false,
      page: 1,
      hasMore: true,
      error: null,
      loadMoreError: null,
    );

    if (!canKeep) {
      ref.read(postMyVoteOverlaysProvider.notifier).clearAll();
      ref.read(postSavedOverlaysProvider.notifier).clearAll();
    }

    try {
      final posts = await ref.read(feedRepositoryProvider).getPosts(
            sort: state.sort,
            type: state.type,
            page: 1,
            limit: _pageSize,
          );
      if (state.loadEpoch != epoch) return;

      final ids = posts.map((p) => p.post.id).toList(growable: false);
      // keepExisting: reuse prior PostView instances when the server returns
      // the same object identity fields for an id — avoids mass VM recompute
      // for posts that did not change (smoother post-refresh paint).
      if (canKeep) {
        final prev = ref.read(feedPostsByIdProvider);
        final map = <int, PostView>{};
        for (final p in posts) {
          final id = p.post.id;
          final old = prev[id];
          map[id] = (old != null && _sameFeedPostSurface(old, p)) ? old : p;
        }
        _entities.replaceAll(map);
      } else {
        _entities.replaceAll({
          for (final p in posts) p.post.id: p,
        });
      }
      ref.read(postMyVoteOverlaysProvider.notifier).clearAll();
      ref.read(postSavedOverlaysProvider.notifier).clearAll();

      state = state.copyWith(
        postIds: ids,
        isLoading: false,
        page: 1,
        hasMore: posts.length >= _pageSize,
        error: null,
      );
    } catch (error) {
      if (state.loadEpoch != epoch) return;
      state = state.copyWith(
        isLoading: false,
        error: canKeep ? null : error,
      );
    }
  }

  /// Cheap equality for refresh reuse — same id + score/vote/save/name/body.
  static bool _sameFeedPostSurface(PostView a, PostView b) {
    if (identical(a, b)) return true;
    final ap = a.post;
    final bp = b.post;
    return ap.id == bp.id &&
        ap.name == bp.name &&
        ap.body == bp.body &&
        ap.deleted == bp.deleted &&
        ap.removed == bp.removed &&
        ap.nsfw == bp.nsfw &&
        ap.thumbnailUrl == bp.thumbnailUrl &&
        ap.url == bp.url &&
        a.counts.score == b.counts.score &&
        a.counts.comments == b.counts.comments &&
        a.myVote == b.myVote &&
        a.saved == b.saved &&
        a.read == b.read &&
        a.subscribed == b.subscribed;
  }

  Future<void> refresh() => load(keepExisting: true);

  /// Inserts a newly created post at the head (deduped).
  void prependPost(PostView post) {
    final id = post.post.id;
    _entities.upsert(id, post);
    final without = state.postIds.where((x) => x != id);
    state = state.copyWith(postIds: [id, ...without]);
  }

  /// Single filter entry: update sort and/or type, persist prefs, reload.
  ///
  /// Pass only the fields that should change. When both are null, reloads
  /// with the current filter (same as a forced [load]).
  Future<void> applyFilter({String? sort, String? type}) async {
    final nextSort = sort ?? state.sort;
    final nextType = type ?? state.type;
    final changed = nextSort != state.sort || nextType != state.type;
    if (changed) {
      state = state.copyWith(sort: nextSort, type: nextType);
      try {
        final prefs = await SharedPreferences.getInstance();
        if (sort != null) await prefs.setString(_prefSort, nextSort);
        if (type != null) await prefs.setString(_prefType, nextType);
      } catch (_) {}
    }
    await load();
  }

  Future<void> changeFilter({String? sort, String? type}) =>
      applyFilter(sort: sort, type: type);

  Future<void> setSort(String sort) async {
    if (sort == state.sort) return;
    await applyFilter(sort: sort);
  }

  Future<void> setType(String type) async {
    if (type == state.type) return;
    await applyFilter(type: type);
  }

  /// Force type without network (e.g. logout demotes Subscribed → All).
  Future<void> demoteTypeIfNeeded(String type) async {
    if (state.type == type) return;
    state = state.copyWith(type: type);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefType, type);
    } catch (_) {}
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final epoch = state.loadEpoch;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, loadMoreError: null);
    try {
      final next = await ref.read(feedRepositoryProvider).getPosts(
            sort: state.sort,
            type: state.type,
            page: nextPage,
            limit: _pageSize,
          );
      // Filter changed mid-flight — discard page.
      if (state.loadEpoch != epoch) return;

      final seen = state.postIds.toSet();
      final additions = <int, PostView>{};
      final newIds = <int>[];
      for (final p in next) {
        final id = p.post.id;
        if (seen.add(id)) {
          additions[id] = p;
          newIds.add(id);
        }
      }
      // Keep prior PostView instances; only add new keys.
      _entities.mergeKeeping(additions);

      final active = {...state.postIds, ...newIds}.toSet();
      ref.read(postMyVoteOverlaysProvider.notifier).retainOnly(active);
      ref.read(postSavedOverlaysProvider.notifier).retainOnly(active);

      state = state.copyWith(
        postIds: [...state.postIds, ...newIds],
        page: nextPage,
        isLoadingMore: false,
        hasMore: next.length >= _pageSize && newIds.isNotEmpty,
      );
    } catch (error) {
      if (state.loadEpoch != epoch) return;
      state = state.copyWith(isLoadingMore: false, loadMoreError: error);
    }
  }
}

/// Whether the active session may request Subscribed listing.
bool feedCanUseSubscribed(AuthService auth) => auth.isLoggedIn;
