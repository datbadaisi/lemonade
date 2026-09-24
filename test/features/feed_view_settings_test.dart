import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/constants/storage_keys.dart';
import 'package:bluerum/core/storage/key_value_store.dart';
import 'package:bluerum/features/feed/data/feed_view_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  String? getString(String key) => values[key];

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }
}

ProviderContainer _container(_MemoryStore store) => ProviderContainer(
  overrides: [keyValueStoreProvider.overrideWithValue(store)],
);

void main() {
  test('Large is the default, including for an unknown stored value', () {
    final store = _MemoryStore();
    final container = _container(store);
    addTearDown(container.dispose);
    expect(container.read(feedViewSettingsProvider), FeedViewMode.large);

    store.values[StorageKeys.feedViewMode] = 'old-mode';
    final restored = _container(store);
    addTearDown(restored.dispose);
    expect(restored.read(feedViewSettingsProvider), FeedViewMode.large);
  });

  test('selected mode is restored on the next app start', () async {
    final store = _MemoryStore();
    final container = _container(store);
    addTearDown(container.dispose);

    await container
        .read(feedViewSettingsProvider.notifier)
        .setMode(FeedViewMode.compact);
    expect(store.getString(StorageKeys.feedViewMode), 'compact');

    final restored = _container(store);
    addTearDown(restored.dispose);
    expect(restored.read(feedViewSettingsProvider), FeedViewMode.compact);
  });
}
