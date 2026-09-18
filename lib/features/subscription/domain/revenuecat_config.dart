/// RevenueCat product / entitlement identifiers and public API keys.
///
/// **Catalog (Google Play: 1 subscription + 2 base plans):**
/// - Entitlement: [entitlementRemoveAds]
/// - Subscription: [subscriptionProductId]
///   - Base plan [basePlanIdMonthly] → [productIdMonthly] (~$1.99/mo)
///   - Base plan [basePlanIdYearly] → [productIdYearly] (~$9.99/yr)
/// - One-time: [productIdLifetime] (~$19.99)
/// - Attach all to the entitlement; Offering: monthly + annual + lifetime.
///
/// Public SDK keys (safe in client) from RevenueCat → Project → API keys.
abstract final class RevenueCatConfig {
  /// Entitlement that unlocks ad-free.
  static const String entitlementRemoveAds = 'remove_ads';

  /// Google Play subscription product id (parent of both base plans).
  static const String subscriptionProductId = 'remove_ads';

  /// Base plan id for monthly billing (Play Console).
  static const String basePlanIdMonthly = 'monthly';

  /// Base plan id for yearly billing (Play Console).
  static const String basePlanIdYearly = 'yearly';

  /// Full store / RevenueCat product identifier for monthly.
  /// Play format: `productId:basePlanId` → `remove_ads:monthly`.
  static const String productIdMonthly =
      '$subscriptionProductId:$basePlanIdMonthly';

  /// Full store / RevenueCat product identifier for yearly.
  /// Play format: `productId:basePlanId` → `remove_ads:yearly`.
  static const String productIdYearly =
      '$subscriptionProductId:$basePlanIdYearly';

  /// One-time lifetime unlock (not a subscription base plan).
  /// Play: one-time product. App Store: non-consumable.
  static const String productIdLifetime = 'remove_ads_lifetime';

  /// Fallback labels when store prices are not loaded yet.
  static const String fallbackMonthlyPrice = '\$1.99';
  static const String fallbackYearlyPrice = '\$9.99';
  static const String fallbackLifetimePrice = '\$19.99';

  /// Whether [storeProductId] is the monthly base plan.
  ///
  /// Matches full id (`remove_ads:monthly`), suffix `:monthly`, or bare
  /// base plan id (`monthly`) from [EntitlementInfo.productPlanIdentifier].
  static bool matchesMonthlyProductId(String? storeProductId) {
    if (storeProductId == null || storeProductId.isEmpty) return false;
    final id = storeProductId.toLowerCase();
    return id == productIdMonthly.toLowerCase() ||
        id == basePlanIdMonthly ||
        id.endsWith(':$basePlanIdMonthly');
  }

  /// Whether [storeProductId] is the yearly base plan.
  static bool matchesYearlyProductId(String? storeProductId) {
    if (storeProductId == null || storeProductId.isEmpty) return false;
    final id = storeProductId.toLowerCase();
    return id == productIdYearly.toLowerCase() ||
        id == basePlanIdYearly ||
        id.endsWith(':$basePlanIdYearly');
  }

  /// Whether [storeProductId] is the lifetime one-time product.
  static bool matchesLifetimeProductId(String? storeProductId) {
    if (storeProductId == null || storeProductId.isEmpty) return false;
    return storeProductId.toLowerCase() == productIdLifetime.toLowerCase();
  }

  /// Google Play public API key (`goog_...`).
  ///
  /// Override at build time:
  /// `--dart-define=REVENUECAT_ANDROID_API_KEY=goog_xxx`
  /// or `--dart-define-from-file=config.json`
  static const String androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: '',
  );

  /// App Store public API key (`appl_...`).
  ///
  /// Override at build time:
  /// `--dart-define=REVENUECAT_IOS_API_KEY=appl_xxx`
  static const String iosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: '',
  );

  /// True when at least the current platform key is non-empty.
  static bool get hasConfiguredKeys {
    return androidApiKey.isNotEmpty || iosApiKey.isNotEmpty;
  }
}
