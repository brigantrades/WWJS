import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../state/app_controller.dart';
import 'brand_logo.dart';

enum ReminderPromptAction { setReminder, notNow }

bool shouldOfferDailyReminder({
  required int completedDay,
  required bool wasAlreadyCompleted,
  required bool reminderEnabled,
}) => completedDay == 1 && !wasAlreadyCompleted && !reminderEnabled;

Future<ReminderPromptAction?> showReminderPromptModal(
  BuildContext context, {
  required AppController controller,
}) {
  return showDialog<ReminderPromptAction>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .54),
    builder: (_) => _ReminderPromptDialog(controller: controller),
  );
}

class _ReminderPromptDialog extends StatefulWidget {
  const _ReminderPromptDialog({required this.controller});

  final AppController controller;

  @override
  State<_ReminderPromptDialog> createState() => _ReminderPromptDialogState();
}

class _ReminderPromptDialogState extends State<_ReminderPromptDialog> {
  late TimeOfDay _time;
  bool _saving = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _time = widget.controller.reminderTime;
  }

  Future<void> _chooseTime() async {
    final chosen = await showTimePicker(context: context, initialTime: _time);
    if (chosen != null && mounted) setState(() => _time = chosen);
  }

  Future<void> _setReminder() async {
    setState(() {
      _saving = true;
      _permissionDenied = false;
    });
    final success = await widget.controller.configureReminder(
      enabled: true,
      time: _time,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, ReminderPromptAction.setReminder);
      return;
    }
    setState(() {
      _saving = false;
      _permissionDenied = true;
    });
  }

  void _dismiss() => Navigator.pop(context, ReminderPromptAction.notNow);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      backgroundColor: scheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const BrandLogo(size: 70, semanticLabel: 'WWJS logo'),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Semantics(
                        label: 'Daily reminder',
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.dawnPeach.withValues(alpha: .34),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: scheme.primary,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        tooltip: 'Not now',
                        onPressed: _saving ? null : _dismiss,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  'Make room for Jesus',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A gentle reminder can help you return for two quiet minutes with Jesus each day.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _saving ? null : _chooseTime,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.sage,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminder time',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatTime(_time),
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined),
                      ],
                    ),
                  ),
                ),
              ),
              if (_permissionDenied) ...[
                const SizedBox(height: 14),
                Text(
                  'Notifications are disabled for WWJS. Allow them in your phone’s settings, then try again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _setReminder,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.notifications_active_outlined),
                label: const Text('Set daily reminder'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _saving ? null : _dismiss,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurface,
                  minimumSize: const Size(160, 48),
                ),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
