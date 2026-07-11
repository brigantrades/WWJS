import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../state/app_controller.dart';
import '../widgets/dawn_artwork.dart';

class CommitmentScreen extends StatefulWidget {
  const CommitmentScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen> {
  late TimeOfDay _time;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _time = widget.controller.reminderTime;
    _enabled = widget.controller.reminderEnabled;
  }

  Future<void> _chooseTime() async {
    final chosen = await showTimePicker(context: context, initialTime: _time);
    if (chosen != null) setState(() => _time = chosen);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success = await widget.controller.configureReminder(
      enabled: _enabled,
      time: _time,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) Navigator.of(context).pop();
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
                  const DawnArtwork(height: 340, compact: true),
                  Positioned(
                    left: 8,
                    right: 8,
                    top: MediaQuery.paddingOf(context).top + 4,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            'Daily Commitment',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppColors.forest),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -42),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
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
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.sage,
                          foregroundColor: Colors.white,
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                          ),
                        ),
                      ),
                      Text(
                        'Make time for prayer each day. Choose a time when you can give Jesus two quiet, undistracted minutes.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 26),
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _chooseTime,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 22,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Choose Your Time',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: AppColors.sage),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    formatTime(_time),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: SwitchListTile.adaptive(
                          title: const Text('Daily Reminder'),
                          value: _enabled,
                          onChanged: (value) =>
                              setState(() => _enabled = value),
                        ),
                      ),
                      if (widget.controller.notificationPermissionDenied) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Notifications are disabled for WWJS. You can allow them in your phone’s system settings and try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.calendar_month_outlined),
                        label: const Text('Make This My Time'),
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
