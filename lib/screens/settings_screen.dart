import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../state/app_controller.dart';
import 'commitment_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _chooseCurrentDay(BuildContext context) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose your current day'),
        children: [
          for (var day = 1; day <= controller.prayerCount; day++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, day),
              child: Row(
                children: [
                  Expanded(child: Text('Day $day')),
                  if (day == controller.highestUnlockedDay)
                    const Icon(Icons.check_rounded),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected != null) await controller.setCurrentDay(selected);
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset local progress?'),
        content: const Text(
          'This removes completed prayers, favorites, reminders, and saved progress from this device. You’ll return to Day 1 unless you choose a different starting day during setup. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _sectionLabel(context, 'PRAYER'),
          Card(
            child: Column(
              children: [
                ListTile(
                  minTileHeight: 66,
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: const Text('Daily reminder'),
                  subtitle: Text(
                    controller.reminderEnabled
                        ? formatTime(controller.reminderTime)
                        : 'Off',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommitmentScreen(controller: controller),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  minTileHeight: 66,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Current prayer day'),
                  subtitle: Text('Day ${controller.highestUnlockedDay}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _chooseCurrentDay(context),
                ),
              ],
            ),
          ),
          _sectionLabel(context, 'APPEARANCE'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    underline: const SizedBox.shrink(),
                    onChanged: (mode) {
                      if (mode != null) controller.setThemeMode(mode);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.text_fields_rounded),
                          SizedBox(width: 16),
                          Text('App text size'),
                        ],
                      ),
                      Slider(
                        value: controller.textScale,
                        min: .9,
                        max: 1.3,
                        divisions: 4,
                        label: '${(controller.textScale * 100).round()}%',
                        onChanged: controller.setTextScale,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _sectionLabel(context, 'ABOUT'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.lock_outline_rounded),
                  title: Text('Privacy'),
                  subtitle: Text(
                    'Your progress, favorites, and preferences remain on this device. WWJS has no account or remote database.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset local progress'),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.sage,
          letterSpacing: 1.4,
          fontSize: 12,
        ),
      ),
    );
  }
}
