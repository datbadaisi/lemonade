import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/subscription/data/subscription_providers.dart';
import 'package:bluerum/features/subscription/data/subscription_service.dart';

class LifetimeSupportScreen extends ConsumerStatefulWidget {
  const LifetimeSupportScreen({super.key});

  @override
  ConsumerState<LifetimeSupportScreen> createState() =>
      _LifetimeSupportScreenState();
}

class _LifetimeSupportScreenState extends ConsumerState<LifetimeSupportScreen> {
  bool _busy = false;

  Future<void> _runPurchase({required bool restore}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final service = ref.read(lifetimePurchaseServiceProvider);
    final result = restore
        ? await service.restorePurchases()
        : await service.purchaseLifetime();
    if (!mounted) return;
    if (result != LifetimePurchaseActionResult.started) {
      final message = switch (result) {
        LifetimePurchaseActionResult.notAvailable =>
          'Purchases are not available on this device.',
        LifetimePurchaseActionResult.notConfigured =>
          'The lifetime product is currently unavailable.',
        LifetimePurchaseActionResult.error =>
          restore
              ? 'Could not restore purchases. Please try again.'
              : 'Could not start the purchase. Please try again.',
        LifetimePurchaseActionResult.started => '',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(lifetimePurchaseBootstrapProvider);
    final offering = ref.watch(lifetimePurchaseOfferingProvider);
    final owned = ref.watch(lifetimeEntitlementProvider).lifetimeOwned;
    final service = ref.watch(lifetimePurchaseServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lifetime supporter'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: offering.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load product: $error')),
        data: (product) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: owned
                  ? const Image(
                      image: AssetImage(
                        'assets/stickers/lifetime_lemonade.png',
                      ),
                      width: 112,
                      height: 112,
                      semanticLabel: 'Lifetime supporter',
                    )
                  : const Icon(Icons.local_cafe_outlined, size: 72),
            ),
            const SizedBox(height: 24),
            Text(
              owned
                  ? 'Thanks for supporting Lemonade!'
                  : 'Support Lemonade for life',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              owned
                  ? 'Your lifetime supporter sticker is now shown in the feed header.'
                  : 'A one-time purchase unlocks the lifetime supporter sticker in the feed header.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            if (owned)
              const OutlinedButton(
                onPressed: null,
                child: Text('Lifetime unlocked'),
              )
            else
              FilledButton(
                onPressed: product.lifetime == null || !service.isReady || _busy
                    ? null
                    : () => _runPurchase(restore: false),
                child: Text(
                  product.lifetime == null
                      ? 'Lifetime product unavailable'
                      : 'Unlock for life · ${product.priceLabel}',
                ),
              ),
            TextButton(
              onPressed: _busy || !service.isConfigured
                  ? null
                  : () => _runPurchase(restore: true),
              child: const Text('Restore purchases'),
            ),
          ],
        ),
      ),
    );
  }
}
