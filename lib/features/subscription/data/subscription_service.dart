import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:bluerum/features/subscription/domain/lifetime_purchase_config.dart';
import 'package:bluerum/features/subscription/domain/lifetime_purchase_offering.dart';
import 'package:bluerum/features/subscription/domain/lifetime_purchase_snapshot.dart';

enum LifetimePurchaseActionResult {
  started,
  notAvailable,
  notConfigured,
  error,
}

enum LifetimePurchaseEventType {
  pending,
  purchased,
  restored,
  restoreCompleted,
  cancelled,
  error,
}

final class LifetimePurchaseEvent {
  const LifetimePurchaseEvent({
    required this.type,
    this.snapshot,
    this.message,
  });

  final LifetimePurchaseEventType type;
  final LifetimePurchaseSnapshot? snapshot;
  final String? message;
}

/// Thin wrapper around Flutter's store-independent in-app purchase API.
class LifetimePurchaseService {
  LifetimePurchaseService({InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
  final _events = StreamController<LifetimePurchaseEvent>.broadcast(sync: true);
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _initialized = false;
  bool _available = false;
  ProductDetails? _lifetimeProduct;
  Future<void>? _initializationFuture;
  bool _restoreInFlight = false;

  bool get isConfigured => _initialized && _available;
  bool get isReady => isConfigured && _lifetimeProduct != null;
  ProductDetails? get lifetimeProduct => _lifetimeProduct;
  Stream<LifetimePurchaseEvent> get events => _events.stream;

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Starts listening before any restore or purchase operation is requested.
  Future<void> initialize() async {
    final future = _initializationFuture ??= _initialize();
    try {
      await future;
    } finally {
      // Store availability and product queries are transient. Do not cache a
      // failed/unavailable attempt for the rest of the process lifetime.
      if (identical(_initializationFuture, future) && !isReady) {
        _initializationFuture = null;
      }
    }
  }

  Future<void> _initialize() async {
    _initialized = true;

    if (!isSupportedPlatform) return;

    _purchaseSubscription ??= _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _log('purchaseStream failed: $error\n$stackTrace');
        _events.add(
          LifetimePurchaseEvent(
            type: LifetimePurchaseEventType.error,
            message: error.toString(),
          ),
        );
      },
    );

    try {
      _available = await _store.isAvailable();
      if (!_available) return;

      final response = await _store.queryProductDetails({
        LifetimePurchaseConfig.productId,
      });
      if (response.error != null) {
        _log('queryProductDetails failed: ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        _log('Product not found: ${response.notFoundIDs.join(', ')}');
      }
      for (final product in response.productDetails) {
        if (product.id == LifetimePurchaseConfig.productId) {
          _lifetimeProduct = product;
          break;
        }
      }
    } catch (error, stackTrace) {
      _log('store initialization failed: $error\n$stackTrace');
    }
  }

  Future<LifetimePurchaseOffering> loadOffering() async {
    await initialize();
    return LifetimePurchaseOffering(lifetime: _lifetimeProduct);
  }

  /// Starts the native purchase UI. The final result arrives on [events].
  Future<LifetimePurchaseActionResult> purchaseLifetime() async {
    await initialize();
    if (!isSupportedPlatform || !_available) {
      return LifetimePurchaseActionResult.notAvailable;
    }
    final product = _lifetimeProduct;
    if (product == null) {
      return LifetimePurchaseActionResult.notConfigured;
    }

    try {
      final started = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      return started
          ? LifetimePurchaseActionResult.started
          : LifetimePurchaseActionResult.error;
    } catch (error, stackTrace) {
      _log('purchase failed: $error\n$stackTrace');
      return LifetimePurchaseActionResult.error;
    }
  }

  /// Requests the store to emit previously purchased non-consumables.
  Future<LifetimePurchaseActionResult> restorePurchases() async {
    await initialize();
    if (!isSupportedPlatform || !_available) {
      return LifetimePurchaseActionResult.notAvailable;
    }
    if (_restoreInFlight) {
      return LifetimePurchaseActionResult.started;
    }

    try {
      _restoreInFlight = true;
      await _store.restorePurchases();
      return LifetimePurchaseActionResult.started;
    } catch (error, stackTrace) {
      _restoreInFlight = false;
      _log('restorePurchases failed: $error\n$stackTrace');
      return LifetimePurchaseActionResult.error;
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    var restoredLifetime = false;
    for (final purchase in purchases) {
      try {
        switch (purchase.status) {
          case PurchaseStatus.pending:
            _events.add(
              const LifetimePurchaseEvent(
                type: LifetimePurchaseEventType.pending,
              ),
            );
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            final snapshot = LifetimePurchaseSnapshot.fromPurchase(purchase);
            if (snapshot.entitled) {
              if (_restoreInFlight &&
                  purchase.status == PurchaseStatus.restored) {
                restoredLifetime = true;
              }
              _events.add(
                LifetimePurchaseEvent(
                  type: purchase.status == PurchaseStatus.restored
                      ? LifetimePurchaseEventType.restored
                      : LifetimePurchaseEventType.purchased,
                  snapshot: snapshot,
                ),
              );
            } else {
              _events.add(
                const LifetimePurchaseEvent(
                  type: LifetimePurchaseEventType.error,
                  message: 'Unexpected product returned by the store.',
                ),
              );
            }
          case PurchaseStatus.canceled:
            _events.add(
              const LifetimePurchaseEvent(
                type: LifetimePurchaseEventType.cancelled,
              ),
            );
          case PurchaseStatus.error:
            _events.add(
              LifetimePurchaseEvent(
                type: LifetimePurchaseEventType.error,
                message: purchase.error?.message,
              ),
            );
        }

        if (purchase.pendingCompletePurchase) {
          await _store.completePurchase(purchase);
        }
      } catch (error, stackTrace) {
        _log('processing purchase failed: $error\n$stackTrace');
      }
    }

    // Flutter's store implementations emit one list for restore, including
    // an empty list when the account owns no restorable products.
    if (_restoreInFlight) {
      _restoreInFlight = false;
      _events.add(
        LifetimePurchaseEvent(
          type: LifetimePurchaseEventType.restoreCompleted,
          snapshot: restoredLifetime
              ? const LifetimePurchaseSnapshot(
                  entitled: true,
                  productId: LifetimePurchaseConfig.productId,
                )
              : LifetimePurchaseSnapshot.empty,
        ),
      );
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('IAP: $message');
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _events.close();
  }
}
