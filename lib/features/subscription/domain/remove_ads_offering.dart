import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bluerum/features/subscription/domain/revenuecat_config.dart';

/// Which remove-ads plan the user selected on the paywall.
enum RemoveAdsPlan { yearly, monthly, lifetime }

extension RemoveAdsPlanX on RemoveAdsPlan {
  String get title => switch (this) {
        RemoveAdsPlan.yearly => 'Yearly',
        RemoveAdsPlan.monthly => 'Monthly',
        RemoveAdsPlan.lifetime => 'Lifetime',
      };

  /// Suffix after price on the paywall (e.g. `/year`). Empty for lifetime.
  String get periodLabel => switch (this) {
        RemoveAdsPlan.yearly => '/year',
        RemoveAdsPlan.monthly => '/month',
        RemoveAdsPlan.lifetime => ' once',
      };

  /// Whether this plan is a recurring store subscription.
  bool get isSubscription =>
      this == RemoveAdsPlan.yearly || this == RemoveAdsPlan.monthly;
}

/// Maps a store / RevenueCat product id to [RemoveAdsPlan].
///
/// Accepts:
/// - Full Play ids: `remove_ads:monthly`, `remove_ads:yearly`
/// - Bare base plan ids: `monthly`, `yearly` (from [EntitlementInfo.productPlanIdentifier])
/// - Lifetime: `remove_ads_lifetime`
RemoveAdsPlan? removeAdsPlanFromProductId(String? productId) {
  if (productId == null || productId.isEmpty) return null;
  if (RevenueCatConfig.matchesLifetimeProductId(productId)) {
    return RemoveAdsPlan.lifetime;
  }
  if (RevenueCatConfig.matchesYearlyProductId(productId)) {
    return RemoveAdsPlan.yearly;
  }
  if (RevenueCatConfig.matchesMonthlyProductId(productId)) {
    return RemoveAdsPlan.monthly;
  }
  return null;
}

/// Resolves plan from a RevenueCat entitlement (Play-safe).
///
/// On Google Play, [productIdentifier] is often just the subscription id
/// (`remove_ads`) while the base plan is in [productPlanIdentifier]
/// (`monthly` / `yearly`). Composes `productId:basePlanId` when needed.
RemoveAdsPlan? removeAdsPlanFromEntitlement({
  required String productIdentifier,
  String? productPlanIdentifier,
}) {
  if (RevenueCatConfig.matchesLifetimeProductId(productIdentifier)) {
    return RemoveAdsPlan.lifetime;
  }

  final planId = productPlanIdentifier?.trim();
  if (planId != null && planId.isNotEmpty) {
    // Bare base plan id from Play.
    final fromPlan = removeAdsPlanFromProductId(planId);
    if (fromPlan != null) return fromPlan;

    // Compose productId:basePlanId when RC only returns the parent product id.
    final parent = productIdentifier.trim();
    if (parent.isNotEmpty && !parent.contains(':')) {
      final composed = removeAdsPlanFromProductId('$parent:$planId');
      if (composed != null) return composed;
    }
  }

  return removeAdsPlanFromProductId(productIdentifier);
}

/// Monthly + annual + lifetime packages for the remove-ads entitlement.
class RemoveAdsOffering {
  const RemoveAdsOffering({
    this.monthly,
    this.yearly,
    this.lifetime,
  });

  final Package? monthly;
  final Package? yearly;
  final Package? lifetime;

  bool get hasAny => monthly != null || yearly != null || lifetime != null;

  /// Preferred default: yearly (best value), else monthly, else lifetime.
  /// When nothing is loaded yet, still prefer yearly so the paywall highlights it.
  RemoveAdsPlan get defaultPlan {
    if (yearly != null) return RemoveAdsPlan.yearly;
    if (monthly != null) return RemoveAdsPlan.monthly;
    if (lifetime != null) return RemoveAdsPlan.lifetime;
    return RemoveAdsPlan.yearly;
  }

  Package? packageFor(RemoveAdsPlan plan) {
    return switch (plan) {
      RemoveAdsPlan.yearly => yearly,
      RemoveAdsPlan.monthly => monthly,
      RemoveAdsPlan.lifetime => lifetime,
    };
  }

  String priceLabel(RemoveAdsPlan plan) {
    final package = packageFor(plan);
    if (package != null) return package.storeProduct.priceString;
    return switch (plan) {
      RemoveAdsPlan.yearly => RevenueCatConfig.fallbackYearlyPrice,
      RemoveAdsPlan.monthly => RevenueCatConfig.fallbackMonthlyPrice,
      RemoveAdsPlan.lifetime => RevenueCatConfig.fallbackLifetimePrice,
    };
  }

  String periodLabel(RemoveAdsPlan plan) => plan.periodLabel;
}
