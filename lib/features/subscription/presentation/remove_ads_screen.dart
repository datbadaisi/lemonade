import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/subscription/data/subscription_providers.dart';
import 'package:bluerum/features/subscription/data/subscription_service.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_plan_change.dart';
import 'package:bluerum/features/subscription/presentation/widgets/remove_ads_chrome.dart';
import 'package:bluerum/features/subscription/presentation/widgets/remove_ads_plan_option.dart';

/// Paywall + subscription management for remove-ads.
///
/// Production pattern:
/// - **Acquire**: pick a plan → purchase
/// - **Manage**: active = Current; other plans = upgrade/switch
/// - **Lifetime**: max tier — thank-you only
/// - Cancel / billing always via store management URL
///
/// Entitlement/plan come from [removeAdsEntitlementProvider] only — no
/// lastKnown / local-selection merge for "active" badges.
class RemoveAdsScreen extends ConsumerStatefulWidget {
  const RemoveAdsScreen({super.key});

  @override
  ConsumerState<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends ConsumerState<RemoveAdsScreen> {
  bool _busy = false;

  /// User override for which plan is highlighted; null = defaultSelectedPlan.
  RemoveAdsPlan? _selectedPlan;

  Future<void> _purchase({
    required Package package,
    required RemoveAdsPlan targetPlan,
    required RemoveAdsPlan? activePlan,
    required String? activeStoreProductId,
    required PlanPurchaseIntent intent,
    required bool entitled,
  }) async {
    if (_busy) return;

    if (intent == PlanPurchaseIntent.unlockLifetime &&
        shouldWarnLifetimeWhileSubscribed(
          entitled: entitled,
          activePlan: activePlan,
        )) {
      final proceed = await _confirmLifetimeWhileSubscribed();
      if (!proceed || !mounted) return;
    }

    setState(() => _busy = true);
    final service = ref.read(subscriptionServiceProvider);
    final outcome = await service.purchasePackage(
      package,
      activePlan: activePlan,
      targetPlan: targetPlan,
      activeStoreProductId: activeStoreProductId,
    );
    if (!mounted) return;

    switch (outcome.result) {
      case SubscriptionActionResult.success:
        final snapshot = outcome.snapshot!;
        await ref
            .read(removeAdsEntitlementProvider.notifier)
            .applyVerifiedSnapshot(snapshot, fallbackPlan: targetPlan);
        if (mounted) {
          setState(() {
            _selectedPlan = snapshot.plan ?? targetPlan;
          });
        }
        if (!mounted) return;
        final message = switch (intent) {
          PlanPurchaseIntent.upgrade ||
          PlanPurchaseIntent.switchPlan =>
            'Plan updated. Ads stay removed.',
          PlanPurchaseIntent.unlockLifetime =>
            'Lifetime unlocked. Ads are off forever on this store account.',
          _ => 'Thank you! Ads have been removed.',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      case SubscriptionActionResult.cancelled:
        break;
      case SubscriptionActionResult.notConfigured:
        _showMessage(
          'Purchases are not configured yet. Please try again later.',
        );
      case SubscriptionActionResult.error:
        _showMessage('Could not complete the purchase. Please try again.');
      case SubscriptionActionResult.noPurchases:
        break;
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<bool> _confirmLifetimeWhileSubscribed() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unlock lifetime?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Lifetime does not auto-cancel a monthly or yearly plan. '
          'After purchase, use Manage subscription to cancel '
          'the recurring billing.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Not now',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.action),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final service = ref.read(subscriptionServiceProvider);
    final outcome = await service.restorePurchases();
    if (!mounted) return;

    switch (outcome.result) {
      case SubscriptionActionResult.success:
        final snapshot = outcome.snapshot!;
        await ref
            .read(removeAdsEntitlementProvider.notifier)
            .applyVerifiedSnapshot(snapshot);
        if (snapshot.plan != null && mounted) {
          setState(() => _selectedPlan = snapshot.plan);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored. Ads have been removed.'),
          ),
        );
      case SubscriptionActionResult.noPurchases:
        _showMessage(
          'No previous purchases found for this store account.',
        );
      case SubscriptionActionResult.notConfigured:
        _showMessage(
          'Purchases are not configured yet. Please try again later.',
        );
      case SubscriptionActionResult.error:
        _showMessage('Restore failed. Please try again.');
      case SubscriptionActionResult.cancelled:
        break;
    }

    if (mounted) setState(() => _busy = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openManageSubscriptions() async {
    final service = ref.read(subscriptionServiceProvider);
    final uri = await service.subscriptionManagementUri();
    if (!mounted) return;
    if (uri == null) {
      _showMessage('Subscription management is not available on this device.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      _showMessage('Could not open subscription management.');
    }
  }

  RemoveAdsPlan _effectivePlan({
    required bool entitled,
    required RemoveAdsPlan? activePlan,
    required RemoveAdsOffering offering,
  }) {
    final selected = _selectedPlan;
    if (selected != null &&
        (offering.packageFor(selected) != null || !offering.hasAny)) {
      return selected;
    }
    return defaultSelectedPlan(
      entitled: entitled,
      activePlan: activePlan,
      offering: offering,
    );
  }

  @override
  Widget build(BuildContext context) {
    final offeringAsync = ref.watch(removeAdsOfferingProvider);
    final entitlement = ref.watch(removeAdsEntitlementProvider);
    final service = ref.watch(subscriptionServiceProvider);

    // Store entitlement is the only source for "active" plan / entitled badges.
    // Fall back to local ads cache only before first store sync completes.
    final adsRemovedCache =
        ref.watch(adsSettingsProvider.select((s) => s.adsRemoved));
    final entitled =
        entitlement.storeSynced ? entitlement.entitled : adsRemovedCache;
    final activePlan = entitlement.entitled ? entitlement.plan : null;
    final activeStoreProductId =
        entitlement.entitled ? entitlement.subscriptionProductId : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Remove ads',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        leading: const RemoveAdsBackButton(),
      ),
      body: offeringAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.textPrimary,
            strokeWidth: 2.2,
          ),
        ),
        error: (e, _) => RemoveAdsErrorBody(
          message: 'Could not load subscription plans.\n$e',
          onRetry: () {
            ref.invalidate(removeAdsOfferingProvider);
          },
        ),
        data: (offering) {
          final lifetimeActive =
              entitled && activePlan == RemoveAdsPlan.lifetime;
          final showPlanPicker =
              !lifetimeActive && canChangeRemoveAdsPlan(activePlan);

          final plan = lifetimeActive
              ? RemoveAdsPlan.lifetime
              : _effectivePlan(
                  entitled: entitled,
                  activePlan: activePlan,
                  offering: offering,
                );
          final intent = planPurchaseIntent(
            entitled: entitled,
            activePlan: activePlan,
            selected: plan,
          );
          final selectedPackage = offering.packageFor(plan);
          final priceLabel = offering.priceLabel(plan);
          final periodLabel = offering.periodLabel(plan);
          final ctaLabel = planPrimaryCtaLabel(
            intent: intent,
            selected: plan,
            priceLabel: priceLabel,
            periodLabel: periodLabel,
          );
          final canPurchase = intent != PlanPurchaseIntent.current &&
              selectedPackage != null &&
              service.isConfigured &&
              !_busy;

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RemoveAdsHeader(entitled: entitled),
              ),
              const SizedBox(height: 20),
              const RemoveAdsBenefitsList(),
              const SizedBox(height: 8),
              if (lifetimeActive)
                RemoveAdsLifetimeActiveRow(offering: offering)
              else if (showPlanPicker)
                RemoveAdsPlanPicker(
                  offering: offering,
                  activePlan: activePlan,
                  selectedPlan: plan,
                  sectionTitle: entitled ? 'Your plan' : 'Choose a plan',
                  onSelect: (p) => setState(() => _selectedPlan = p),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: [
                    if (lifetimeActive)
                      const SizedBox.shrink()
                    else if (intent == PlanPurchaseIntent.current && !_busy)
                      IgnorePointer(
                        child: RemoveAdsOutlineButton(
                          label: ctaLabel,
                          onPressed: () {},
                        ),
                      )
                    else
                      RemoveAdsPrimaryButton(
                        label: selectedPackage == null && offering.hasAny
                            ? 'Package not available yet'
                            : ctaLabel,
                        onPressed: !canPurchase
                            ? null
                            : () => _purchase(
                                  package: selectedPackage!,
                                  targetPlan: plan,
                                  activePlan: activePlan,
                                  activeStoreProductId: activeStoreProductId,
                                  intent: intent,
                                  entitled: entitled,
                                ),
                        busy: _busy,
                      ),
                    SizedBox(height: lifetimeActive ? 8 : 14),
                    if (entitled)
                      Column(
                        children: [
                          RemoveAdsOutlineButton(
                            label: 'Manage subscription',
                            onPressed: _openManageSubscriptions,
                          ),
                          const SizedBox(height: 14),
                          RemoveAdsFooterLink(
                            label: 'Restore purchases',
                            color: AppColors.textPrimary,
                            onTap: _busy || !service.isConfigured
                                ? null
                                : _restore,
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RemoveAdsFooterLink(
                            label: 'Restore purchases',
                            color: AppColors.textPrimary,
                            onTap: _busy || !service.isConfigured
                                ? null
                                : _restore,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '·',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          RemoveAdsFooterLink(
                            label: 'Manage subscription',
                            color: AppColors.textPrimary,
                            onTap: _openManageSubscriptions,
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    const RemoveAdsStoreAccountNotice(),
                    if (!service.isConfigured) ...[
                      const SizedBox(height: 12),
                      const RemoveAdsConfigHint(),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
