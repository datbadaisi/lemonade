/// Store configuration for the one-time lifetime product.
abstract final class LifetimePurchaseConfig {
  /// Keep this ID stable so lifetime purchases made by older builds can be
  /// restored from the same Google Play / App Store account.
  // Retain the original store ID so previous lifetime purchases can be restored.
  static const String productId = 'remove_ads_lifetime';
}
