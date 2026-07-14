import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/prayer_content.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.prayer,
    required this.isFavorite,
    required this.isCompleted,
    required this.onTap,
    required this.onFavorite,
  });

  final PrayerContent prayer;
  final bool isFavorite;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final highContrast = MediaQuery.highContrastOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: semantic.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: semantic.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: semantic.subtleBorder,
          width: highContrast ? 1.5 : .8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  label: isCompleted
                      ? 'Day ${prayer.day}, completed'
                      : 'Day ${prayer.day}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            prayer.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: semantic.primaryText),
                          ),
                          if (isCompleted)
                            ExcludeSemantics(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: semantic.completionSurface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: highContrast
                                                ? semantic.completionForeground
                                                : semantic.subtleBorder,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: semantic.completionForeground,
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' Completed'),
                                  ],
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: semantic.scriptureText,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prayer.scriptureReference,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: semantic.scriptureText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: semantic.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '2 min',
                              style: TextStyle(color: semantic.secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                height: 96,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: onFavorite,
                      icon: AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          color: semantic.interactiveForeground,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Play ${prayer.title}',
                      onPressed: onTap,
                      style: IconButton.styleFrom(
                        backgroundColor: semantic.controlSurface,
                        foregroundColor: semantic.interactiveForeground,
                        side: BorderSide(
                          color: highContrast
                              ? semantic.subtleBorder
                              : Colors.transparent,
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
