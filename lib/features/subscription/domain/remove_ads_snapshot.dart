import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/revenuecat_config.dart';

/// Canonical store-backed remove-ads entitlement snapshot.
///
/// Single source of truth derived from one [CustomerInfo] read. When
/// [entitled] is false, [plan] and [subscriptionProductId] are always null.
final class RemoveAdsSnapshot {
  const RemoveAdsSnapshot({
    required this.entitled,
    this.plan,
    this.subscriptionProductId,
    this.managementUrl,
  });

  static const empty = RemoveAdsSnapshot(entitled: false);

  /// Whether the remove-ads entitlement is active on the store account.
  final bool entitled;

  /// Active plan when entitled and mappable; null if unmapped or not entitled.
  final RemoveAdsPlan? plan;

  /// Store product id for Play product-change (`productId:basePlanId` when needed).
  final String? subscriptionProductId;

  /// RevenueCat management URL when present.
  final String? managementUrl;

  /// Builds a snapshot from [CustomerInfo]. Clears plan/product when not entitled.
  factory RemoveAdsSnapshot.fromCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.all[RevenueCatConfig.entitlementRemoveAds];
    final active = entitlement != null && entitlement.isActive;
    final managementUrl =
        (info.managementURL != null && info.managementURL!.isNotEmpty)
            ? info.managementURL
            : null;

    if (!active) {
      return RemoveAdsSnapshot(
        entitled: false,
        managementUrl: managementUrl,
      );
    }

    final plan = removeAdsPlanFromEntitlement(
      productIdentifier: entitlement.productIdentifier,
      productPlanIdentifier: entitlement.productPlanIdentifier,
    );
    final productId = _subscriptionProductIdFromEntitlement(entitlement);

    return RemoveAdsSnapshot(
      entitled: true,
      plan: plan,
      subscriptionProductId: productId,
      managementUrl: managementUrl,
    );
  }
}

/// Play product-change id: `productId:basePlanId` when base plan is separate.
String? _subscriptionProductIdFromEntitlement(EntitlementInfo entitlement) {
  final product = entitlement.productIdentifier.trim();
  if (product.isEmpty) return null;
  final plan = entitlement.productPlanIdentifier?.trim();
  if (plan != null && plan.isNotEmpty && !product.contains(':')) {
    return '$product:$plan';
  }
  return product;
}
