import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/constants/storage_keys.dart';
import 'package:bluerum/core/storage/key_value_store.dart';
import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements KeyValueStore {
  final Map<String, String> data = {};

  @override
  String? getString(String key) => data[key];

  @override
  Future<bool> remove(String key) async {
    data.remove(key);
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    data[key] = value;
    return true;
  }
}

ProviderContainer _container(_MemoryStore store) {
  return ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store),
    ],
  );
}

void main() {
  test('showAds true by default', () {
    final store = _MemoryStore();
    final container = _container(store);
    addTearDown(container.dispose);
    expect(container.read(adsSettingsProvider).showAds, isTrue);
    expect(container.read(adsSettingsProvider).adsRemoved, isFalse);
    expect(container.read(adsSettingsProvider).adsEnabled, isTrue);
  });

  test('setAdsRemoved hides ads and persists', () async {
    final store = _MemoryStore();
    final container = _container(store);
    addTearDown(container.dispose);

    await container.read(adsSettingsProvider.notifier).setAdsRemoved(true);
    expect(container.read(adsSettingsProvider).showAds, isFalse);
    expect(store.getString(StorageKeys.adsRemoved), '1');

    // Fresh container reads same store.
    final restored = _container(store);
    addTearDown(restored.dispose);
    expect(restored.read(adsSettingsProvider).adsRemoved, isTrue);
    expect(restored.read(adsSettingsProvider).showAds, isFalse);
  });

  test('master switch disables without clearing purchase', () async {
    final store = _MemoryStore();
    final container = _container(store);
    addTearDown(container.dispose);
    final ads = container.read(adsSettingsProvider.notifier);

    await ads.setAdsRemoved(true);
    await ads.setAdsEnabled(false);
    expect(container.read(adsSettingsProvider).showAds, isFalse);

    await ads.setAdsRemoved(false);
    expect(container.read(adsSettingsProvider).adsRemoved, isFalse);
    expect(container.read(adsSettingsProvider).showAds, isFalse);

    await ads.setAdsEnabled(true);
    expect(container.read(adsSettingsProvider).showAds, isTrue);
  });
}
