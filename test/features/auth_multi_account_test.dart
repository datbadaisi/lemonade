import 'package:bluerum/core/constants/storage_keys.dart';
import 'package:bluerum/core/storage/key_value_store.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/auth/domain/stored_account.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [KeyValueStore] for multi-account unit tests.
final class MemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) => _data[key];

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  void seed(Map<String, String> values) => _data.addAll(values);
}

void main() {
  group('StoredAccount', () {
    test('makeId normalises username and host', () {
      expect(
        StoredAccount.makeId(
          username: 'Alice',
          instanceUrl: 'https://Lemmy.World/',
        ),
        'alice@lemmy.world',
      );
    });

    test('round-trips through JSON', () {
      const original = StoredAccount(
        id: 'bob@lemmy.zip',
        jwt: 'token',
        instanceUrl: 'https://lemmy.zip',
        username: 'bob',
        personId: 42,
        avatarUrl: 'https://example.com/a.png',
      );
      final restored = StoredAccount.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.jwt, original.jwt);
      expect(restored.username, original.username);
      expect(restored.personId, 42);
      expect(restored.avatarUrl, original.avatarUrl);
      expect(restored.instanceHost, 'lemmy.zip');
    });
  });

  group('AuthService multi-account', () {
    test('migrates legacy single session into accounts list', () async {
      final store = MemoryStore()
        ..seed({
          StorageKeys.jwt: 'legacy-jwt',
          StorageKeys.username: 'legacy_user',
          StorageKeys.instance: 'https://lemmy.zip',
          StorageKeys.personId: '7',
        });
      final auth = AuthService(store: store);
      await auth.init();

      expect(auth.isLoggedIn, isTrue);
      expect(auth.username, 'legacy_user');
      expect(auth.accounts, hasLength(1));
      expect(auth.accounts.first.id, 'legacy_user@lemmy.zip');
      expect(auth.activeAccountId, 'legacy_user@lemmy.zip');
    });

    test('switchAccount changes active session fields', () async {
      final store = MemoryStore();
      final auth = AuthService(store: store);
      await auth.init();

      // Simulate two saved sessions via setJwt + manual second entry is hard
      // without API; seed store and re-init instead.
      final a = StoredAccount(
        id: 'a@lemmy.zip',
        jwt: 'jwt-a',
        instanceUrl: 'https://lemmy.zip',
        username: 'a',
        personId: 1,
      );
      final b = StoredAccount(
        id: 'b@lemmy.world',
        jwt: 'jwt-b',
        instanceUrl: 'https://lemmy.world',
        username: 'b',
        personId: 2,
      );
      await store.setString(
        StorageKeys.accounts,
        // ignore: prefer_single_quotes — keep JSON double quotes
        '[{"id":"${a.id}","jwt":"${a.jwt}","instanceUrl":"${a.instanceUrl}","username":"${a.username}","personId":1},'
        '{"id":"${b.id}","jwt":"${b.jwt}","instanceUrl":"${b.instanceUrl}","username":"${b.username}","personId":2}]',
      );
      await store.setString(StorageKeys.activeAccountId, a.id);

      await auth.init();
      expect(auth.username, 'a');
      expect(auth.jwt, 'jwt-a');
      expect(auth.accounts, hasLength(2));

      await auth.switchAccount(b.id);
      expect(auth.username, 'b');
      expect(auth.jwt, 'jwt-b');
      expect(auth.activeInstanceUrl, 'https://lemmy.world');
      expect(auth.activeAccountId, b.id);
      expect(auth.accounts, hasLength(2));
    });

    test('logout removes only active account and switches to remaining',
        () async {
      final store = MemoryStore();
      final auth = AuthService(store: store);
      await store.setString(
        StorageKeys.accounts,
        '[{"id":"a@lemmy.zip","jwt":"jwt-a","instanceUrl":"https://lemmy.zip","username":"a","personId":1},'
        '{"id":"b@lemmy.world","jwt":"jwt-b","instanceUrl":"https://lemmy.world","username":"b","personId":2}]',
      );
      await store.setString(StorageKeys.activeAccountId, 'a@lemmy.zip');
      await auth.init();

      await auth.logout();
      expect(auth.isLoggedIn, isTrue);
      expect(auth.username, 'b');
      expect(auth.accounts, hasLength(1));
      expect(auth.accounts.first.id, 'b@lemmy.world');
    });

    test('logout of last account clears session', () async {
      final store = MemoryStore();
      final auth = AuthService(store: store);
      await store.setString(
        StorageKeys.accounts,
        '[{"id":"a@lemmy.zip","jwt":"jwt-a","instanceUrl":"https://lemmy.zip","username":"a"}]',
      );
      await store.setString(StorageKeys.activeAccountId, 'a@lemmy.zip');
      await auth.init();

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.accounts, isEmpty);
      expect(auth.jwt, isNull);
    });
  });
}
