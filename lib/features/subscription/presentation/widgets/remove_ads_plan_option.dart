import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_offering.dart';
import 'package:bluerum/features/subscription/domain/remove_ads_plan_change.dart';

/// One selectable plan row on the remove-ads paywall.
class RemoveAdsPlanOption extends StatelessWidget {
  const RemoveAdsPlanOption({
    super.key,
    required this.plan,
    required this.priceLabel,
    required this.periodLabel,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    this.isCurrent = false,
    this.onTap,
  });

  final RemoveAdsPlan plan;
  final String priceLabel;
  final String periodLabel;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final bool isCurrent;
  final VoidCallback? onTap;

  factory RemoveAdsPlanOption.fromOffering({
    Key? key,
    required RemoveAdsPlan plan,
    required RemoveAdsOffering offering,
    required RemoveAdsPlan? activePlan,
    required RemoveAdsPlan selectedPlan,
    required VoidCallback? onTap,
  }) {
    final package = offering.packageFor(plan);
    final isCurrent = activePlan == plan;
    final enabled = package != null || !offering.hasAny;
    return RemoveAdsPlanOption(
      key: key,
      plan: plan,
      priceLabel: offering.priceLabel(plan),
      periodLabel: plan.periodLabel,
      subtitle: planRowSubtitle(
        plan: plan,
        isCurrent: isCurrent,
        package: package,
      ),
      selected: selectedPlan == plan,
      enabled: enabled,
      isCurrent: isCurrent,
      onTap: enabled ? onTap : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = isCurrent
        ? 'Current'
        : plan == RemoveAdsPlan.yearly
            ? 'Best value'
            : plan == RemoveAdsPlan.lifetime
                ? 'One-time'
                : null;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(
          selected
              ? MingCuteIcons.mgc_check_circle_fill
              : MingCuteIcons.mgc_round_line,
          size: 22,
          color: selected ? AppColors.action : AppColors.textPrimary,
        ),
        title: Row(
          children: [
            Text(
              plan.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.action : AppColors.textPrimary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Text(
                badge,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCurrent
                      ? AppColors.action
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: priceLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: periodLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data-driven plan picker: yearly → monthly → lifetime.
class RemoveAdsPlanPicker extends StatelessWidget {
  const RemoveAdsPlanPicker({
    super.key,
    required this.offering,
    required this.activePlan,
    required this.selectedPlan,
    required this.onSelect,
    this.sectionTitle = 'Choose a plan',
  });

  final RemoveAdsOffering offering;
  final RemoveAdsPlan? activePlan;
  final RemoveAdsPlan selectedPlan;
  final ValueChanged<RemoveAdsPlan> onSelect;
  final String sectionTitle;

  static const _order = [
    RemoveAdsPlan.yearly,
    RemoveAdsPlan.monthly,
    RemoveAdsPlan.lifetime,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        for (final plan in _order)
          RemoveAdsPlanOption.fromOffering(
            plan: plan,
            offering: offering,
            activePlan: activePlan,
            selectedPlan: selectedPlan,
            onTap: () => onSelect(plan),
          ),
      ],
    );
  }
}

/// Lifetime-only locked row when user already owns lifetime.
class RemoveAdsLifetimeActiveRow extends StatelessWidget {
  const RemoveAdsLifetimeActiveRow({
    super.key,
    required this.offering,
  });

  final RemoveAdsOffering offering;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Your plan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        RemoveAdsPlanOption(
          plan: RemoveAdsPlan.lifetime,
          priceLabel: offering.priceLabel(RemoveAdsPlan.lifetime),
          periodLabel: RemoveAdsPlan.lifetime.periodLabel,
          subtitle: planRowSubtitle(
            plan: RemoveAdsPlan.lifetime,
            isCurrent: true,
            package: offering.lifetime,
          ),
          selected: true,
          isCurrent: true,
          enabled: false,
        ),
      ],
    );
  }
}
