import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/brand_logo.dart';
import '../widgets/brand_wordmark.dart';
import '../widgets/dawn_artwork.dart';
import '../widgets/subscription_modal.dart';
import 'player_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _openPrayer(BuildContext context, PrayerContent prayer) async {
    if (prayer.day > 7 && !controller.hasActiveSubscription) {
      await showSubscriptionModal(
        context,
        subscriptionService: controller.subscriptionService,
      );
      if (!context.mounted || !controller.hasActiveSubscription) return;
    }
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
    final completed = controller.completed.contains(prayer.day);
    final resume =
        (controller.positions[prayer.day] ?? Duration.zero) > Duration.zero;

    if (Theme.of(context).brightness == Brightness.dark) {
      return _buildDarkScreen(
        context,
        prayer: prayer,
        favorite: favorite,
        completed: completed,
        resume: resume,
      );
    }

    return _buildLightScreen(
      context,
      prayer: prayer,
      favorite: favorite,
      completed: completed,
      resume: resume,
    );
  }

  Widget _buildLightScreen(
    BuildContext context, {
    required PrayerContent prayer,
    required bool favorite,
    required bool completed,
    required bool resume,
  }) {
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
                              Text(
                                'Day ${prayer.day}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.sage,
                                      fontFamily: 'serif',
                                    ),
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
                              FilledButton(
                                onPressed: () => _openPrayer(context, prayer),
                                child: Text(
                                  completed
                                      ? 'Pray Again'
                                      : resume
                                      ? 'Resume Prayer'
                                      : 'Begin Prayer',
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

  Widget _buildDarkScreen(
    BuildContext context, {
    required PrayerContent prayer,
    required bool favorite,
    required bool completed,
    required bool resume,
  }) {
    final semantic = AppSemanticColors.of(context);
    final wordmarkSecondary = Color.lerp(
      semantic.scriptureText,
      semantic.primaryText,
      .42,
    )!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: semantic.navigationBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: semantic.appBackground,
        body: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artworkHeight = (constraints.maxHeight * .52).clamp(
                360.0,
                420.0,
              );
              final backgroundHeight = artworkHeight * 1.86;

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: semantic.appBackground),
                  ),
                  Positioned(
                    top: -artworkHeight * .30,
                    left: 0,
                    right: 0,
                    height: backgroundHeight,
                    child: ExcludeSemantics(
                      child: Image.asset(
                        'assets/images/dawn-path-dark.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              semantic.appBackground.withValues(alpha: .18),
                              semantic.appBackground.withValues(alpha: .82),
                              semantic.appBackground,
                            ],
                            stops: const [.34, .57, .79, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: artworkHeight),
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: _DarkPrayerPanel(
                            prayer: prayer,
                            favorite: favorite,
                            completed: completed,
                            resume: resume,
                            onFavorite: () =>
                                controller.toggleFavorite(prayer.day),
                            onOpenPrayer: () => _openPrayer(context, prayer),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 26,
                    left: 28,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const BrandLogo(size: 64, semanticLabel: 'WWJS logo'),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -16,
                                bottom: -16,
                                left: -16,
                                right: -12,
                                child: IgnorePointer(
                                  child: ShaderMask(
                                    key: const Key('dark-today-wordmark-scrim'),
                                    blendMode: BlendMode.dstIn,
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.white,
                                            Colors.white,
                                            Colors.transparent,
                                          ],
                                          stops: [0, .24, .76, 1],
                                        ).createShader(bounds),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: LinearGradient(
                                          colors: [
                                            semantic.navigationBackground
                                                .withValues(alpha: .72),
                                            semantic.navigationBackground
                                                .withValues(alpha: .52),
                                            semantic.navigationBackground
                                                .withValues(alpha: .16),
                                            Colors.transparent,
                                          ],
                                          stops: const [0, .48, .82, 1],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: semantic.navigationBackground
                                                .withValues(alpha: .32),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              BrandWordmark(
                                color: semantic.primaryText,
                                secondaryColor: wordmarkSecondary,
                                showTagline: false,
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
      ),
    );
  }
}

class _DarkPrayerPanel extends StatelessWidget {
  const _DarkPrayerPanel({
    required this.prayer,
    required this.favorite,
    required this.completed,
    required this.resume,
    required this.onFavorite,
    required this.onOpenPrayer,
  });

  final PrayerContent prayer;
  final bool favorite;
  final bool completed;
  final bool resume;
  final VoidCallback onFavorite;
  final VoidCallback onOpenPrayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);

    return Container(
      key: const Key('dark-today-prayer-panel'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
      decoration: BoxDecoration(
        color: const Color(0xF211211C),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: semantic.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: semantic.shadow,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Day ${prayer.day}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: semantic.scriptureText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'PRAY WITH JESUS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: semantic.secondaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 10),
              Semantics(
                header: true,
                child: Text(
                  prayer.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: semantic.primaryText,
                    fontSize: 39,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                prayer.scriptureReference,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: semantic.scriptureText,
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  indent: 42,
                  endIndent: 42,
                  color: semantic.subtleBorder,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 23,
                    color: semantic.secondaryText,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'About 2 minutes',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: semantic.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                key: const Key('dark-today-prayer-button'),
                onPressed: onOpenPrayer,
                style: OutlinedButton.styleFrom(
                  foregroundColor: semantic.interactiveForeground,
                  backgroundColor: semantic.controlSurface,
                  minimumSize: const Size.fromHeight(64),
                  side: BorderSide(color: semantic.selectionOutline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 18),
                ),
                child: Text(
                  completed
                      ? 'Pray Again'
                      : resume
                      ? 'Resume Prayer'
                      : 'Begin Prayer',
                ),
              ),
            ],
          ),
          Positioned(
            top: -12,
            right: -12,
            child: IconButton(
              tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
              onPressed: onFavorite,
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              style: IconButton.styleFrom(
                foregroundColor: semantic.interactiveForeground,
                minimumSize: const Size.square(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
