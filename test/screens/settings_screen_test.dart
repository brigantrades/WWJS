import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/screens/settings_screen.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';

void main() {
  testWidgets('light settings uses the dedicated illustrated design', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.setThemeMode(ThemeMode.light);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: SettingsScreen(controller: controller),
      ),
    );

    expect(find.byKey(const Key('light-settings-screen')), findsOneWidget);
    expect(find.byKey(const Key('light-settings-header')), findsOneWidget);
    expect(find.byKey(const Key('dark-settings-screen')), findsNothing);
    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.byType(DropdownButton<ThemeMode>), findsNothing);
  });

  testWidgets('dark settings retains its separate design', (tester) async {
    tester.view.physicalSize = const Size(426, 924);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.setCurrentDay(2);
    await controller.setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: SettingsScreen(controller: controller),
      ),
    );

    expect(find.byKey(const Key('dark-settings-screen')), findsOneWidget);
    expect(find.byKey(const Key('dark-settings-header')), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/prayer-header-dark.png')),
      findsOneWidget,
    );
    final darkHeaderImage = tester.widget<Image>(
      find.image(const AssetImage('assets/images/prayer-header-dark.png')),
    );
    expect(darkHeaderImage.alignment, const Alignment(0, -.55));
    expect(find.byKey(const Key('dark-settings-prayer-card')), findsOneWidget);
    expect(
      find.byKey(const Key('dark-settings-appearance-card')),
      findsOneWidget,
    );
    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.byType(DropdownButton<ThemeMode>), findsNothing);
    expect(find.byKey(const Key('light-settings-screen')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const Key('dark-settings-scroll-view')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Rate the App'), findsOneWidget);
    expect(find.text('Send Feedback'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app information keeps the installation id discreet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.setThemeMode(ThemeMode.light);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: SettingsScreen(
          controller: controller,
          packageInfoLoader: () async => PackageInfo(
            appName: 'WWJS',
            packageName: 'com.wwjs.wwjs',
            version: '1.0.16',
            buildNumber: '18',
          ),
          referenceNumberProvider: () => '123e4567-e89b-12d3-a456-426614174000',
        ),
      ),
    );

    await tester.tap(find.text('App version'));
    await tester.pumpAndSettle();

    expect(find.text('App information'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('1.0.16 (18)'), findsOneWidget);
    expect(find.text('Reference number'), findsOneWidget);
    expect(find.text('123e4567-e89b-12d3-a456-426614174000'), findsOneWidget);
    expect(find.textContaining('UUID'), findsNothing);
    expect(find.byKey(const Key('copy-reference-number')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
