import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Shared future so callers can await readiness without double-init.
Future<void>? _mobileAdsInit;

/// Initializes the Mobile Ads SDK on supported platforms only.
///
/// Safe to call on web/desktop — returns immediately without throwing.
/// Idempotent: concurrent callers share one [Future].
Future<void> initializeMobileAds() {
  if (kIsWeb) return Future<void>.value();
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return Future<void>.value();
  }
  return _mobileAdsInit ??= _doInitializeMobileAds();
}

Future<void> _doInitializeMobileAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (e, st) {
    // Allow a later retry if the first cold-start attempt failed.
    _mobileAdsInit = null;
    if (kDebugMode) {
      debugPrint('MobileAds.initialize failed: $e\n$st');
    }
  }
}
