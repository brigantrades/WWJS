import 'package:flutter/material.dart';

import 'brand_logo.dart';

enum SubscriptionPlan { monthly, yearly }

Future<SubscriptionPlan?> showSubscriptionModal(BuildContext context) {
  return showDialog<SubscriptionPlan>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .72),
    builder: (context) => const _SubscriptionDialog(),
  );
}

class _PaywallColors {
  static const background = Color(0xFF0C3028);
  static const surface = Color(0xFF12372F);
  static const cream = Color(0xFFF5EDDE);
  static const muted = Color(0xFFB5BAAF);
  static const subtle = Color(0xFF87958B);
  static const gold = Color(0xFFD5A64E);
  static const paleGold = Color(0xFFF2C276);
  static const border = Color(0xFF66786D);
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
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = (screenSize.width - 32).clamp(0.0, 452.0).toDouble();
    final dialogHeight = (screenSize.height - 24).clamp(0.0, 900.0).toDouble();
    final billingLabel = _selectedPlan == SubscriptionPlan.yearly
        ? r'$9.99 billed yearly'
        : r'$0.99 billed monthly';

    return Dialog(
      backgroundColor: _PaywallColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: _PaywallColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: _PaywallColors.background),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 225,
              child: ExcludeSemantics(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/dawn-path.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, .42),
                      filterQuality: FilterQuality.high,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x220C3028),
                            Color(0x9910322A),
                            _PaywallColors.background,
                          ],
                          stops: [0, .55, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 452,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 76,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _PaywallColors.cream,
                                  width: 2,
                                ),
                              ),
                              child: const BrandLogo(
                                size: 62,
                                semanticLabel: 'WWJS logo',
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Semantics(
                                button: true,
                                label: 'Close paywall',
                                child: IconButton.filled(
                                  tooltip: 'Close',
                                  onPressed: () => Navigator.pop(context),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size.square(48),
                                    backgroundColor: const Color(0x806F786B),
                                    foregroundColor: _PaywallColors.cream,
                                  ),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'YOUR FIRST 7 DAYS',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _PaywallColors.paleGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.2,
                          shadows: const [
                            Shadow(
                              color: Color(0xD90A211C),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Continue Your\nWalk with Jesus',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: _PaywallColors.cream,
                              fontSize: 39,
                              height: 1.06,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You’ve made space for prayer each day.\n'
                        'Continue this quiet rhythm and receive new\n'
                        'words of guidance, comfort and hope from Jesus.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _PaywallColors.cream,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '“ Remain in me, as I also remain in you. ”',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _PaywallColors.muted,
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'John 15:4',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _PaywallColors.gold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Color(0x335F7468), height: 1),
                      const _BenefitRow(
                        icon: Icons.wb_sunny_outlined,
                        title: 'A new prayer for every day',
                        description:
                            'Begin each day with fresh guidance\nand reflection.',
                      ),
                      const _BenefitRow(
                        icon: Icons.favorite_border_rounded,
                        title: 'Keep meaningful words close',
                        description:
                            'Save your favourites and return\nto previous prayers.',
                      ),
                      const _BenefitRow(
                        icon: Icons.spa_outlined,
                        title: 'A peaceful, uninterrupted space',
                        description:
                            'Continue praying without\nadvertisements.',
                      ),
                      const SizedBox(height: 12),
                      _PlanCard(
                        title: 'Yearly',
                        price: r'$9.99 / year',
                        detail: r'Less than $0.84 per month',
                        badge: 'Best value',
                        selected: _selectedPlan == SubscriptionPlan.yearly,
                        onTap: () => setState(
                          () => _selectedPlan = SubscriptionPlan.yearly,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PlanCard(
                        title: 'Monthly',
                        price: r'$0.99 / month',
                        selected: _selectedPlan == SubscriptionPlan.monthly,
                        onTap: () => setState(
                          () => _selectedPlan = SubscriptionPlan.monthly,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        button: true,
                        label: 'Continue My Journey with selected plan',
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, _selectedPlan),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            backgroundColor: _PaywallColors.cream,
                            foregroundColor: _PaywallColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 25),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Continue My Journey'),
                                ),
                              ),
                              Icon(Icons.eco_outlined, size: 25),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$billingLabel   ·   Cancel anytime',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _PaywallColors.gold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Icon(
                        Icons.favorite_border_rounded,
                        color: _PaywallColors.subtle,
                        size: 15,
                      ),
                      _FooterLinks(
                        onRestore: () {},
                        onTerms: () {},
                        onPrivacy: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x335F7468))),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _PaywallColors.gold.withValues(alpha: .7),
              ),
            ),
            child: Icon(icon, color: _PaywallColors.gold, size: 25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _PaywallColors.cream,
                    fontFamily: 'serif',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _PaywallColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    this.detail,
    this.badge,
  });

  final String title;
  final String price;
  final String? detail;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $price${badge == null ? '' : ', $badge'}',
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? _PaywallColors.surface.withValues(alpha: .72)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? _PaywallColors.gold
                  : _PaywallColors.border.withValues(alpha: .35),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected
                    ? _PaywallColors.paleGold
                    : _PaywallColors.border,
                size: 27,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _PaywallColors.cream,
                        fontFamily: 'serif',
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _PaywallColors.cream,
                        height: 1.15,
                      ),
                    ),
                    if (detail != null)
                      Text(
                        detail!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _PaywallColors.gold,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B5B2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _PaywallColors.gold.withValues(alpha: .55),
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _PaywallColors.cream,
                      fontFamily: 'serif',
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({
    required this.onRestore,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onRestore;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      foregroundColor: _PaywallColors.subtle,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      textStyle: const TextStyle(fontSize: 11),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          onPressed: onRestore,
          style: style,
          child: const Text('Restore purchases'),
        ),
        const Text('·', style: TextStyle(color: _PaywallColors.subtle)),
        TextButton(
          onPressed: onTerms,
          style: style,
          child: const Text('Terms'),
        ),
        const Text('·', style: TextStyle(color: _PaywallColors.subtle)),
        TextButton(
          onPressed: onPrivacy,
          style: style,
          child: const Text('Privacy'),
        ),
      ],
    );
  }
}
