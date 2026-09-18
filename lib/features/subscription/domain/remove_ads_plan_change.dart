import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/revenuecat_config.dart';

/// Relative rank for upgrade / downgrade UI and Play replacement mode.
///
/// Higher = better value / longer commitment for this remove-ads catalog.
extension RemoveAdsPlanRanking on RemoveAdsPlan {
  int get rank => switch (this) {
        RemoveAdsPlan.monthly => 1,
        RemoveAdsPlan.yearly => 2,
        RemoveAdsPlan.lifetime => 3,
      };
}

/// What the primary paywall button should do for [selected] vs [activePlan].
enum PlanPurchaseIntent {
  /// New customer buying a subscription plan.
  subscribe,

  /// New customer or upgrade path buying lifetime.
  unlockLifetime,

  /// Selected plan is already active — button disabled.
  current,

  /// Moving to a higher-ranked plan (e.g. monthly → yearly).
  upgrade,

  /// Moving to a lower or lateral subscription plan (e.g. yearly → monthly).
  switchPlan,
}

/// Resolves the primary CTA intent for the remove-ads paywall.
PlanPurchaseIntent planPurchaseIntent({
  required bool entitled,
  required RemoveAdsPlan? activePlan,
  required RemoveAdsPlan selected,
}) {
  if (!entitled) {
    return selected == RemoveAdsPlan.lifetime
        ? PlanPurchaseIntent.unlockLifetime
        : PlanPurchaseIntent.subscribe;
  }
  // Entitled (ads removed) — even if plan id has not resolved yet.
  if (activePlan == selected) return PlanPurchaseIntent.current;
  if (selected == RemoveAdsPlan.lifetime) {
    return PlanPurchaseIntent.unlockLifetime;
  }
  if (activePlan == null) {
    // Subscription active but base plan unknown: still offer change CTAs.
    return PlanPurchaseIntent.switchPlan;
  }
  // Lifetime holders should not see change-plan CTAs (UI hides picker).
  if (!activePlan.isSubscription) return PlanPurchaseIntent.current;
  if (selected.rank > activePlan.rank) return PlanPurchaseIntent.upgrade;
  return PlanPurchaseIntent.switchPlan;
}

/// Whether to warn / confirm canceling a recurring sub before lifetime.
///
/// True when ads are already removed via a non-lifetime plan (or plan unknown).
bool shouldWarnLifetimeWhileSubscribed({
  required bool entitled,
  required RemoveAdsPlan? activePlan,
}) {
  if (!entitled) return false;
  if (activePlan == RemoveAdsPlan.lifetime) return false;
  return true;
}

/// Whether the user can still change plans in-app (subscription, not lifetime).
bool canChangeRemoveAdsPlan(RemoveAdsPlan? activePlan) {
  return activePlan == null || activePlan.isSubscription;
}

/// Default selection when the paywall opens or entitlement updates.
///
/// - Not entitled: highlight best-value default (usually yearly).
/// - Entitled: select the **current** active plan so the check matches
///   "Current" and the CTA shows "Current plan" until the user picks another.
RemoveAdsPlan defaultSelectedPlan({
  required bool entitled,
  required RemoveAdsPlan? activePlan,
  required RemoveAdsOffering offering,
}) {
  // Not entitled → best-value default. Never use this fallback while entitled
  // with a known plan (would flash yearly during entitlement reloads).
  if (!entitled) {
    return offering.defaultPlan;
  }
  if (activePlan != null &&
      (offering.packageFor(activePlan) != null || !offering.hasAny)) {
    return activePlan;
  }
  // Entitled but plan not resolved yet — keep yearly only as last resort
  // when neither lastKnown nor store has answered (cold start).
  return offering.defaultPlan;
}

/// Primary button label (price already localized from the store when available).
String planPrimaryCtaLabel({
  required PlanPurchaseIntent intent,
  required RemoveAdsPlan selected,
  required String priceLabel,
  required String periodLabel,
}) {
  return switch (intent) {
    // Status, not a purchase CTA — solid black + normal white label.
    PlanPurchaseIntent.current => 'You\'re on this plan',
    PlanPurchaseIntent.subscribe => selected == RemoveAdsPlan.lifetime
        ? 'Unlock forever · $priceLabel'
        : 'Support $priceLabel$periodLabel',
    PlanPurchaseIntent.unlockLifetime => 'Unlock forever · $priceLabel',
    PlanPurchaseIntent.upgrade =>
      'Upgrade to ${selected.title} · $priceLabel',
    PlanPurchaseIntent.switchPlan =>
      'Switch to ${selected.title} · $priceLabel',
  };
}

/// Paywall subtitle for a plan row (no hardcoded free-trial marketing).
///
/// Free-trial copy is only shown when the store product reports a $0 intro.
String planRowSubtitle({
  required RemoveAdsPlan plan,
  required bool isCurrent,
  Package? package,
}) {
  if (isCurrent) {
    return switch (plan) {
      RemoveAdsPlan.yearly => 'Current · billed once a year',
      RemoveAdsPlan.monthly => 'Current · billed monthly',
      RemoveAdsPlan.lifetime => 'Active · one-time purchase',
    };
  }
  if (plan == RemoveAdsPlan.lifetime) {
    return 'Pay once · forever ad-free';
  }
  final trial = freeTrialSubtitle(package?.storeProduct.introductoryPrice);
  if (trial != null) {
    return switch (plan) {
      RemoveAdsPlan.yearly => '$trial · then billed yearly',
      RemoveAdsPlan.monthly => '$trial · then billed monthly',
      RemoveAdsPlan.lifetime => trial,
    };
  }
  return switch (plan) {
    RemoveAdsPlan.yearly => 'Best value · billed once a year',
    RemoveAdsPlan.monthly => 'Billed monthly',
    RemoveAdsPlan.lifetime => 'Pay once · forever ad-free',
  };
}

/// Human-readable free-trial fragment when intro price is free; otherwise null.
String? freeTrialSubtitle(IntroductoryPrice? intro) {
  if (intro == null || intro.price > 0) return null;
  final n = intro.periodNumberOfUnits;
  if (n <= 0) return null;
  final unit = switch (intro.periodUnit) {
    PeriodUnit.day => n == 1 ? 'day' : 'days',
    PeriodUnit.week => n == 1 ? 'week' : 'weeks',
    PeriodUnit.month => n == 1 ? 'month' : 'months',
    PeriodUnit.year => n == 1 ? 'year' : 'years',
    PeriodUnit.unknown => null,
  };
  if (unit == null) return null;
  return n == 1 ? 'First $unit free' : 'First $n $unit free';
}

/// Whether a Play Store purchase must pass [StoreProductChangeInfo].
///
/// Driven by **store product ids**, not only mapped [RemoveAdsPlan] enums, so
/// base-plan switches still replace correctly when plan mapping is briefly null.
///
/// iOS ignores product-change info (subscription group handles upgrades).
/// Lifetime is a separate one-time product — never a Play replacement.
bool requiresGoogleProductChange({
  required String? activeStoreProductId,
  required String targetStoreProductId,
  RemoveAdsPlan? activePlan,
  RemoveAdsPlan? targetPlan,
}) {
  final oldId = activeStoreProductId?.trim();
  final newId = targetStoreProductId.trim();
  if (oldId == null || oldId.isEmpty || newId.isEmpty) return false;
  if (oldId == newId) return false;

  // Lifetime is never a Play subscription replacement (either side).
  if (targetPlan == RemoveAdsPlan.lifetime ||
      RevenueCatConfig.matchesLifetimeProductId(newId)) {
    return false;
  }
  if (activePlan == RemoveAdsPlan.lifetime ||
      RevenueCatConfig.matchesLifetimeProductId(oldId)) {
    return false;
  }

  // Target must be a subscription product for product-change.
  if (targetPlan != null && !targetPlan.isSubscription) return false;

  return true;
}

/// Play replacement mode for subscription → subscription changes.
///
/// For **same subscription, different base plans** (`remove_ads:monthly` ↔
/// `remove_ads:yearly`), Google only accepts a small set of modes:
/// [withoutProration], [chargeFullPrice], and sometimes [deferred].
///
/// Modes that **fail** with DEVELOPER_ERROR on this catalog:
/// - [deferred] — "replacement mode is not supported"
/// - [withTimeProration] / [chargeProratedPrice] — not valid for base-plan
///   switches on the same product.
///
/// We use [withoutProration] both ways: change applies immediately; the new
/// price is charged on the next billing cycle.
StoreReplacementMode? googleReplacementMode({
  required String? activeStoreProductId,
  required String targetStoreProductId,
  RemoveAdsPlan? activePlan,
  RemoveAdsPlan? targetPlan,
}) {
  if (!requiresGoogleProductChange(
    activeStoreProductId: activeStoreProductId,
    targetStoreProductId: targetStoreProductId,
    activePlan: activePlan,
    targetPlan: targetPlan,
  )) {
    return null;
  }
  return StoreReplacementMode.withoutProration;
}
