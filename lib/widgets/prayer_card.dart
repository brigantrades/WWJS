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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppColors.forest.withValues(alpha: .12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Semantics(
                label: isCompleted
                    ? 'Day ${prayer.day}, completed'
                    : 'Day ${prayer.day}',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 62,
                      height: 66,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '${prayer.day}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.sage,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Positioned(
                        right: -5,
                        bottom: -5,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.sage,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prayer.scriptureReference,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.sage),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16),
                        const SizedBox(width: 4),
                        const Text('2 min'),
                      ],
                    ),
                  ],
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
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          color: AppColors.forest,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Play ${prayer.title}',
                      onPressed: onTap,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.sage.withValues(alpha: .18),
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
