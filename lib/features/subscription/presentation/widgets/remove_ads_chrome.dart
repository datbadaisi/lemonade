import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';

class RemoveAdsHeader extends StatelessWidget {
  const RemoveAdsHeader({super.key, required this.entitled});

  final bool entitled;

  @override
  Widget build(BuildContext context) {
    final text = entitled
        ? 'Thank you for supporting Lemonade! Your support keeps the app '
            'growing — we truly appreciate it. Cancel anytime in Manage '
            'subscription.'
        : 'Support Lemonade. Every glass of lemonade helps keep the app '
            'independent and built with care. Cancel anytime in Manage '
            'subscription.';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class RemoveAdsBenefitsList extends StatelessWidget {
  const RemoveAdsBenefitsList({super.key});

  static const _items = [
    'Remove all ads',
    'A smoother, content-first experience',
    'Support long-term app development',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in _items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Icon(
                    Icons.circle,
                    size: 5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class RemoveAdsFooterLink extends StatelessWidget {
  const RemoveAdsFooterLink({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = enabled ? color : color.withValues(alpha: 0.45);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class RemoveAdsPrimaryButton extends StatelessWidget {
  const RemoveAdsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.busy,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Secondary full-width outline (Manage subscription, "You're on this plan").
class RemoveAdsOutlineButton extends StatelessWidget {
  const RemoveAdsOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Subscription follows the store account, not Lemmy login.
class RemoveAdsStoreAccountNotice extends StatelessWidget {
  const RemoveAdsStoreAccountNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Linked to your Google Play account — not your Lemmy login. '
      'On another phone, sign in with the same Play account and tap Restore purchases.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class RemoveAdsConfigHint extends StatelessWidget {
  const RemoveAdsConfigHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'RevenueCat API key is not set for this build. Paste your public key '
      '(goog_… / appl_…) into RevenueCatConfig or pass it with '
      '--dart-define when building.\n\n'
      'Play catalog: one subscription remove_ads with base plans monthly '
      '(\$1.99) and yearly (\$9.99), plus one-time remove_ads_lifetime '
      '(\$19.99). Full store ids: remove_ads:monthly / remove_ads:yearly. '
      'Attach all to entitlement remove_ads; Offering packages: monthly + '
      'annual + lifetime.',
      style: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class RemoveAdsErrorBody extends StatelessWidget {
  const RemoveAdsErrorBody({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.action,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leading chevron for the remove-ads AppBar.
class RemoveAdsBackButton extends StatelessWidget {
  const RemoveAdsBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        MingCuteIcons.mgc_left_line,
        color: AppColors.textPrimary,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
