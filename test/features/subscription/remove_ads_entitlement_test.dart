import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/constants/storage_keys.dart';
import 'package:bluerum/core/storage/key_value_store.dart';
import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/subscription/data/subscription_providers.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_snapshot.dart';
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

void main() {
  group('RemoveAdsEntitlementNotifier', () {
    late ProviderContainer container;
    late _MemoryStore store;

    setUp(() {
      store = _MemoryStore();
      container = ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('applySnapshot sets plan when entitled', () {
      container.read(removeAdsEntitlementProvider.notifier).applySnapshot(
            const RemoveAdsSnapshot(
              entitled: true,
              plan: RemoveAdsPlan.monthly,
              subscriptionProductId: 'remove_ads:monthly',
            ),
          );
      final state = container.read(removeAdsEntitlementProvider);
      expect(state.entitled, isTrue);
      expect(state.plan, RemoveAdsPlan.monthly);
      expect(state.subscriptionProductId, 'remove_ads:monthly');
      expect(state.storeSynced, isTrue);
    });

    test('applySnapshot clears plan and product when not entitled (cancel)', () {
      final notifier = container.read(removeAdsEntitlementProvider.notifier);
      notifier.applySnapshot(
        const RemoveAdsSnapshot(
          entitled: true,
          plan: RemoveAdsPlan.yearly,
          subscriptionProductId: 'remove_ads:yearly',
        ),
      );
      notifier.applySnapshot(const RemoveAdsSnapshot(entitled: false));

      final state = container.read(removeAdsEntitlementProvider);
      expect(state.entitled, isFalse);
      expect(state.plan, isNull);
      expect(state.subscriptionProductId, isNull);
      expect(state.storeSynced, isTrue);
    });

    test('applyVerifiedSnapshot mirrors adsRemoved only when entitled', () async {
      final notifier = container.read(removeAdsEntitlementProvider.notifier);

      await notifier.applyVerifiedSnapshot(
        const RemoveAdsSnapshot(
          entitled: true,
          plan: RemoveAdsPlan.monthly,
          subscriptionProductId: 'remove_ads:monthly',
        ),
      );
      expect(container.read(adsSettingsProvider).adsRemoved, isTrue);
      expect(store.getString(StorageKeys.adsRemoved), '1');

      await notifier.applyVerifiedSnapshot(
        const RemoveAdsSnapshot(entitled: false),
      );
      expect(container.read(adsSettingsProvider).adsRemoved, isFalse);
      expect(store.getString(StorageKeys.adsRemoved), isNull);
      expect(container.read(removeAdsEntitlementProvider).plan, isNull);
    });

    test('applyVerifiedSnapshot uses fallbackPlan when snapshot plan null', () async {
      await container.read(removeAdsEntitlementProvider.notifier).applyVerifiedSnapshot(
            const RemoveAdsSnapshot(
              entitled: true,
              plan: null,
              subscriptionProductId: 'remove_ads:monthly',
            ),
            fallbackPlan: RemoveAdsPlan.monthly,
          );
      expect(
        container.read(removeAdsEntitlementProvider).plan,
        RemoveAdsPlan.monthly,
      );
    });
  });
}
