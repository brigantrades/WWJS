import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../state/app_controller.dart';
import '../widgets/brand_logo.dart';
import '../widgets/brand_wordmark.dart';
import '../widgets/dawn_artwork.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _setReminder = false;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 30);
  bool _busy = false;
  bool _showScrollCue = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollCue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollCue());
  }

  void _updateScrollCue() {
    if (!mounted || !_scrollController.hasClients) return;
    final shouldShow =
        _scrollController.position.maxScrollExtent > 24 &&
        _scrollController.offset < 24;
    if (shouldShow != _showScrollCue) {
      setState(() => _showScrollCue = shouldShow);
    }
  }

  Future<void> _scrollForMore() async {
    final position = _scrollController.position;
    await _scrollController.animateTo(
      (position.pixels + 220).clamp(0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollCue)
      ..dispose();
    super.dispose();
  }

  Future<void> _begin() async {
    setState(() => _busy = true);
    await widget.controller.finishOnboarding(startingDay: 1);
    if (_setReminder) {
      await widget.controller.configureReminder(enabled: true, time: _time);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final semantic = AppSemanticColors.of(context);
    final wordmarkSecondary = Color.lerp(
      semantic.scriptureText,
      semantic.primaryText,
      .42,
    )!;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Stack(
                    children: [
                      const DawnArtwork(height: 350, useDarkArtwork: true),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: MediaQuery.paddingOf(context).top + 18,
                        child: Row(
                          children: [
                            const BrandLogo(
                              size: 62,
                              semanticLabel: 'WWJS logo',
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (dark)
                                    Positioned(
                                      top: -16,
                                      bottom: -16,
                                      left: -16,
                                      right: -12,
                                      child: IgnorePointer(
                                        child: ShaderMask(
                                          key: const Key(
                                            'dark-onboarding-wordmark-scrim',
                                          ),
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
                                              borderRadius:
                                                  BorderRadius.circular(18),
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
                                                  color: semantic
                                                      .navigationBackground
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
                                    color: dark
                                        ? semantic.primaryText
                                        : AppColors.forest,
                                    secondaryColor: dark
                                        ? wordmarkSecondary
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    key: const ValueKey('welcome-setup-panel-position'),
                    offset: const Offset(0, -50),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'A quiet daily rhythm with Jesus',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'What Would Jesus Say? (WWJS) guides you through Scripture, a short reflection, and a two-minute prayer—one day at a time.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 22),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Make it yours',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Choose your appearance and daily reminder before you begin.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Appearance',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<ThemeMode>(
                              key: const ValueKey('welcome-theme-toggle'),
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_rounded),
                                  label: Text('Light'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_rounded),
                                  label: Text('Dark'),
                                ),
                              ],
                              selected: {
                                widget.controller.themeMode == ThemeMode.dark ||
                                        (widget.controller.themeMode ==
                                                ThemeMode.system &&
                                            Theme.of(context).brightness ==
                                                Brightness.dark)
                                    ? ThemeMode.dark
                                    : ThemeMode.light,
                              },
                              onSelectionChanged: (selection) {
                                widget.controller.setThemeMode(selection.first);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Remind me each day'),
                            subtitle: Text(
                              _setReminder ? formatTime(_time) : 'Off',
                            ),
                            value: _setReminder,
                            activeThumbColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            activeTrackColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            inactiveThumbColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            inactiveTrackColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            trackOutlineColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.outline,
                            ),
                            onChanged: (value) =>
                                setState(() => _setReminder = value),
                          ),
                          if (_setReminder)
                            OutlinedButton.icon(
                              onPressed: () async {
                                final chosen = await showTimePicker(
                                  context: context,
                                  initialTime: _time,
                                );
                                if (chosen != null) {
                                  setState(() => _time = chosen);
                                }
                              },
                              icon: const Icon(Icons.schedule_rounded),
                              label: const Text('Choose your time'),
                            ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Your journey starts here',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Begin with Day 1. You can change these choices anytime in Settings.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: _busy ? null : _begin,
                            child: _busy
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Begin Day 1'),
                                    ],
                                  )
                                : const Text('Begin Day 1'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No account. No streaks. Your activity stays on this device.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showScrollCue)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom + 12,
                child: Center(
                  child: FilledButton.tonalIcon(
                    key: const ValueKey('welcome-scroll-cue'),
                    onPressed: _scrollForMore,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    label: const Text('Scroll to continue'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
