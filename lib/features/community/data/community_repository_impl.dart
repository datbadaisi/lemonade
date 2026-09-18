import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/features/post/data/post_repository_impl.dart';
import 'package:bluerum/shared/models/post.dart';
import '../domain/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => LemmyCommunityRepository(ref.watch(lemmyApiClientProvider)),
);

/// Community IDs the user joined this session (hides Subscribe on all post cards).
final sessionSubscribedCommunityIdsProvider =
    NotifierProvider<SessionSubscribedCommunityIds, Set<int>>(
  SessionSubscribedCommunityIds.new,
);

final class SessionSubscribedCommunityIds extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void add(int communityId) {
    if (state.contains(communityId)) return;
    state = {...state, communityId};
  }

  void clear() {
    if (state.isEmpty) return;
    state = {};
  }
}

/// Clears in-memory session caches when the user logs out or switches account.
/// Watched from [BluerumApp] so it stays alive for the app lifetime.
final authSessionSideEffectsProvider = Provider<void>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  var lastAccountId = auth.activeAccountId;
  var lastLoggedIn = auth.isLoggedIn;

  void clearSessionCaches() {
    // Defer so we never mutate providers during build.
    Future.microtask(() {
      ref.read(sessionSubscribedCommunityIdsProvider.notifier).clear();
      ref.read(sessionReadPostIdsProvider.notifier).clear();
    });
  }

  void onAuthChanged() {
    final loggedIn = auth.isLoggedIn;
    final accountId = auth.activeAccountId;
    final loggedOut = lastLoggedIn && !loggedIn;
    final switched =
        lastLoggedIn && loggedIn && lastAccountId != accountId;
    lastLoggedIn = loggedIn;
    lastAccountId = accountId;
    if (loggedOut || switched) {
      clearSessionCaches();
    }
  }

  auth.addListener(onAuthChanged);
  onAuthChanged();
  ref.onDispose(() => auth.removeListener(onAuthChanged));
});

final class LemmyCommunityRepository implements CommunityRepository {
  const LemmyCommunityRepository(this._client);

  final LemmyApiService _client;

  @override
  Future<CommunityView> get({int? id, String? name}) =>
      _client.getCommunity(id: id, name: name);

  @override
  Future<CommunityView> follow({
    required int communityId,
    required bool follow,
  }) => _client.followCommunity(communityId: communityId, follow: follow);

  @override
  Future<bool> block({required int communityId, required bool block}) =>
      _client.blockCommunity(communityId: communityId, block: block);
}
