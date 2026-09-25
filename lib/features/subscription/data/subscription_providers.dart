import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/subscription/data/subscription_service.dart';
import 'package:bluerum/features/subscription/domain/lifetime_purchase_offering.dart';
import 'package:bluerum/features/subscription/domain/lifetime_purchase_snapshot.dart';

final lifetimePurchaseServiceProvider = Provider<LifetimePurchaseService>((
  ref,
) {
  final service = LifetimePurchaseService();
  ref.onDispose(service.dispose);
  return service;
});

/// Store-backed lifetime purchase state.
final class LifetimeEntitlement {
  const LifetimeEntitlement({
    required this.entitled,
    this.productId,
    this.storeSynced = false,
  });

  static const initial = LifetimeEntitlement(entitled: false);

  final bool entitled;
  final String? productId;
  final bool storeSynced;

  bool get lifetimeOwned => entitled;
}

class LifetimeEntitlementNotifier extends Notifier<LifetimeEntitlement> {
  @override
  LifetimeEntitlement build() => LifetimeEntitlement.initial;

  void applySnapshot(LifetimePurchaseSnapshot snapshot) {
    state = LifetimeEntitlement(
      entitled: snapshot.entitled,
      productId: snapshot.entitled ? snapshot.productId : null,
      storeSynced: true,
    );
  }

  void applyPurchaseSnapshot(LifetimePurchaseSnapshot snapshot) {
    applySnapshot(snapshot);
  }
}

final lifetimeEntitlementProvider =
    NotifierProvider<LifetimeEntitlementNotifier, LifetimeEntitlement>(
      LifetimeEntitlementNotifier.new,
    );

/// Initializes the store listener and restores the lifetime entitlement.
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
        .read(lifetimeEntitlementProvider.notifier)
        .applyPurchaseSnapshot(snapshot);
  });
  ref.onDispose(eventSubscription.cancel);

  // Restore silently at startup so an existing lifetime purchase survives
  // reinstall/device changes when the same store account is active.
  unawaited(service.restorePurchases());
});

final lifetimePurchaseOfferingProvider =
    FutureProvider<LifetimePurchaseOffering>((ref) async {
      await ref.watch(lifetimePurchaseBootstrapProvider.future);
      return ref.read(lifetimePurchaseServiceProvider).loadOffering();
    });
