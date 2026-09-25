import 'package:bluerum/features/subscription/data/subscription_providers.dart';
import 'package:bluerum/features/subscription/domain/lifetime_purchase_snapshot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifetime purchase grants sticker entitlement', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(lifetimeEntitlementProvider.notifier)
        .applyPurchaseSnapshot(
          const LifetimePurchaseSnapshot(
            entitled: true,
            productId: 'remove_ads_lifetime',
          ),
        );

    final entitlement = container.read(lifetimeEntitlementProvider);
    expect(entitlement.lifetimeOwned, isTrue);
    expect(entitlement.productId, 'remove_ads_lifetime');
    expect(entitlement.storeSynced, isTrue);
  });

  test('store revocation clears lifetime sticker entitlement', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(lifetimeEntitlementProvider.notifier);

    notifier.applySnapshot(
      const LifetimePurchaseSnapshot(
        entitled: true,
        productId: 'remove_ads_lifetime',
      ),
    );
    notifier.applySnapshot(const LifetimePurchaseSnapshot(entitled: false));

    final entitlement = container.read(lifetimeEntitlementProvider);
    expect(entitlement.lifetimeOwned, isFalse);
    expect(entitlement.productId, isNull);
    expect(entitlement.storeSynced, isTrue);
  });
}
