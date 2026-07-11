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
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
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
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(16),
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
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.sage,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16),
                        const SizedBox(width: 4),
                        const Text('About 2 minutes'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: onFavorite,
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
