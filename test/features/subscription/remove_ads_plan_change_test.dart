import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_plan_change.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('planPurchaseIntent', () {
    test('new customer subscribe vs lifetime', () {
      expect(
        planPurchaseIntent(
          entitled: false,
          activePlan: null,
          selected: RemoveAdsPlan.yearly,
        ),
        PlanPurchaseIntent.subscribe,
      );
      expect(
        planPurchaseIntent(
          entitled: false,
          activePlan: null,
          selected: RemoveAdsPlan.lifetime,
        ),
        PlanPurchaseIntent.unlockLifetime,
      );
    });

    test('current plan disabled', () {
      expect(
        planPurchaseIntent(
          entitled: true,
          activePlan: RemoveAdsPlan.monthly,
          selected: RemoveAdsPlan.monthly,
        ),
        PlanPurchaseIntent.current,
      );
    });

    test('upgrade monthly to yearly', () {
      expect(
        planPurchaseIntent(
          entitled: true,
          activePlan: RemoveAdsPlan.monthly,
          selected: RemoveAdsPlan.yearly,
        ),
        PlanPurchaseIntent.upgrade,
      );
    });

    test('switch yearly to monthly', () {
      expect(
        planPurchaseIntent(
          entitled: true,
          activePlan: RemoveAdsPlan.yearly,
          selected: RemoveAdsPlan.monthly,
        ),
        PlanPurchaseIntent.switchPlan,
      );
    });

    test('sub to lifetime is unlock', () {
      expect(
        planPurchaseIntent(
          entitled: true,
          activePlan: RemoveAdsPlan.yearly,
          selected: RemoveAdsPlan.lifetime,
        ),
        PlanPurchaseIntent.unlockLifetime,
      );
    });

    test('entitled with unknown plan still manage mode not subscribe', () {
      expect(
        planPurchaseIntent(
          entitled: true,
          activePlan: null,
          selected: RemoveAdsPlan.yearly,
        ),
        PlanPurchaseIntent.switchPlan,
      );
      expect(
        planPurchaseIntent(
          entitled: true,
          activePlan: null,
          selected: RemoveAdsPlan.lifetime,
        ),
        PlanPurchaseIntent.unlockLifetime,
      );
    });
  });

  group('shouldWarnLifetimeWhileSubscribed', () {
    test('warns when entitled non-lifetime', () {
      expect(
        shouldWarnLifetimeWhileSubscribed(
          entitled: true,
          activePlan: RemoveAdsPlan.monthly,
        ),
        isTrue,
      );
      expect(
        shouldWarnLifetimeWhileSubscribed(
          entitled: true,
          activePlan: null,
        ),
        isTrue,
      );
      expect(
        shouldWarnLifetimeWhileSubscribed(
          entitled: true,
          activePlan: RemoveAdsPlan.lifetime,
        ),
        isFalse,
      );
      expect(
        shouldWarnLifetimeWhileSubscribed(
          entitled: false,
          activePlan: null,
        ),
        isFalse,
      );
    });
  });

  group('defaultSelectedPlan', () {
    test('entitled selects current active plan (monthly or yearly)', () {
      const offering = RemoveAdsOffering();
      expect(
        defaultSelectedPlan(
          entitled: true,
          activePlan: RemoveAdsPlan.monthly,
          offering: offering,
        ),
        RemoveAdsPlan.monthly,
      );
      expect(
        defaultSelectedPlan(
          entitled: true,
          activePlan: RemoveAdsPlan.yearly,
          offering: offering,
        ),
        RemoveAdsPlan.yearly,
      );
    });

    test('unentitled uses offering default (yearly)', () {
      const offering = RemoveAdsOffering();
      expect(
        defaultSelectedPlan(
          entitled: false,
          activePlan: null,
          offering: offering,
        ),
        RemoveAdsPlan.yearly,
      );
    });
  });

  group('requiresGoogleProductChange / googleReplacementMode', () {
    test('uses store product ids even when plan enum is null', () {
      expect(
        requiresGoogleProductChange(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads:yearly',
          activePlan: null,
          targetPlan: RemoveAdsPlan.yearly,
        ),
        isTrue,
      );
      expect(
        googleReplacementMode(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads:yearly',
          activePlan: null,
          targetPlan: RemoveAdsPlan.yearly,
        ),
        StoreReplacementMode.withoutProration,
      );
    });

    test('only for subscription to different subscription product', () {
      expect(
        requiresGoogleProductChange(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads:yearly',
          activePlan: RemoveAdsPlan.monthly,
          targetPlan: RemoveAdsPlan.yearly,
        ),
        isTrue,
      );
      expect(
        requiresGoogleProductChange(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads_lifetime',
          activePlan: RemoveAdsPlan.monthly,
          targetPlan: RemoveAdsPlan.lifetime,
        ),
        isFalse,
      );
      expect(
        requiresGoogleProductChange(
          activeStoreProductId: null,
          targetStoreProductId: 'remove_ads:yearly',
          activePlan: null,
          targetPlan: RemoveAdsPlan.yearly,
        ),
        isFalse,
      );
      expect(
        requiresGoogleProductChange(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads:monthly',
          activePlan: RemoveAdsPlan.monthly,
          targetPlan: RemoveAdsPlan.monthly,
        ),
        isFalse,
      );
    });

    test('same-subscription base plan changes use withoutProration', () {
      expect(
        googleReplacementMode(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads:yearly',
          activePlan: RemoveAdsPlan.monthly,
          targetPlan: RemoveAdsPlan.yearly,
        ),
        StoreReplacementMode.withoutProration,
      );
      expect(
        googleReplacementMode(
          activeStoreProductId: 'remove_ads:yearly',
          targetStoreProductId: 'remove_ads:monthly',
          activePlan: RemoveAdsPlan.yearly,
          targetPlan: RemoveAdsPlan.monthly,
        ),
        StoreReplacementMode.withoutProration,
      );
      expect(
        googleReplacementMode(
          activeStoreProductId: 'remove_ads:monthly',
          targetStoreProductId: 'remove_ads_lifetime',
          activePlan: RemoveAdsPlan.monthly,
          targetPlan: RemoveAdsPlan.lifetime,
        ),
        isNull,
      );
    });
  });

  group('planPrimaryCtaLabel', () {
    test('labels for each intent', () {
      expect(
        planPrimaryCtaLabel(
          intent: PlanPurchaseIntent.current,
          selected: RemoveAdsPlan.monthly,
          priceLabel: '\$1.99',
          periodLabel: '/month',
        ),
        'You\'re on this plan',
      );
      expect(
        planPrimaryCtaLabel(
          intent: PlanPurchaseIntent.upgrade,
          selected: RemoveAdsPlan.yearly,
          priceLabel: '\$9.99',
          periodLabel: '/year',
        ),
        'Upgrade to Yearly · \$9.99',
      );
      expect(
        planPrimaryCtaLabel(
          intent: PlanPurchaseIntent.switchPlan,
          selected: RemoveAdsPlan.monthly,
          priceLabel: '\$1.99',
          periodLabel: '/month',
        ),
        'Switch to Monthly · \$1.99',
      );
      expect(
        planPrimaryCtaLabel(
          intent: PlanPurchaseIntent.subscribe,
          selected: RemoveAdsPlan.yearly,
          priceLabel: '\$9.99',
          periodLabel: '/year',
        ),
        'Support \$9.99/year',
      );
      expect(
        planPrimaryCtaLabel(
          intent: PlanPurchaseIntent.unlockLifetime,
          selected: RemoveAdsPlan.lifetime,
          priceLabel: '\$19.99',
          periodLabel: ' once',
        ),
        'Unlock forever · \$19.99',
      );
    });
  });

  group('canChangeRemoveAdsPlan', () {
    test('lifetime cannot change; subscriptions can', () {
      expect(canChangeRemoveAdsPlan(RemoveAdsPlan.lifetime), isFalse);
      expect(canChangeRemoveAdsPlan(RemoveAdsPlan.monthly), isTrue);
      expect(canChangeRemoveAdsPlan(null), isTrue);
    });
  });

  group('planRowSubtitle / freeTrialSubtitle', () {
    test('never hardcodes free trial without intro price', () {
      expect(
        planRowSubtitle(
          plan: RemoveAdsPlan.monthly,
          isCurrent: false,
          package: null,
        ),
        'Billed monthly',
      );
      expect(
        planRowSubtitle(
          plan: RemoveAdsPlan.yearly,
          isCurrent: false,
          package: null,
        ),
        'Best value · billed once a year',
      );
    });

    test('free trial only when intro price is zero', () {
      expect(freeTrialSubtitle(null), isNull);
      expect(
        freeTrialSubtitle(
          const IntroductoryPrice(
            0,
            '\$0.00',
            'P1M',
            1,
            PeriodUnit.month,
            1,
          ),
        ),
        'First month free',
      );
      expect(
        freeTrialSubtitle(
          const IntroductoryPrice(
            0.99,
            '\$0.99',
            'P1M',
            1,
            PeriodUnit.month,
            1,
          ),
        ),
        isNull,
      );
      expect(
        freeTrialSubtitle(
          const IntroductoryPrice(
            0,
            '\$0.00',
            'P7D',
            1,
            PeriodUnit.day,
            7,
          ),
        ),
        'First 7 days free',
      );
    });

    test('current plan subtitles', () {
      expect(
        planRowSubtitle(
          plan: RemoveAdsPlan.monthly,
          isCurrent: true,
        ),
        'Current · billed monthly',
      );
      expect(
        planRowSubtitle(
          plan: RemoveAdsPlan.lifetime,
          isCurrent: true,
        ),
        'Active · one-time purchase',
      );
    });
  });
}
