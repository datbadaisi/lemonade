import 'package:in_app_purchase/in_app_purchase.dart';

/// The only paid product currently offered by Lemonade.
class LifetimePurchaseOffering {
  const LifetimePurchaseOffering({this.lifetime});

  final ProductDetails? lifetime;

  bool get hasProduct => lifetime != null;

  String get priceLabel => lifetime?.price ?? '';
}
