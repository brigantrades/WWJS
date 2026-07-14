import 'package:flutter/material.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    required this.color,
    this.secondaryColor,
    this.showTagline = true,
  });

  final Color color;
  final Color? secondaryColor;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: showTagline
          ? 'WWJS. What Would Jesus Say? Pray with Jesus.'
          : 'WWJS. What Would Jesus Say?',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WWJS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'What Would Jesus Say?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: secondaryColor ?? color,
                height: 1.15,
              ),
            ),
            if (showTagline)
              Text(
                'Pray with Jesus',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: secondaryColor ?? color),
              ),
          ],
        ),
      ),
    );
  }
}
