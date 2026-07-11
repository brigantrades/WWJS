import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../state/app_controller.dart';
import '../widgets/brand_logo.dart';
import '../widgets/dawn_artwork.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _setReminder = false;
  int _startingDay = 1;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 30);
  bool _busy = false;

  Future<void> _begin() async {
    setState(() => _busy = true);
    await widget.controller.finishOnboarding(startingDay: _startingDay);
    if (_setReminder) {
      await widget.controller.configureReminder(enabled: true, time: _time);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const DawnArtwork(height: 390),
                  Positioned(
                    left: 24,
                    right: 24,
                    top: MediaQuery.paddingOf(context).top + 18,
                    child: Row(
                      children: [
                        const BrandLogo(size: 62, semanticLabel: 'WWJS logo'),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'WWJS',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.forest,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Text('Pray with Jesus'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -42),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
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
                    children: [
                      Text(
                        _startingDay == 1
                            ? 'Begin with Day 1'
                            : 'Continue with Day $_startingDay',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'One short prayer each day. Scripture, a gentle reflection, and two quiet minutes with Jesus.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        initialValue: _startingDay,
                        decoration: const InputDecoration(
                          labelText: 'Returning to WWJS?',
                          helperText: 'Choose the prayer day to continue from.',
                          prefixIcon: Icon(Icons.history_rounded),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (
                            var day = 1;
                            day <= widget.controller.prayerCount;
                            day++
                          )
                            DropdownMenuItem(
                              value: day,
                              child: Text('Day $day'),
                            ),
                        ],
                        onChanged: (day) {
                          if (day != null) setState(() => _startingDay = day);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Remind me each day'),
                        subtitle: Text(formatTime(_time)),
                        value: _setReminder,
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
                            if (chosen != null) setState(() => _time = chosen);
                          },
                          icon: const Icon(Icons.schedule_rounded),
                          label: const Text('Choose your time'),
                        ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _busy ? null : _begin,
                        icon: _busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          _startingDay == 1
                              ? 'Begin with Day 1'
                              : 'Continue with Day $_startingDay',
                        ),
                      ),
                      const SizedBox(height: 12),
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
      ),
    );
  }
}
