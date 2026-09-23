import 'package:bluerum/features/subscription/domain/remove_ads_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

PurchaseDetails _purchase({
  required String productId,
  required PurchaseStatus status,
  bool hasVerificationData = true,
}) {
  return PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: hasVerificationData ? 'local' : '',
      serverVerificationData: hasVerificationData ? 'server' : '',
      source: 'test',
    ),
    transactionDate: '2020-01-01T00:00:00Z',
    status: status,
  );
}

void main() {
  group('RemoveAdsSnapshot.fromPurchase', () {
    test('accepts a purchased lifetime product', () {
      final snapshot = RemoveAdsSnapshot.fromPurchase(
        _purchase(
          productId: 'remove_ads_lifetime',
          status: PurchaseStatus.purchased,
        ),
      );

      expect(snapshot.entitled, isTrue);
      expect(snapshot.productId, 'remove_ads_lifetime');
    });

    test('accepts a restored lifetime product', () {
      final snapshot = RemoveAdsSnapshot.fromPurchase(
        _purchase(
          productId: 'remove_ads_lifetime',
          status: PurchaseStatus.restored,
        ),
      );

      expect(snapshot.entitled, isTrue);
    });

    test('rejects subscriptions and other products', () {
      for (final purchase in [
        _purchase(productId: 'remove_ads', status: PurchaseStatus.purchased),
        _purchase(
          productId: 'remove_ads_lifetime',
          status: PurchaseStatus.pending,
        ),
      ]) {
        final snapshot = RemoveAdsSnapshot.fromPurchase(purchase);
        expect(snapshot.entitled, isFalse);
        expect(snapshot.productId, isNull);
      }
    });

    test('rejects a lifetime update without store verification payload', () {
      final snapshot = RemoveAdsSnapshot.fromPurchase(
        _purchase(
          productId: 'remove_ads_lifetime',
          status: PurchaseStatus.purchased,
          hasVerificationData: false,
        ),
      );

      expect(snapshot.entitled, isFalse);
      expect(snapshot.productId, isNull);
    });
  });
}
