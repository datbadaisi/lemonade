import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/lemmy_api_client.dart';
import '../core/storage/key_value_store.dart';
import '../core/storage/shared_prefs_store.dart';
import '../features/auth/data/auth_repository.dart';

final keyValueStoreProvider = Provider<KeyValueStore>((ref) {
  throw UnimplementedError(
    'KeyValueStore must be overridden during bootstrap.');
});

/// Auth repository (persisted session + unread counters).
///
/// Constructed only during bootstrap and injected via override.
final authRepositoryProvider = Provider<AuthService>((ref) {
  throw UnimplementedError(
    'AuthService must be overridden during bootstrap.');
});

/// The sole application-level API client. Feature code must obtain it through
/// this provider (or a repository that depends on it) rather than constructing
/// a client from a widget.
final lemmyApiClientProvider = Provider<LemmyApiService>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final client = LemmyApiService(baseUrl: auth.activeInstanceUrl)
    ..setAuthToken(auth.jwt);
  void updateClient() {
    client
      ..setBaseUrl(auth.activeInstanceUrl)
      ..setAuthToken(auth.jwt);
  }

  auth.addListener(updateClient);
  ref.onDispose(() {
    auth.removeListener(updateClient);
    client.dispose();
  });
  return client;
});

final sharedPrefsStoreProvider = FutureProvider<SharedPrefsStore>(
  (ref) => SharedPrefsStore.create());
