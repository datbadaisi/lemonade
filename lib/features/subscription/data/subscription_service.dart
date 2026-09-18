import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_plan_change.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_snapshot.dart';
import 'package:bluerum/features/subscription/domain/revenuecat_config.dart';

/// Result of a purchase or restore attempt.
enum SubscriptionActionResult {
  success,
  cancelled,
  noPurchases,
  notConfigured,
  error,
}

/// Outcome of purchase / restore with a single derived [snapshot] when available.
typedef SubscriptionActionOutcome = ({
  SubscriptionActionResult result,
  RemoveAdsSnapshot? snapshot,
});

/// Thin wrapper around RevenueCat [Purchases] for the remove-ads subscription.
class SubscriptionService {
  SubscriptionService();

  bool _configured = false;

  bool get isConfigured => _configured;

  /// Whether the current platform can use in-app purchases.
  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String? get _platformApiKey {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return RevenueCatConfig.androidApiKey;
      case TargetPlatform.iOS:
        return RevenueCatConfig.iosApiKey;
      default:
        return null;
    }
  }

  /// Configures the RevenueCat SDK once. Safe to call multiple times.
  Future<void> configure() async {
    if (_configured) return;
    if (!isSupportedPlatform) return;

    final apiKey = _platformApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'RevenueCat: API key missing for $defaultTargetPlatform. '
          'Set REVENUECAT_ANDROID_API_KEY / REVENUECAT_IOS_API_KEY or paste '
          'keys into RevenueCatConfig.',
        );
      }
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RevenueCat.configure failed: $e\n$st');
      }
    }
  }

  /// One [CustomerInfo] read → [RemoveAdsSnapshot]. Prefer this over piecemeal APIs.
  Future<RemoveAdsSnapshot> loadSnapshot() async {
    if (!_configured) return RemoveAdsSnapshot.empty;
    try {
      final info = await Purchases.getCustomerInfo();
      return RemoveAdsSnapshot.fromCustomerInfo(info);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('getCustomerInfo failed: $e');
      }
      return RemoveAdsSnapshot.empty;
    }
  }

  /// Listens for CustomerInfo updates (purchase, restore, refresh).
  void addCustomerInfoListener(void Function(CustomerInfo info) listener) {
    if (!_configured) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoListener(void Function(CustomerInfo info) listener) {
    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  /// Loads monthly + annual + lifetime remove-ads packages from the current offering.
  Future<RemoveAdsOffering> loadRemoveAdsOffering() async {
    if (!_configured) return const RemoveAdsOffering();
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        if (kDebugMode) {
          debugPrint('RevenueCat: no current offering configured');
        }
        return const RemoveAdsOffering();
      }

      Package? monthly = current.monthly;
      Package? yearly = current.annual;
      Package? lifetime = current.lifetime;

      // Single pass: fill any missing slots from package type or product id.
      for (final package in current.availablePackages) {
        final id = package.storeProduct.identifier;
        monthly ??= _matchPackage(
          package,
          id: id,
          type: PackageType.monthly,
          matchesId: RevenueCatConfig.matchesMonthlyProductId,
        );
        yearly ??= _matchPackage(
          package,
          id: id,
          type: PackageType.annual,
          matchesId: RevenueCatConfig.matchesYearlyProductId,
        );
        lifetime ??= _matchPackage(
          package,
          id: id,
          type: PackageType.lifetime,
          matchesId: RevenueCatConfig.matchesLifetimeProductId,
        );
      }

      return RemoveAdsOffering(
        monthly: monthly,
        yearly: yearly,
        lifetime: lifetime,
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('getOfferings failed: $e');
      }
      return const RemoveAdsOffering();
    }
  }

  static Package? _matchPackage(
    Package package, {
    required String id,
    required PackageType type,
    required bool Function(String?) matchesId,
  }) {
    if (package.packageType == type || matchesId(id)) return package;
    return null;
  }

  /// Purchases [package], attaching Play product-change info when replacing
  /// an active subscription (by store product id, not only mapped plan enum).
  ///
  /// Success only when the remove-ads entitlement is active on the resulting
  /// [CustomerInfo] — never unlock ads on a bare store success without entitle.
  Future<SubscriptionActionOutcome> purchasePackage(
    Package package, {
    RemoveAdsPlan? activePlan,
    RemoveAdsPlan? targetPlan,
    String? activeStoreProductId,
  }) async {
    if (!_configured) {
      return (result: SubscriptionActionResult.notConfigured, snapshot: null);
    }
    try {
      final changeInfo = await _productChangeInfoIfNeeded(
        package: package,
        activePlan: activePlan,
        targetPlan: targetPlan,
        activeStoreProductId: activeStoreProductId,
      );
      final result = await Purchases.purchase(
        PurchaseParams.package(
          package,
          productChangeInfo: changeInfo,
        ),
      );
      final snapshot = RemoveAdsSnapshot.fromCustomerInfo(result.customerInfo);
      if (!snapshot.entitled) {
        if (kDebugMode) {
          debugPrint(
            'purchase succeeded at store but remove_ads entitlement inactive',
          );
        }
        return (result: SubscriptionActionResult.error, snapshot: snapshot);
      }
      return (result: SubscriptionActionResult.success, snapshot: snapshot);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return (result: SubscriptionActionResult.cancelled, snapshot: null);
      }
      if (kDebugMode) {
        debugPrint('purchase failed: $e');
      }
      return (result: SubscriptionActionResult.error, snapshot: null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('purchase failed: $e');
      }
      return (result: SubscriptionActionResult.error, snapshot: null);
    }
  }

  /// Builds Play [StoreProductChangeInfo] when replacing an active sub.
  Future<StoreProductChangeInfo?> _productChangeInfoIfNeeded({
    required Package package,
    required RemoveAdsPlan? activePlan,
    required RemoveAdsPlan? targetPlan,
    required String? activeStoreProductId,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    final target = targetPlan ??
        removeAdsPlanFromProductId(package.storeProduct.identifier);
    final targetId = package.storeProduct.identifier;

    // Prefer caller-supplied product id (from entitlement state); else one fetch.
    var oldId = activeStoreProductId?.trim();
    if (oldId == null || oldId.isEmpty) {
      final snap = await loadSnapshot();
      oldId = snap.subscriptionProductId;
      // If we still have no plan from UI but snapshot has one, use it for mode.
      activePlan ??= snap.plan;
    }

    if (!requiresGoogleProductChange(
      activeStoreProductId: oldId,
      targetStoreProductId: targetId,
      activePlan: activePlan,
      targetPlan: target,
    )) {
      return null;
    }

    final mode = googleReplacementMode(
      activeStoreProductId: oldId,
      targetStoreProductId: targetId,
      activePlan: activePlan,
      targetPlan: target,
    );

    if (kDebugMode) {
      debugPrint(
        'purchase: Google product change $oldId → $targetId mode=$mode',
      );
    }

    return StoreProductChangeInfo(
      oldId!,
      replacementMode: mode ?? StoreReplacementMode.withoutProration,
    );
  }

  Future<SubscriptionActionOutcome> restorePurchases() async {
    if (!_configured) {
      return (result: SubscriptionActionResult.notConfigured, snapshot: null);
    }
    try {
      final info = await Purchases.restorePurchases();
      final snapshot = RemoveAdsSnapshot.fromCustomerInfo(info);
      if (snapshot.entitled) {
        return (result: SubscriptionActionResult.success, snapshot: snapshot);
      }
      return (result: SubscriptionActionResult.noPurchases, snapshot: snapshot);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('restorePurchases failed: $e');
      }
      return (result: SubscriptionActionResult.error, snapshot: null);
    }
  }

  /// URL to cancel / manage the subscription in Play Store or App Store.
  Future<Uri?> subscriptionManagementUri() async {
    if (_configured) {
      try {
        final snap = await loadSnapshot();
        final fromRc = snap.managementUrl;
        if (fromRc != null && fromRc.isNotEmpty) {
          return Uri.tryParse(fromRc);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('managementURL lookup failed: $e');
        }
      }
    }
    return _fallbackManagementUri();
  }

  Uri? _fallbackManagementUri() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Uri.parse(
          'https://play.google.com/store/account/subscriptions'
          '?package=com.thezello.lemonade',
        );
      case TargetPlatform.iOS:
        return Uri.parse('https://apps.apple.com/account/subscriptions');
      default:
        return null;
    }
  }
}
