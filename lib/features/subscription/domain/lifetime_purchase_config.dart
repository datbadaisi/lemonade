/// Store configuration for the one-time remove-ads product.
abstract final class LifetimePurchaseConfig {
  /// Keep this ID stable so lifetime purchases made by older builds can be
  /// restored from the same Google Play / App Store account.
  static const String productId = 'remove_ads_lifetime';
}
