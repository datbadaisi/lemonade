import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/subscription/data/subscription_service.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_snapshot.dart';

final lifetimePurchaseServiceProvider = Provider<LifetimePurchaseService>((
  ref,
) {
  final service = LifetimePurchaseService();
  ref.onDispose(service.dispose);
  return service;
});

/// Store-backed remove-ads state. The local ads flag remains only as a cache
/// before the first store update arrives.
final class RemoveAdsEntitlement {
  const RemoveAdsEntitlement({
    required this.entitled,
    this.productId,
    this.storeSynced = false,
  });

  static const initial = RemoveAdsEntitlement(entitled: false);

  final bool entitled;
  final String? productId;
  final bool storeSynced;

  bool get lifetimeOwned => entitled;
}

class RemoveAdsEntitlementNotifier extends Notifier<RemoveAdsEntitlement> {
  @override
  RemoveAdsEntitlement build() => RemoveAdsEntitlement.initial;

  void applySnapshot(RemoveAdsSnapshot snapshot) {
    state = RemoveAdsEntitlement(
      entitled: snapshot.entitled,
      productId: snapshot.entitled ? snapshot.productId : null,
      storeSynced: true,
    );
  }

  Future<void> applyPurchaseSnapshot(RemoveAdsSnapshot snapshot) async {
    applySnapshot(snapshot);
    await ref
        .read(adsSettingsProvider.notifier)
        .setAdsRemoved(snapshot.entitled);
  }
}

final removeAdsEntitlementProvider =
    NotifierProvider<RemoveAdsEntitlementNotifier, RemoveAdsEntitlement>(
      RemoveAdsEntitlementNotifier.new,
    );

/// Initializes the store listener and mirrors lifetime purchases into ads.
final lifetimePurchaseBootstrapProvider = FutureProvider<void>((ref) async {
  final service = ref.read(lifetimePurchaseServiceProvider);
  await service.initialize();

  final eventSubscription = service.events.listen((event) {
    final snapshot = event.snapshot;
    if (snapshot == null) return;
    if (event.type != LifetimePurchaseEventType.restoreCompleted &&
        !snapshot.entitled) {
      return;
    }

    // ignore: discarded_futures
    ref
        .read(removeAdsEntitlementProvider.notifier)
        .applyPurchaseSnapshot(snapshot);
  });
  ref.onDispose(eventSubscription.cancel);

  // Restore silently at startup so an existing lifetime purchase survives
  // reinstall/device changes when the same store account is active.
  unawaited(service.restorePurchases());
});

final removeAdsOfferingProvider = FutureProvider<RemoveAdsOffering>((
  ref,
) async {
  await ref.watch(lifetimePurchaseBootstrapProvider.future);
  return ref.read(lifetimePurchaseServiceProvider).loadOffering();
});
