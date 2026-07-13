import 'package:flutter/material.dart';

import 'brand_logo.dart';

enum SubscriptionPlan { monthly, yearly }

Future<SubscriptionPlan?> showSubscriptionModal(BuildContext context) {
  return showDialog<SubscriptionPlan>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .58),
    builder: (context) => const _SubscriptionDialog(),
  );
}

class _SubscriptionDialog extends StatefulWidget {
  const _SubscriptionDialog();

  @override
  State<_SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<_SubscriptionDialog> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedLabel = _selectedPlan == SubscriptionPlan.yearly
        ? 'Begin Yearly'
        : 'Begin Monthly';

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const BrandLogo(size: 52, semanticLabel: 'WWJS logo'),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your Journey Continues',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'You’ve begun a beautiful daily rhythm. Continue with a new guided prayer each day.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Text(
                '“Give, and it will be given to you.”',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Luke 6:38',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PlanCard(
                      title: 'Monthly',
                      price: r'$0.99',
                      selected: _selectedPlan == SubscriptionPlan.monthly,
                      onTap: () => setState(
                        () => _selectedPlan = SubscriptionPlan.monthly,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlanCard(
                      title: 'Yearly',
                      price: r'$9.99',
                      badge: 'Best value',
                      selected: _selectedPlan == SubscriptionPlan.yearly,
                      onTap: () => setState(
                        () => _selectedPlan = SubscriptionPlan.yearly,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              const _BenefitRow(
                icon: Icons.wb_sunny_outlined,
                text: 'A new guided prayer each day',
              ),
              const SizedBox(height: 10),
              const _BenefitRow(
                icon: Icons.volunteer_activism_outlined,
                text: 'Supports new prayers and keeps WWJS ad-free',
              ),
              const SizedBox(height: 10),
              const _BenefitRow(
                icon: Icons.favorite_border_rounded,
                text: 'Favorites and previous prayers',
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => Navigator.pop(context, _selectedPlan),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(selectedLabel),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Not now'),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $price, cancel anytime${badge == null ? '' : ', $badge'}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 190,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: .55)
                : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 20,
                        color: selected ? colors.primary : colors.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(title),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Cancel anytime',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 22, color: colors.primary),
        const SizedBox(width: 14),
        Expanded(child: Text(text)),
      ],
    );
  }
}
