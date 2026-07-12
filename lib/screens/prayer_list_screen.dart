import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/prayer_card.dart';
import 'player_screen.dart';

class PrayerListScreen extends StatelessWidget {
  const PrayerListScreen({
    super.key,
    required this.controller,
    required this.favoritesOnly,
    this.onExplorePrayers,
    this.onHome,
  });

  final AppController controller;
  final bool favoritesOnly;
  final VoidCallback? onExplorePrayers;
  final VoidCallback? onHome;

  void _open(BuildContext context, PrayerContent prayer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          controller: controller,
          prayer: prayer,
          onHome: onHome,
        ),
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
    return Scaffold(
      body: _GardenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 108,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Center(
                    child: Text(
                      favoritesOnly ? 'Favorites' : 'Prayers',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? _EmptyPrayerList(
                        favoritesOnly: favoritesOnly,
                        onExplorePrayers: onExplorePrayers,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final prayer = entries[index];
                          return PrayerCard(
                            prayer: prayer,
                            isFavorite: controller.favorites.contains(
                              prayer.day,
                            ),
                            isCompleted: controller.completed.contains(
                              prayer.day,
                            ),
                            onTap: () => _open(context, prayer),
                            onFavorite: () =>
                                controller.toggleFavorite(prayer.day),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GardenBackground extends StatelessWidget {
  const _GardenBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkBackground : const Color(0xFFFCF9F2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Image.asset(
              'assets/images/prayer-header-watercolor.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              color: dark
                  ? AppColors.darkBackground.withValues(alpha: .34)
                  : null,
              colorBlendMode: dark ? BlendMode.multiply : null,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _EmptyPrayerList extends StatelessWidget {
  const _EmptyPrayerList({
    required this.favoritesOnly,
    required this.onExplorePrayers,
  });

  final bool favoritesOnly;
  final VoidCallback? onExplorePrayers;

  @override
  Widget build(BuildContext context) {
    if (favoritesOnly) {
      return _FavoriteEmptyState(onExplorePrayers: onExplorePrayers);
    }

    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dawnPeach.withValues(alpha: .12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dawnPeach.withValues(alpha: .25),
                    blurRadius: 38,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Your prayers will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Day 1 is ready now. New prayers become available one local day at a time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: .72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteEmptyState extends StatelessWidget {
  const _FavoriteEmptyState({required this.onExplorePrayers});

  final VoidCallback? onExplorePrayers;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 40),
      child: Column(
        children: [
          const _SavedPrayerIllustration(),
          const SizedBox(height: 24),
          Text(
            'Your saved prayers\nwill live here',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 32, height: 1.12),
          ),
          const SizedBox(height: 16),
          Container(width: 70, height: 1, color: const Color(0xFFD4B462)),
          const SizedBox(height: 22),
          Text(
            'Tap a heart whenever\nyou want to return.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: onSurface.withValues(alpha: .72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onExplorePrayers,
            label: const Text('Browse prayers'),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPrayerIllustration extends StatelessWidget {
  const _SavedPrayerIllustration();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final paper = dark ? AppColors.darkSurface : AppColors.warmWhite;
    final shadow = AppColors.forest.withValues(alpha: dark ? .28 : .16);

    Widget card({required double angle, required Offset offset}) {
      return Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 164,
            height: 190,
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: .65)),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          card(angle: -.12, offset: const Offset(-12, 8)),
          card(angle: .09, offset: const Offset(14, 9)),
          Container(
            width: 166,
            height: 192,
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: .9)),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          AppColors.sage.withValues(alpha: .28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.favorite, size: 62, color: AppColors.sage),
                ),
                Positioned(
                  top: 0,
                  right: 24,
                  child: ClipPath(
                    clipper: _BookmarkClipper(),
                    child: Container(
                      width: 34,
                      height: 64,
                      color: AppColors.forest,
                    ),
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

class _BookmarkClipper extends CustomClipper<Path> {
  const _BookmarkClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width / 2, size.height - 13)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
