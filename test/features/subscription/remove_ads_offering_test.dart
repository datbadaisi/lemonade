import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/revenuecat_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoveAdsOffering', () {
    test('defaultPlan prefers yearly when present', () {
      // Packages are opaque store objects; null/non-null is enough for plan logic
      // when we only assert defaultPlan + fallbacks without real Package instances.
      const empty = RemoveAdsOffering();
      expect(empty.defaultPlan, RemoveAdsPlan.yearly);
      expect(empty.hasAny, isFalse);
      expect(
        empty.priceLabel(RemoveAdsPlan.monthly),
        RevenueCatConfig.fallbackMonthlyPrice,
      );
      expect(
        empty.priceLabel(RemoveAdsPlan.yearly),
        RevenueCatConfig.fallbackYearlyPrice,
      );
      expect(
        empty.priceLabel(RemoveAdsPlan.lifetime),
        RevenueCatConfig.fallbackLifetimePrice,
      );
    });

    test('period labels', () {
      const offering = RemoveAdsOffering();
      expect(offering.periodLabel(RemoveAdsPlan.yearly), '/year');
      expect(offering.periodLabel(RemoveAdsPlan.monthly), '/month');
      expect(offering.periodLabel(RemoveAdsPlan.lifetime), ' once');
    });

    test('product ids match Play catalog (1 sub + 2 base plans)', () {
      expect(RevenueCatConfig.subscriptionProductId, 'remove_ads');
      expect(RevenueCatConfig.basePlanIdMonthly, 'monthly');
      expect(RevenueCatConfig.basePlanIdYearly, 'yearly');
      expect(RevenueCatConfig.productIdMonthly, 'remove_ads:monthly');
      expect(RevenueCatConfig.productIdYearly, 'remove_ads:yearly');
      expect(RevenueCatConfig.productIdLifetime, 'remove_ads_lifetime');
      expect(RevenueCatConfig.entitlementRemoveAds, 'remove_ads');
      expect(RevenueCatConfig.fallbackLifetimePrice, '\$19.99');
    });

    test('plan titles and period labels via extension', () {
      expect(RemoveAdsPlan.yearly.title, 'Yearly');
      expect(RemoveAdsPlan.monthly.title, 'Monthly');
      expect(RemoveAdsPlan.lifetime.title, 'Lifetime');
      expect(RemoveAdsPlan.yearly.periodLabel, '/year');
      expect(RemoveAdsPlan.monthly.periodLabel, '/month');
      expect(RemoveAdsPlan.lifetime.periodLabel, ' once');
      expect(RemoveAdsPlan.yearly.isSubscription, isTrue);
      expect(RemoveAdsPlan.monthly.isSubscription, isTrue);
      expect(RemoveAdsPlan.lifetime.isSubscription, isFalse);
    });
  });

  group('removeAdsPlanFromProductId', () {
    test('maps Play base-plan product ids', () {
      expect(
        removeAdsPlanFromProductId(RevenueCatConfig.productIdYearly),
        RemoveAdsPlan.yearly,
      );
      expect(
        removeAdsPlanFromProductId(RevenueCatConfig.productIdMonthly),
        RemoveAdsPlan.monthly,
      );
      expect(
        removeAdsPlanFromProductId(RevenueCatConfig.productIdLifetime),
        RemoveAdsPlan.lifetime,
      );
      expect(
        removeAdsPlanFromProductId('remove_ads:yearly'),
        RemoveAdsPlan.yearly,
      );
      expect(
        removeAdsPlanFromProductId('remove_ads:monthly'),
        RemoveAdsPlan.monthly,
      );
    });

    test('matches configured catalog ids and bare base plans', () {
      expect(
        RevenueCatConfig.matchesMonthlyProductId('remove_ads:monthly'),
        isTrue,
      );
      expect(
        RevenueCatConfig.matchesYearlyProductId('remove_ads:yearly'),
        isTrue,
      );
      expect(RevenueCatConfig.matchesMonthlyProductId('monthly'), isTrue);
      expect(RevenueCatConfig.matchesYearlyProductId('yearly'), isTrue);
      expect(
        RevenueCatConfig.matchesLifetimeProductId('remove_ads_lifetime'),
        isTrue,
      );
      expect(
        RevenueCatConfig.matchesMonthlyProductId('remove_ads:yearly'),
        isFalse,
      );
    });

    test('removeAdsPlanFromEntitlement uses Play productPlanIdentifier', () {
      // RC often returns product=remove_ads + plan=monthly (not productId:basePlan).
      expect(
        removeAdsPlanFromEntitlement(
          productIdentifier: 'remove_ads',
          productPlanIdentifier: 'monthly',
        ),
        RemoveAdsPlan.monthly,
      );
      expect(
        removeAdsPlanFromEntitlement(
          productIdentifier: 'remove_ads',
          productPlanIdentifier: 'yearly',
        ),
        RemoveAdsPlan.yearly,
      );
      expect(
        removeAdsPlanFromEntitlement(
          productIdentifier: 'remove_ads:yearly',
          productPlanIdentifier: null,
        ),
        RemoveAdsPlan.yearly,
      );
      expect(
        removeAdsPlanFromEntitlement(
          productIdentifier: 'remove_ads_lifetime',
          productPlanIdentifier: null,
        ),
        RemoveAdsPlan.lifetime,
      );
      expect(
        removeAdsPlanFromEntitlement(
          productIdentifier: 'remove_ads',
          productPlanIdentifier: null,
        ),
        isNull,
      );
    });

    test('returns null for empty or unknown ids', () {
      expect(removeAdsPlanFromProductId(null), isNull);
      expect(removeAdsPlanFromProductId(''), isNull);
      expect(removeAdsPlanFromProductId('premium_plus'), isNull);
    });
  });
}
