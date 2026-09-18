/// Frequency + AdMob unit configuration for in-feed ads.
///
/// Replace [androidAppId] / [iosAppId] and the ad unit IDs with your real
/// AdMob values before shipping a production build. Test IDs below are
/// Google's official samples and always fill in debug.
abstract final class AdsConfig {
  /// Home feed: one native ad after every N posts.
  /// Fewer slots = fewer platform-view ads. 6 was dense enough to OOM when
  /// several medium templates stayed alive under a long feed.
  static const int homePostsPerAd = 8;

  /// Comment list: one native ad after every N **root** (parent) comments.
  static const int commentRootsPerAd = 9;

  /// AdMob App IDs. Defaults to Google test app IDs when not passed via environment.
  static const String androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );
  static const String iosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511',
  );

  /// Native advanced units. Defaults to Google test unit IDs when not passed via environment.
  static const String androidNativeAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_NATIVE_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2247696110',
  );
  static const String iosNativeAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_NATIVE_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/3986624511',
  );
}
