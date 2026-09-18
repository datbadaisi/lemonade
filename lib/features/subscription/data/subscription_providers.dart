import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/subscription/data/subscription_service.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_snapshot.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Atomic entitlement state for remove-ads (plan + entitled + store product id).
///
/// Always clears [plan] / [subscriptionProductId] when [entitled] is false so
/// cancel/expire cannot leave a stale "Current" badge.
final class RemoveAdsEntitlement {
  const RemoveAdsEntitlement({
    required this.entitled,
    this.plan,
    this.subscriptionProductId,
    this.storeSynced = false,
  });

  static const initial = RemoveAdsEntitlement(entitled: false);

  final bool entitled;
  final RemoveAdsPlan? plan;
  final String? subscriptionProductId;

  /// True after at least one store sync (or verified purchase/restore).
  final bool storeSynced;

  RemoveAdsEntitlement copyWith({
    bool? entitled,
    RemoveAdsPlan? plan,
    String? subscriptionProductId,
    bool? storeSynced,
    bool clearPlan = false,
    bool clearProductId = false,
  }) {
    return RemoveAdsEntitlement(
      entitled: entitled ?? this.entitled,
      plan: clearPlan ? null : (plan ?? this.plan),
      subscriptionProductId:
          clearProductId ? null : (subscriptionProductId ?? this.subscriptionProductId),
      storeSynced: storeSynced ?? this.storeSynced,
    );
  }
}

class RemoveAdsEntitlementNotifier extends Notifier<RemoveAdsEntitlement> {
  @override
  RemoveAdsEntitlement build() => RemoveAdsEntitlement.initial;

  /// Applies a store snapshot atomically. Clears plan when not entitled.
  void applySnapshot(RemoveAdsSnapshot snapshot) {
    state = RemoveAdsEntitlement(
      entitled: snapshot.entitled,
      plan: snapshot.entitled ? snapshot.plan : null,
      subscriptionProductId:
          snapshot.entitled ? snapshot.subscriptionProductId : null,
      storeSynced: true,
    );
  }

  /// After verified purchase/restore: mirror entitlement and persist ads flag.
  Future<void> applyVerifiedSnapshot(
    RemoveAdsSnapshot snapshot, {
    RemoveAdsPlan? fallbackPlan,
  }) async {
    final plan = snapshot.entitled
        ? (snapshot.plan ?? fallbackPlan)
        : null;
    state = RemoveAdsEntitlement(
      entitled: snapshot.entitled,
      plan: plan,
      subscriptionProductId:
          snapshot.entitled ? snapshot.subscriptionProductId : null,
      storeSynced: true,
    );
    await ref.read(adsSettingsProvider.notifier).setAdsRemoved(snapshot.entitled);
  }
}

final removeAdsEntitlementProvider =
    NotifierProvider<RemoveAdsEntitlementNotifier, RemoveAdsEntitlement>(
  RemoveAdsEntitlementNotifier.new,
);

/// Initializes RevenueCat and mirrors entitlement into [removeAdsEntitlementProvider]
/// + [adsSettingsProvider]. Call once from bootstrap.
final subscriptionBootstrapProvider = FutureProvider<void>((ref) async {
  final service = ref.read(subscriptionServiceProvider);
  await service.configure();
  if (!service.isConfigured) return;

  Future<void> syncFromInfo(CustomerInfo info) async {
    final snapshot = RemoveAdsSnapshot.fromCustomerInfo(info);
    ref.read(removeAdsEntitlementProvider.notifier).applySnapshot(snapshot);
    await ref.read(adsSettingsProvider.notifier).setAdsRemoved(snapshot.entitled);
  }

  // Single CustomerInfo read for initial sync.
  final snapshot = await service.loadSnapshot();
  ref.read(removeAdsEntitlementProvider.notifier).applySnapshot(snapshot);
  await ref.read(adsSettingsProvider.notifier).setAdsRemoved(snapshot.entitled);

  void listener(CustomerInfo info) {
    // ignore: discarded_futures
    syncFromInfo(info);
  }

  service.addCustomerInfoListener(listener);
  ref.onDispose(() => service.removeCustomerInfoListener(listener));
});

/// Monthly + annual + lifetime packages for remove-ads (yearly preferred as default).
final removeAdsOfferingProvider = FutureProvider<RemoveAdsOffering>((ref) async {
  await ref.watch(subscriptionBootstrapProvider.future);
  final service = ref.read(subscriptionServiceProvider);
  if (!service.isConfigured) return const RemoveAdsOffering();
  return service.loadRemoveAdsOffering();
});
