import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/brand_logo.dart';
import '../widgets/brand_wordmark.dart';
import '../widgets/dawn_artwork.dart';
import '../widgets/subscription_modal.dart';
import 'player_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late int _selectedIndex;

  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    final orderedPrayers = [...controller.prayers]
      ..sort((first, second) => first.day.compareTo(second.day));
    _selectedIndex = orderedPrayers.indexWhere(
      (prayer) => prayer.day == controller.todaysPrayer.day,
    );
  }

  void _showDay(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _openPrayer(BuildContext context, PrayerContent prayer) async {
    if (prayer.day > 7) {
      final plan = await showSubscriptionModal(context);
      if (plan == null || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription purchasing will be connected next.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(controller: controller, prayer: prayer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Temporary testing navigation: allow every published prayer day,
    // regardless of the normal daily unlock schedule.
    final availablePrayers = [...controller.prayers]
      ..sort((first, second) => first.day.compareTo(second.day));
    _selectedIndex = _selectedIndex.clamp(0, availablePrayers.length - 1);
    final prayer = availablePrayers[_selectedIndex];
    final hasPrevious = _selectedIndex > 0;
    final hasNext = _selectedIndex < availablePrayers.length - 1;
    final favorite = controller.favorites.contains(prayer.day);
    final resume =
        (controller.positions[prayer.day] ?? Duration.zero) > Duration.zero;
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artworkHeight = (constraints.maxHeight * .48).clamp(
              300.0,
              420.0,
            );
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      DawnArtwork(height: artworkHeight),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 18,
                        left: 24,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BrandLogo(
                              size: 62,
                              semanticLabel: 'WWJS logo',
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: const BrandWordmark(
                                color: AppColors.forest,
                                showTagline: false,
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
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: 'Previous day',
                                    onPressed: hasPrevious
                                        ? () => _showDay(_selectedIndex - 1)
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                    ),
                                    color: AppColors.sage,
                                  ),
                                  SizedBox(
                                    width: 92,
                                    child: Text(
                                      'Day ${prayer.day}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: AppColors.sage,
                                            fontFamily: 'serif',
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Next day',
                                    onPressed: hasNext
                                        ? () => _showDay(_selectedIndex + 1)
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                    color: AppColors.sage,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'PRAY WITH JESUS',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.6,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                prayer.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                prayer.scriptureReference,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
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
                                label: Text(
                                  resume ? 'Resume Prayer' : 'Begin Prayer',
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: -12,
                            right: -12,
                            child: IconButton(
                              tooltip: favorite
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                              onPressed: () =>
                                  controller.toggleFavorite(prayer.day),
                              icon: Icon(
                                favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              style: IconButton.styleFrom(
                                foregroundColor: AppColors.sage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
