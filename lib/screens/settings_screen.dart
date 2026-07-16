import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_layout.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../services/app_update_service.dart';
import '../state/app_controller.dart';
import '../widgets/subscription_modal.dart';
import '../widgets/tablet_artwork_background.dart';
import '../widgets/update_modal.dart';
import 'commitment_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    this.updateService,
  });

  final AppController controller;
  final AppUpdateService? updateService;

  Future<void> _showTestUpdateModal(BuildContext context) async {
    final action = await showUpdateModal(context);
    if (action != UpdateModalAction.update || !context.mounted) return;

    final service = updateService;
    if (service == null) return;
    try {
      final opened = await service.openConfiguredStore();
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the update page.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the update page.')),
        );
      }
    }
  }

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

  Future<void> _chooseTheme(BuildContext context) async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose a theme'),
        children: [
          for (final option in const [
            (ThemeMode.system, 'System'),
            (ThemeMode.light, 'Light'),
            (ThemeMode.dark, 'Dark'),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, option.$1),
              child: Row(
                children: [
                  Expanded(child: Text(option.$2)),
                  if (option.$1 == controller.themeMode)
                    const Icon(Icons.check_rounded),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected != null) await controller.setThemeMode(selected);
  }

  Future<void> _openUri(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // The recovery message below is sufficient for launch failures.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open that link.')),
      );
    }
  }

  Future<void> _rateApp(BuildContext context) async {
    final service = updateService;
    if (service != null) {
      try {
        if (await service.openConfiguredStore()) return;
      } catch (_) {
        // Fall through to the public WWJS website.
      }
    }
    if (context.mounted) {
      await _openUri(context, Uri.parse('https://praywithjesus.app/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return _buildDarkScreen(context);
    }
    return _buildLightScreen(context);
  }

  Widget _buildLightScreen(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final horizontalInset = AppLayout.horizontalInset(context, phoneInset: 23);
    final themeName = switch (controller.themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.warmWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('light-settings-screen'),
        backgroundColor: isTablet ? Colors.transparent : AppColors.playerIvory,
        body: Stack(
          fit: isTablet ? StackFit.expand : StackFit.loose,
          children: [
            if (isTablet)
              const Positioned.fill(
                child: TabletArtworkBackground(
                  key: Key('tablet-settings-background'),
                  assetName: 'assets/images/dawn-path.png',
                  preservePortraitComposition: true,
                  portraitOffsetY: -220,
                  bottomScrimOpacity: .52,
                ),
              )
            else
              const Positioned.fill(child: _LightSettingsBackground()),
            CustomScrollView(
              key: const Key('light-settings-scroll-view'),
              slivers: [
                SliverToBoxAdapter(
                  child: _LightSettingsHeader(showArtwork: !isTablet),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalInset,
                    0,
                    horizontalInset,
                    40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _LightSectionLabel(text: 'PRAYER', first: true),
                      _LightSettingsCard(
                        children: [
                          _LightSettingsRow(
                            icon: Icons.notifications_none_rounded,
                            title: 'Daily reminder',
                            value: controller.reminderEnabled
                                ? formatTime(controller.reminderTime)
                                : 'Off',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CommitmentScreen(controller: controller),
                              ),
                            ),
                          ),
                          const _LightSettingsDivider(),
                          _LightSettingsRow(
                            icon: Icons.calendar_month_outlined,
                            title: 'Current prayer day',
                            value: 'Day ${controller.highestUnlockedDay}',
                            onTap: () => _chooseCurrentDay(context),
                          ),
                        ],
                      ),
                      const _LightSectionLabel(text: 'APPEARANCE'),
                      _LightSettingsCard(
                        children: [
                          _LightSettingsRow(
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            trailingValue: themeName,
                            onTap: () => _chooseTheme(context),
                          ),
                          const _LightSettingsDivider(),
                          _LightTextScaleRow(controller: controller),
                        ],
                      ),
                      const _LightSectionLabel(text: 'ABOUT'),
                      _LightSettingsCard(
                        children: [
                          _LightSettingsRow(
                            icon: Icons.info_outline_rounded,
                            title: 'WWJS',
                            subtitle: 'What Would Jesus Say?\nPray with Jesus',
                            onTap: () => _openUri(
                              context,
                              Uri.parse('https://praywithjesus.app/'),
                            ),
                          ),
                          const _LightSettingsDivider(),
                          _LightSettingsRow(
                            icon: Icons.shield_outlined,
                            title: 'Privacy',
                            compact: true,
                            onTap: () => _openUri(
                              context,
                              Uri.parse(
                                'https://www.praywithjesus.app/privacy.html',
                              ),
                            ),
                          ),
                          const _LightSettingsDivider(indented: true),
                          _LightSettingsRow(
                            icon: Icons.star_rounded,
                            title: 'Rate the App',
                            compact: true,
                            onTap: () => _rateApp(context),
                          ),
                          const _LightSettingsDivider(indented: true),
                          _LightSettingsRow(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Send Feedback',
                            compact: true,
                            onTap: () => _openUri(
                              context,
                              Uri(
                                scheme: 'mailto',
                                path: 'support@praywithjesus.app',
                                queryParameters: const {
                                  'subject': 'WWJS Feedback',
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const _LightSectionLabel(text: 'TESTING'),
                      _LightSettingsCard(
                        children: [
                          _LightSettingsRow(
                            icon: Icons.payments_outlined,
                            title: 'Show paywall',
                            compact: true,
                            onTap: () => showSubscriptionModal(
                              context,
                              subscriptionService:
                                  controller.subscriptionService,
                            ),
                          ),
                          const _LightSettingsDivider(),
                          _LightSettingsRow(
                            icon: Icons.system_update_alt_rounded,
                            title: 'Show update modal',
                            compact: true,
                            onTap: () => _showTestUpdateModal(context),
                          ),
                        ],
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
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkScreen(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final isTablet = AppLayout.isTablet(context);
    final horizontalInset = AppLayout.horizontalInset(context, phoneInset: 23);
    final themeName = switch (controller.themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: semantic.navigationBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        key: const Key('dark-settings-screen'),
        backgroundColor: isTablet
            ? Colors.transparent
            : semantic.navigationBackground,
        body: Stack(
          fit: isTablet ? StackFit.expand : StackFit.loose,
          children: [
            if (isTablet)
              const Positioned.fill(
                child: TabletArtworkBackground(
                  key: Key('tablet-settings-background'),
                  assetName: 'assets/images/prayer-header-dark.png',
                  fit: BoxFit.fitWidth,
                  fadeArtworkBottom: true,
                  bottomScrimOpacity: .68,
                  textureOpacity: .18,
                ),
              )
            else
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        semantic.navigationBackground,
                        Color.lerp(
                          semantic.navigationBackground,
                          semantic.appBackground,
                          .28,
                        )!,
                        semantic.navigationBackground,
                      ],
                      stops: const [0, .56, 1],
                    ),
                  ),
                ),
              ),
            CustomScrollView(
              key: const Key('dark-settings-scroll-view'),
              slivers: [
                SliverToBoxAdapter(
                  child: _DarkSettingsHeader(showArtwork: !isTablet),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalInset,
                    0,
                    horizontalInset,
                    40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _DarkSectionLabel(text: 'PRAYER', first: true),
                      _DarkSettingsCard(
                        key: const Key('dark-settings-prayer-card'),
                        children: [
                          _DarkSettingsRow(
                            icon: Icons.notifications_none_rounded,
                            title: 'Daily reminder',
                            value: controller.reminderEnabled
                                ? formatTime(controller.reminderTime)
                                : 'Off',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CommitmentScreen(controller: controller),
                              ),
                            ),
                          ),
                          const _DarkSettingsDivider(),
                          _DarkSettingsRow(
                            icon: Icons.calendar_month_outlined,
                            title: 'Current prayer day',
                            value: 'Day ${controller.highestUnlockedDay}',
                            onTap: () => _chooseCurrentDay(context),
                          ),
                        ],
                      ),
                      const _DarkSectionLabel(text: 'APPEARANCE'),
                      _DarkSettingsCard(
                        key: const Key('dark-settings-appearance-card'),
                        children: [
                          _DarkSettingsRow(
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            trailingValue: themeName,
                            minimumHeight: 68,
                            onTap: () => _chooseTheme(context),
                          ),
                          const _DarkSettingsDivider(),
                          _DarkTextScaleRow(controller: controller),
                        ],
                      ),
                      const _DarkSectionLabel(text: 'ABOUT'),
                      _DarkSettingsCard(
                        key: const Key('dark-settings-about-card'),
                        children: [
                          _DarkSettingsRow(
                            icon: Icons.info_outline_rounded,
                            title: 'WWJS',
                            subtitle: 'What Would Jesus Say?\nPray with Jesus',
                            onTap: () => _openUri(
                              context,
                              Uri.parse('https://praywithjesus.app/'),
                            ),
                          ),
                          const _DarkSettingsDivider(),
                          _DarkSettingsRow(
                            icon: Icons.shield_outlined,
                            title: 'Privacy',
                            compact: true,
                            onTap: () => _openUri(
                              context,
                              Uri.parse(
                                'https://www.praywithjesus.app/privacy.html',
                              ),
                            ),
                          ),
                          const _DarkSettingsDivider(indented: true),
                          _DarkSettingsRow(
                            icon: Icons.star_rounded,
                            title: 'Rate the App',
                            compact: true,
                            onTap: () => _rateApp(context),
                          ),
                          const _DarkSettingsDivider(indented: true),
                          _DarkSettingsRow(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Send Feedback',
                            compact: true,
                            onTap: () => _openUri(
                              context,
                              Uri(
                                scheme: 'mailto',
                                path: 'support@praywithjesus.app',
                                queryParameters: const {
                                  'subject': 'WWJS Feedback',
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const _DarkSectionLabel(text: 'TESTING'),
                      _DarkSettingsCard(
                        children: [
                          _DarkSettingsRow(
                            icon: Icons.payments_outlined,
                            title: 'Show paywall',
                            compact: true,
                            onTap: () => showSubscriptionModal(
                              context,
                              subscriptionService:
                                  controller.subscriptionService,
                            ),
                          ),
                          const _DarkSettingsDivider(),
                          _DarkSettingsRow(
                            icon: Icons.system_update_alt_rounded,
                            title: 'Show update modal',
                            compact: true,
                            onTap: () => _showTestUpdateModal(context),
                          ),
                        ],
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
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LightSettingsBackground extends StatelessWidget {
  const _LightSettingsBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.playerIvory),
            Opacity(
              opacity: .38,
              child: Image.asset(
                'assets/images/player-paper-texture.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -.76),
                  radius: .86,
                  colors: [
                    Color(0x28F4D99B),
                    Color(0x10F4D99B),
                    Colors.transparent,
                  ],
                  stops: [0, .44, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightSettingsHeader extends StatelessWidget {
  const _LightSettingsHeader({this.showArtwork = true});

  final bool showArtwork;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('light-settings-header'),
      height: 156,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showArtwork)
            ExcludeSemantics(
              child: Image.asset(
                'assets/images/dawn-path.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.3),
                filterQuality: FilterQuality.high,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: showArtwork
                    ? const [
                        Color(0x08FFFDF8),
                        Color(0x18FFFDF8),
                        Color(0xB8F7F2E8),
                      ]
                    : [
                        AppColors.playerIvory.withValues(alpha: .12),
                        AppColors.playerIvory.withValues(alpha: .20),
                        AppColors.playerIvory.withValues(alpha: .36),
                      ],
                stops: const [0, .68, 1],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 26,
            child: Semantics(
              header: true,
              child: Text(
                'Settings',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.forest,
                  fontSize: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LightSectionLabel extends StatelessWidget {
  const _LightSectionLabel({required this.text, this.first = false});

  final String text;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, first ? 36 : 31, 8, 11),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF836E22),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.7,
        ),
      ),
    );
  }
}

class _LightSettingsCard extends StatelessWidget {
  const _LightSettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.warmWhite.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE2DCC8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6A2D).withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _LightSettingsDivider extends StatelessWidget {
  const _LightSettingsDivider({this.indented = false});

  final bool indented;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indented ? 70 : 10,
      endIndent: 10,
      color: const Color(0xFFE7E1D2),
    );
  }
}

class _LightSettingsIcon extends StatelessWidget {
  const _LightSettingsIcon({required this.icon, this.square = false});

  final IconData icon;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: square ? 44 : 46,
      height: square ? 44 : 46,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0E1),
        borderRadius: BorderRadius.circular(square ? 14 : 23),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.forest, size: 25),
    );
  }
}

class _LightSettingsRow extends StatelessWidget {
  const _LightSettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.subtitle,
    this.trailingValue,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final String? trailingValue;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;
    final minimumHeight = hasSubtitle ? 86.0 : (compact ? 52.0 : 74.0);

    return Semantics(
      button: true,
      label: [
        title,
        value,
        trailingValue,
        subtitle,
      ].whereType<String>().join(', '),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minimumHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 14,
              vertical: compact ? 7 : 12,
            ),
            child: Row(
              children: [
                _LightSettingsIcon(icon: icon),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.forest,
                          fontSize: 17,
                          height: 1.18,
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          value!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFFB08B2C),
                                fontSize: 15,
                              ),
                        ),
                      ],
                      if (hasSubtitle) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.sage,
                                fontSize: 14,
                                height: 1.28,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingValue != null) ...[
                  Text(
                    trailingValue!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFB08B2C),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 27,
                  color: Color(0xFFA7B39A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LightTextScaleRow extends StatelessWidget {
  const _LightTextScaleRow({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 90),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _LightSettingsIcon(
              icon: Icons.text_fields_rounded,
              square: true,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App text size',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.forest,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: const Color(0xFF9BAA8D),
                      inactiveTrackColor: const Color(0xFFE3E7DB),
                      thumbColor: const Color(0xFFE9EEDF),
                      overlayColor: AppColors.sage.withValues(alpha: .12),
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: const Color(0xFFB9C2AA),
                    ),
                    child: Slider(
                      value: controller.textScale,
                      min: .9,
                      max: 1.3,
                      divisions: 4,
                      label: '${(controller.textScale * 100).round()}%',
                      onChanged: controller.setTextScale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkSettingsHeader extends StatelessWidget {
  const _DarkSettingsHeader({this.showArtwork = true});

  final bool showArtwork;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return SizedBox(
      key: const Key('dark-settings-header'),
      height: 153,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showArtwork)
            ExcludeSemantics(
              child: Image.asset(
                'assets/images/prayer-header-dark.png',
                fit: BoxFit.cover,
                // Keep the cross below notches and Dynamic Island cutouts.
                alignment: const Alignment(0, -.55),
                filterQuality: FilterQuality.high,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  semantic.navigationBackground.withValues(alpha: .10),
                  semantic.navigationBackground.withValues(alpha: .04),
                  semantic.navigationBackground.withValues(alpha: .30),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 21,
            child: Semantics(
              header: true,
              child: Text(
                'Settings',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: semantic.primaryText,
                  fontSize: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkSectionLabel extends StatelessWidget {
  const _DarkSectionLabel({required this.text, this.first = false});

  final String text;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(9, first ? 36 : 25, 9, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Color.lerp(semantic.accent, semantic.primaryText, .18),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.7,
        ),
      ),
    );
  }
}

class _DarkSettingsCard extends StatelessWidget {
  const _DarkSettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semantic.elevatedSurface.withValues(alpha: .46),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: semantic.subtleBorder.withValues(alpha: .72)),
        boxShadow: [
          BoxShadow(
            color: semantic.shadow.withValues(alpha: .34),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _DarkSettingsDivider extends StatelessWidget {
  const _DarkSettingsDivider({this.indented = false});

  final bool indented;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      indent: indented ? 53 : 11,
      endIndent: 11,
      color: semantic.subtleBorder.withValues(alpha: .58),
    );
  }
}

class _DarkSettingsIcon extends StatelessWidget {
  const _DarkSettingsIcon({required this.icon, this.square = false});

  final IconData icon;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return Container(
      width: square ? 44 : 46,
      height: square ? 44 : 46,
      decoration: BoxDecoration(
        color: semantic.controlSurface.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(square ? 14 : 23),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: semantic.interactiveForeground, size: 25),
    );
  }
}

class _DarkSettingsRow extends StatelessWidget {
  const _DarkSettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.subtitle,
    this.trailingValue,
    this.compact = false,
    this.minimumHeight,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final String? trailingValue;
  final bool compact;
  final double? minimumHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final hasSubtitle = subtitle != null;
    final resolvedMinimumHeight =
        minimumHeight ?? (hasSubtitle ? 86.0 : (compact ? 52.0 : 74.0));

    return Semantics(
      button: true,
      label: [
        title,
        value,
        trailingValue,
        subtitle,
      ].whereType<String>().join(', '),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: resolvedMinimumHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 14,
              vertical: compact ? 7 : 12,
            ),
            child: Row(
              children: [
                _DarkSettingsIcon(icon: icon),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: semantic.primaryText,
                          fontSize: 17,
                          height: 1.18,
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          value!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Color.lerp(
                                  semantic.accent,
                                  semantic.primaryText,
                                  .12,
                                ),
                                fontSize: 15,
                              ),
                        ),
                      ],
                      if (hasSubtitle) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: semantic.secondaryText,
                                fontSize: 14,
                                height: 1.28,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingValue != null) ...[
                  Text(
                    trailingValue!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Color.lerp(
                        semantic.accent,
                        semantic.primaryText,
                        .12,
                      ),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 27,
                  color: semantic.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkTextScaleRow extends StatelessWidget {
  const _DarkTextScaleRow({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 90),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DarkSettingsIcon(
              icon: Icons.text_fields_rounded,
              square: true,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App text size',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: semantic.primaryText,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: semantic.interactiveForeground,
                      inactiveTrackColor: semantic.controlSurface,
                      thumbColor: const Color(0xFFAFC2A8),
                      overlayColor: semantic.interactiveForeground.withValues(
                        alpha: .12,
                      ),
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: semantic.secondaryText.withValues(
                        alpha: .42,
                      ),
                    ),
                    child: SizedBox(
                      height: 32,
                      child: Slider(
                        value: controller.textScale,
                        min: .9,
                        max: 1.3,
                        divisions: 4,
                        label: '${(controller.textScale * 100).round()}%',
                        onChanged: controller.setTextScale,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
