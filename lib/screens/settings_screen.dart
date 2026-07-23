import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_layout.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../services/app_update_service.dart';
import '../state/app_controller.dart';
import '../widgets/tablet_artwork_background.dart';
import 'commitment_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    this.updateService,
    this.packageInfoLoader,
    this.referenceNumberProvider,
  });

  final AppController controller;
  final AppUpdateService? updateService;
  final Future<PackageInfo> Function()? packageInfoLoader;
  final String? Function()? referenceNumberProvider;

  bool get _showCurrentPrayerDaySetting => false;

  Future<void> _showAppInformation(BuildContext context) async {
    PackageInfo? packageInfo;
    try {
      packageInfo = await (packageInfoLoader ?? PackageInfo.fromPlatform)();
    } catch (_) {
      // The dialog still provides the installation reference when available.
    }
    if (!context.mounted) return;

    String? referenceNumber;
    try {
      referenceNumber =
          (referenceNumberProvider ??
                  () => Supabase.instance.client.auth.currentUser?.id)()
              ?.trim();
    } catch (_) {
      // Supabase may still be establishing the anonymous session.
    }
    final hasReference = referenceNumber?.isNotEmpty == true;
    final version = packageInfo == null
        ? 'Not available'
        : packageInfo.buildNumber.isEmpty
        ? packageInfo.version
        : '${packageInfo.version} (${packageInfo.buildNumber})';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('App information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version',
                style: Theme.of(dialogContext).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(version, key: const Key('app-version-value')),
              const SizedBox(height: 24),
              Text(
                'Reference number',
                style: Theme.of(dialogContext).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Use this number if support asks for it.',
                style: Theme.of(
                  dialogContext,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        hasReference ? referenceNumber! : 'Not available yet',
                        key: const Key('reference-number-value'),
                        style: Theme.of(dialogContext).textTheme.bodySmall
                            ?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                    if (hasReference)
                      IconButton(
                        key: const Key('copy-reference-number'),
                        tooltip: 'Copy reference number',
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: referenceNumber!),
                          );
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Reference number copied.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
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
                          if (_showCurrentPrayerDaySetting) ...[
                            const _LightSettingsDivider(),
                            _LightSettingsRow(
                              icon: Icons.calendar_month_outlined,
                              title: 'Current prayer day',
                              value: 'Day ${controller.highestUnlockedDay}',
                              onTap: () => _chooseCurrentDay(context),
                            ),
                          ],
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
                                path: 'praywithjesusapp@gmail.com',
                                queryParameters: const {
                                  'subject': 'WWJS Feedback',
                                },
                              ),
                            ),
                          ),
                          const _LightSettingsDivider(indented: true),
                          _LightSettingsRow(
                            icon: Icons.apps_outlined,
                            title: 'App version',
                            compact: true,
                            onTap: () => _showAppInformation(context),
                          ),
                        ],
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
                          if (_showCurrentPrayerDaySetting) ...[
                            const _DarkSettingsDivider(),
                            _DarkSettingsRow(
                              icon: Icons.calendar_month_outlined,
                              title: 'Current prayer day',
                              value: 'Day ${controller.highestUnlockedDay}',
                              onTap: () => _chooseCurrentDay(context),
                            ),
                          ],
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
                                path: 'praywithjesusapp@gmail.com',
                                queryParameters: const {
                                  'subject': 'WWJS Feedback',
                                },
                              ),
                            ),
                          ),
                          const _DarkSettingsDivider(indented: true),
                          _DarkSettingsRow(
                            icon: Icons.apps_outlined,
                            title: 'App version',
                            compact: true,
                            onTap: () => _showAppInformation(context),
                          ),
                        ],
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
