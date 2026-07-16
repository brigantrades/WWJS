import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../state/app_controller.dart';
import '../widgets/dawn_artwork.dart';
import '../widgets/tablet_artwork_background.dart';

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final semantic = AppSemanticColors.of(context);
    final isTablet = AppLayout.isTablet(context);
    final panelInset = AppLayout.horizontalInset(context, phoneInset: 14);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: TabletArtworkFrame(
          background: TabletArtworkBackground(
            key: const Key('tablet-commitment-background'),
            assetName: dark
                ? 'assets/images/dawn-path-dark.png'
                : 'assets/images/dawn-path.png',
            preservePortraitComposition: true,
            portraitOffsetY: -260,
            bottomScrimOpacity: .42,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    if (isTablet)
                      SizedBox(
                        width: double.infinity,
                        height: (MediaQuery.sizeOf(context).height * .46).clamp(
                          580.0,
                          640.0,
                        ),
                      )
                    else
                      const DawnArtwork(height: 340, compact: true),
                    Positioned(
                      left: isTablet ? panelInset : 8,
                      right: isTablet ? panelInset : 8,
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
                                  ?.copyWith(
                                    color: isTablet && dark
                                        ? semantic.primaryText
                                        : AppColors.forest,
                                  ),
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
                    key: const Key('commitment-panel'),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: panelInset),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
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
      ),
    );
  }
}
