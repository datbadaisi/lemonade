import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

EntitlementInfo _entitlement({
  required bool active,
  required String productIdentifier,
  String? productPlanIdentifier,
}) {
  return EntitlementInfo(
    'remove_ads',
    active,
    true,
    '2020-01-01T00:00:00Z',
    '2020-01-01T00:00:00Z',
    productIdentifier,
    false,
    ownershipType: OwnershipType.purchased,
    store: Store.playStore,
    periodType: PeriodType.normal,
    productPlanIdentifier: productPlanIdentifier,
  );
}

CustomerInfo _customerInfo({
  Map<String, EntitlementInfo>? entitlements,
  String? managementURL,
}) {
  final all = entitlements ?? {};
  final active = <String, EntitlementInfo>{
    for (final e in all.entries)
      if (e.value.isActive) e.key: e.value,
  };
  return CustomerInfo(
    EntitlementInfos(all, active),
    const {},
    const [],
    const [],
    const [],
    'firstSeen',
    'appUserId',
    const {},
    'requestDate',
    managementURL: managementURL,
  );
}

void main() {
  group('RemoveAdsSnapshot.fromCustomerInfo', () {
    test('not entitled clears plan and product id', () {
      final snap = RemoveAdsSnapshot.fromCustomerInfo(
        _customerInfo(
          entitlements: {
            'remove_ads': _entitlement(
              active: false,
              productIdentifier: 'remove_ads:monthly',
            ),
          },
        ),
      );
      expect(snap.entitled, isFalse);
      expect(snap.plan, isNull);
      expect(snap.subscriptionProductId, isNull);
    });

    test('empty entitlements → not entitled', () {
      final snap = RemoveAdsSnapshot.fromCustomerInfo(_customerInfo());
      expect(snap.entitled, isFalse);
      expect(snap.plan, isNull);
      expect(snap.subscriptionProductId, isNull);
    });

    test('active monthly via productPlanIdentifier', () {
      final snap = RemoveAdsSnapshot.fromCustomerInfo(
        _customerInfo(
          entitlements: {
            'remove_ads': _entitlement(
              active: true,
              productIdentifier: 'remove_ads',
              productPlanIdentifier: 'monthly',
            ),
          },
          managementURL: 'https://play.google.com/manage',
        ),
      );
      expect(snap.entitled, isTrue);
      expect(snap.plan, RemoveAdsPlan.monthly);
      expect(snap.subscriptionProductId, 'remove_ads:monthly');
      expect(snap.managementUrl, 'https://play.google.com/manage');
    });

    test('active yearly full product id', () {
      final snap = RemoveAdsSnapshot.fromCustomerInfo(
        _customerInfo(
          entitlements: {
            'remove_ads': _entitlement(
              active: true,
              productIdentifier: 'remove_ads:yearly',
            ),
          },
        ),
      );
      expect(snap.entitled, isTrue);
      expect(snap.plan, RemoveAdsPlan.yearly);
      expect(snap.subscriptionProductId, 'remove_ads:yearly');
    });

    test('active lifetime', () {
      final snap = RemoveAdsSnapshot.fromCustomerInfo(
        _customerInfo(
          entitlements: {
            'remove_ads': _entitlement(
              active: true,
              productIdentifier: 'remove_ads_lifetime',
            ),
          },
        ),
      );
      expect(snap.entitled, isTrue);
      expect(snap.plan, RemoveAdsPlan.lifetime);
      expect(snap.subscriptionProductId, 'remove_ads_lifetime');
    });

    test('active but unmapped product still entitled with product id', () {
      final snap = RemoveAdsSnapshot.fromCustomerInfo(
        _customerInfo(
          entitlements: {
            'remove_ads': _entitlement(
              active: true,
              productIdentifier: 'remove_ads',
              productPlanIdentifier: null,
            ),
          },
        ),
      );
      expect(snap.entitled, isTrue);
      expect(snap.plan, isNull);
      expect(snap.subscriptionProductId, 'remove_ads');
    });
  });
}
