import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:bluerum/features/subscription/domain/lifetime_purchase_config.dart';

/// Store-backed state for the lifetime purchase.
///
/// With no backend, the safest client-only gate is the store's
/// purchased/restored status, the exact product ID, and a non-empty store
/// verification payload. Cryptographic receipt verification would require a
/// platform-specific verifier or a trusted server and is intentionally not
/// claimed here.
final class LifetimePurchaseSnapshot {
  const LifetimePurchaseSnapshot({required this.entitled, this.productId});

  static const empty = LifetimePurchaseSnapshot(entitled: false);

  final bool entitled;
  final String? productId;

  factory LifetimePurchaseSnapshot.fromPurchase(PurchaseDetails purchase) {
    final isLifetime = purchase.productID == LifetimePurchaseConfig.productId;
    final isOwned =
        purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored;
    final hasStoreVerificationPayload =
        purchase.verificationData.localVerificationData.trim().isNotEmpty &&
        purchase.verificationData.serverVerificationData.trim().isNotEmpty;

    return LifetimePurchaseSnapshot(
      entitled: isLifetime && isOwned && hasStoreVerificationPayload,
      productId: isLifetime && isOwned && hasStoreVerificationPayload
          ? purchase.productID
          : null,
    );
  }
}
