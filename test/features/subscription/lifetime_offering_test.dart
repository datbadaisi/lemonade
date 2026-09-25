import 'package:bluerum/features/subscription/domain/lifetime_purchase_config.dart';
import 'package:bluerum/features/subscription/domain/lifetime_purchase_offering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  test('catalog contains only the stable lifetime product', () {
    expect(LifetimePurchaseConfig.productId, 'remove_ads_lifetime');
    const empty = LifetimePurchaseOffering();
    expect(empty.hasProduct, isFalse);
    expect(empty.priceLabel, isEmpty);
  });

  test('uses the localized store price', () {
    final product = ProductDetails(
      id: 'remove_ads_lifetime',
      title: 'Lifetime supporter',
      description: 'One-time purchase',
      price: '\$19.99',
      rawPrice: 19.99,
      currencyCode: 'USD',
    );
    final offering = LifetimePurchaseOffering(lifetime: product);

    expect(offering.hasProduct, isTrue);
    expect(offering.priceLabel, '\$19.99');
  });
}
