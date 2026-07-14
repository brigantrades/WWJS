import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/prayer_card.dart';
import 'player_screen.dart';

enum _PrayerFilter { favorites, completed }

const _prayerHeaderHeight = 160.0;
const _prayerHeaderTitleOffset = Offset(0, 18);
const _lightPrayerHeaderHeight = 168.0;
const _lightPrayerHeaderTitleOffset = Offset(0, 18);

class PrayerListScreen extends StatelessWidget {
  const PrayerListScreen({super.key, required this.controller, this.onHome});

  final AppController controller;
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

  List<PrayerContent> _entriesFor(_PrayerFilter filter) {
    final prayers = controller.unlockedPrayers.reversed;
    return switch (filter) {
      _PrayerFilter.favorites =>
        prayers
            .where((prayer) => controller.favorites.contains(prayer.day))
            .toList(),
      _PrayerFilter.completed =>
        prayers
            .where((prayer) => controller.completed.contains(prayer.day))
            .toList(),
    };
  }

  Widget _buildPrayerList(
    BuildContext context,
    _PrayerFilter filter, {
    required VoidCallback onExplorePrayers,
  }) {
    final entries = _entriesFor(filter);
    if (entries.isEmpty) {
      return _EmptyPrayerList(
        filter: filter,
        onExplorePrayers: onExplorePrayers,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final usesDarkArtwork = theme.brightness == Brightness.dark;
    final hasLargeText = MediaQuery.textScalerOf(context).scale(14) > 20;

    Tab filterTab(String label) {
      if (!hasLargeText) return Tab(text: label);
      return Tab(
        height: 56,
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      );
    }

    return DefaultTabController(
      length: _PrayerFilter.values.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: semantic.appBackground,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: usesDarkArtwork
              ? _prayerHeaderHeight
              : _lightPrayerHeaderHeight,
          centerTitle: true,
          title: Transform.translate(
            offset: usesDarkArtwork
                ? _prayerHeaderTitleOffset
                : _lightPrayerHeaderTitleOffset,
            child: Text(
              'Prayers',
              style: theme.textTheme.displayMedium?.copyWith(
                color: semantic.interactiveForeground,
              ),
            ),
          ),
          flexibleSpace: ExcludeSemantics(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (usesDarkArtwork)
                  Image.asset(
                    'assets/images/prayer-header-dark.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -.55),
                    filterQuality: FilterQuality.high,
                  )
                else
                  ClipRect(
                    key: const Key('light-prayer-header-artwork-clip'),
                    child: Transform.translate(
                      key: const Key('light-prayer-header-artwork-position'),
                      offset: const Offset(0, 14),
                      child: Transform.scale(
                        scale: 1.18,
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/images/prayer-header-light.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        semantic.appBackground.withValues(
                          alpha: usesDarkArtwork ? .08 : .42,
                        ),
                        semantic.appBackground,
                      ],
                      stops: const [.58, .82, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Builder(
          builder: (tabContext) {
            void explorePrayers() => onHome?.call();

            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: usesDarkArtwork ? .03 : .18,
                        child: Image.asset(
                          'assets/images/player-paper-texture.png',
                          fit: BoxFit.cover,
                          color: usesDarkArtwork ? semantic.primaryText : null,
                          colorBlendMode: usesDarkArtwork
                              ? BlendMode.softLight
                              : null,
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: semantic.controlSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: semantic.subtleBorder),
                          ),
                          child: TabBar(
                            dividerHeight: 0,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: semantic.selectedSurface,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: semantic.selectionOutline,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: semantic.accent.withValues(alpha: .10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorPadding: const EdgeInsets.all(3),
                            labelColor: semantic.interactiveForeground,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelColor: semantic.unselectedText,
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                            tabs: [
                              filterTab('Favorites'),
                              filterTab('Completed'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            for (final filter in _PrayerFilter.values)
                              _buildPrayerList(
                                tabContext,
                                filter,
                                onExplorePrayers: explorePrayers,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyPrayerList extends StatelessWidget {
  const _EmptyPrayerList({
    required this.filter,
    required this.onExplorePrayers,
  });

  final _PrayerFilter filter;
  final VoidCallback onExplorePrayers;

  @override
  Widget build(BuildContext context) {
    return switch (filter) {
      _PrayerFilter.favorites => _FavoriteEmptyState(
        onExplorePrayers: onExplorePrayers,
      ),
      _PrayerFilter.completed => _CompletedEmptyState(
        onExplorePrayers: onExplorePrayers,
      ),
    };
  }
}

class _CompletedEmptyState extends StatelessWidget {
  const _CompletedEmptyState({required this.onExplorePrayers});

  final VoidCallback onExplorePrayers;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sage.withValues(alpha: .14),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 52,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Completed prayers\nwill appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Finish a prayer to keep a simple record of your journey.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: .72),
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onExplorePrayers,
              label: const Text('Browse prayers'),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteEmptyState extends StatelessWidget {
  const _FavoriteEmptyState({required this.onExplorePrayers});

  final VoidCallback onExplorePrayers;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
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
