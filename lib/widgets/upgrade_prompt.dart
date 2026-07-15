import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class UpgradePrompt extends StatelessWidget {
  const UpgradePrompt({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);

    return Material(
      color: semantic.elevatedSurface,
      child: InkWell(
        key: const Key('upgrade-prompt'),
        onTap: onPressed,
        child: Semantics(
          button: true,
          excludeSemantics: true,
          label: 'Upgrade to continue after Day 7',
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: semantic.subtleBorder)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  color: semantic.accent,
                  semanticLabel: 'Upgrade',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Upgrade to continue beyond Day 7',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: semantic.interactiveForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: semantic.interactiveForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
