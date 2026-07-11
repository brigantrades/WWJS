import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/brand_logo.dart';
import '../widgets/dawn_artwork.dart';
import 'player_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final AppController controller;

  void _openPrayer(BuildContext context, PrayerContent prayer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(controller: controller, prayer: prayer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayer = controller.todaysPrayer;
    final favorite = controller.favorites.contains(prayer.day);
    final resume =
        (controller.positions[prayer.day] ?? Duration.zero) > Duration.zero;
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const DawnArtwork(height: 420),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 18,
                    left: 24,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandLogo(size: 62, semanticLabel: 'WWJS logo'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'WWJS',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.forest,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Text('Pray with Jesus'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -48),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Day ${prayer.day}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.sage,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayer.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayer.scriptureReference,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.sage,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(indent: 42, endIndent: 42),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_rounded, size: 22),
                          SizedBox(width: 8),
                          Text('About 2 minutes'),
                        ],
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: () => _openPrayer(context, prayer),
                        icon: Icon(
                          resume
                              ? Icons.play_circle_outline
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(resume ? 'Resume Prayer' : 'Begin Prayer'),
                      ),
                      const SizedBox(height: 18),
                      IconButton.outlined(
                        tooltip: favorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () => controller.toggleFavorite(prayer.day),
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(54, 54),
                          foregroundColor: AppColors.sage,
                          side: const BorderSide(color: AppColors.sage),
                        ),
                      ),
                    ],
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
