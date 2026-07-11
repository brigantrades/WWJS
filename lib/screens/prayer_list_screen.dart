import 'package:flutter/material.dart';

import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/prayer_card.dart';
import 'player_screen.dart';

class PrayerListScreen extends StatelessWidget {
  const PrayerListScreen({
    super.key,
    required this.controller,
    required this.favoritesOnly,
  });

  final AppController controller;
  final bool favoritesOnly;

  void _open(BuildContext context, PrayerContent prayer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(controller: controller, prayer: prayer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = favoritesOnly
        ? controller.unlockedPrayers
              .where((prayer) => controller.favorites.contains(prayer.day))
              .toList()
        : controller.unlockedPrayers.reversed.toList();
    final title = favoritesOnly ? 'Favorites' : 'Previous Prayers';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      favoritesOnly
                          ? Icons.favorite_border
                          : Icons.menu_book_outlined,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      favoritesOnly
                          ? 'A quiet place for prayers you return to'
                          : 'Your prayers will appear here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      favoritesOnly
                          ? 'Tap the heart on any unlocked prayer to keep it here.'
                          : 'Day 1 is ready now. New prayers become available one local day at a time.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final prayer = entries[index];
                return PrayerCard(
                  prayer: prayer,
                  isFavorite: controller.favorites.contains(prayer.day),
                  isCompleted: controller.completed.contains(prayer.day),
                  onTap: () => _open(context, prayer),
                  onFavorite: () => controller.toggleFavorite(prayer.day),
                );
              },
            ),
    );
  }
}
