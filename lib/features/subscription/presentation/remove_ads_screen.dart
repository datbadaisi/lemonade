import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/ads/data/ads_settings.dart';
import 'package:bluerum/features/subscription/data/subscription_providers.dart';
import 'package:bluerum/features/subscription/data/subscription_service.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/presentation/widgets/remove_ads_chrome.dart';

/// Lifetime-only remove-ads paywall.
class RemoveAdsScreen extends ConsumerStatefulWidget {
  const RemoveAdsScreen({super.key});

  @override
  ConsumerState<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends ConsumerState<RemoveAdsScreen> {
  bool _busy = false;

  Future<void> _purchase(RemoveAdsOffering offering) async {
    if (_busy || offering.lifetime == null) return;
    setState(() => _busy = true);

    final result = await ref
        .read(lifetimePurchaseServiceProvider)
        .purchaseLifetime();
    if (!mounted) return;

    switch (result) {
      case LifetimePurchaseActionResult.started:
        break;
      case LifetimePurchaseActionResult.notAvailable:
        _showMessage('In-app purchases are not available on this device.');
      case LifetimePurchaseActionResult.notConfigured:
        _showMessage(
          'The lifetime product is not available yet. Please try again later.',
        );
      case LifetimePurchaseActionResult.error:
        _showMessage('Could not start the purchase. Please try again.');
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await ref
        .read(lifetimePurchaseServiceProvider)
        .restorePurchases();
    if (!mounted) return;

    switch (result) {
      case LifetimePurchaseActionResult.started:
        _showMessage(
          'Restore requested. If this store account owns lifetime, ads will be removed.',
        );
      case LifetimePurchaseActionResult.notAvailable:
        _showMessage('In-app purchases are not available on this device.');
      case LifetimePurchaseActionResult.notConfigured:
        _showMessage(
          'The lifetime product is not available yet. Please try again later.',
        );
      case LifetimePurchaseActionResult.error:
        _showMessage('Restore failed. Please try again.');
    }

    if (mounted) setState(() => _busy = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final offeringAsync = ref.watch(removeAdsOfferingProvider);
    final entitlement = ref.watch(removeAdsEntitlementProvider);
    final service = ref.watch(lifetimePurchaseServiceProvider);
    final adsRemovedCache = ref.watch(
      adsSettingsProvider.select((state) => state.adsRemoved),
    );
    final entitled = entitlement.storeSynced
        ? entitlement.entitled
        : adsRemovedCache;

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
        error: (error, _) => RemoveAdsErrorBody(
          message: 'Could not load the lifetime product.\n$error',
          onRetry: () => ref.invalidate(removeAdsOfferingProvider),
        ),
        data: (offering) => _buildContent(
          offering: offering,
          entitled: entitled,
          service: service,
        ),
      ),
    );
  }

  Widget _buildContent({
    required RemoveAdsOffering offering,
    required bool entitled,
    required LifetimePurchaseService service,
  }) {
    final productAvailable = offering.lifetime != null;
    final price = offering.priceLabel;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RemoveAdsHeader(entitled: entitled),
        ),
        const SizedBox(height: 20),
        const RemoveAdsBenefitsList(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: entitled
              ? const RemoveAdsOutlineButton(
                  label: 'Lifetime unlocked',
                  onPressed: null,
                )
              : RemoveAdsPrimaryButton(
                  label: productAvailable
                      ? 'Unlock forever · $price'
                      : 'Lifetime product unavailable',
                  onPressed: !productAvailable || !service.isReady || _busy
                      ? null
                      : () => _purchase(offering),
                  busy: _busy,
                ),
        ),
        const SizedBox(height: 14),
        Center(
          child: RemoveAdsFooterLink(
            label: 'Restore purchases',
            color: AppColors.textPrimary,
            onTap: _busy || !service.isConfigured ? null : _restore,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: RemoveAdsStoreAccountNotice(),
        ),
        if (!service.isReady) ...[
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: RemoveAdsConfigHint(),
          ),
        ],
      ],
    );
  }
}
