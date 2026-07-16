import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/app.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/data/prayers.dart';
import 'package:wwjs/models/prayer_content.dart';
import 'package:wwjs/screens/today_screen.dart';
import 'package:wwjs/services/content_repository.dart';
import 'package:wwjs/services/local_activity_store.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';
import 'package:wwjs/widgets/brand_wordmark.dart';

void main() {
  testWidgets('records app foreground time and returns during onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 7, 16, 8);
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      now: () => now,
    );
    await controller.initialize();
    await tester.pumpWidget(WWJSApp(controller: controller));

    now = DateTime(2026, 7, 16, 8, 2);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    var history = await controller.loadLocalActivityHistory();
    expect(history.total(LocalActivityMetric.foregroundSeconds), 120);

    now = DateTime(2026, 7, 16, 9);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    history = await controller.loadLocalActivityHistory();
    expect(history.total(LocalActivityMetric.appResume), 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await controller.reset();
  });

  testWidgets('onboarding starts at Day 1', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();

    await tester.pumpWidget(WWJSApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('A quiet daily rhythm with Jesus'), findsOneWidget);
    expect(find.text('What Would Jesus Say?'), findsOneWidget);
    expect(find.text('Pray with Jesus'), findsOneWidget);
    expect(find.text('Make it yours'), findsOneWidget);
    expect(find.text('Your journey starts here'), findsOneWidget);
    expect(
      find.text(
        'No account or public streaks. Your prayer progress stays on this device.',
      ),
      findsOneWidget,
    );
    final setupPanelPosition = tester.widget<Transform>(
      find.byKey(const ValueKey('welcome-setup-panel-position')),
    );
    expect(setupPanelPosition.transform.getTranslation().y, -50);
    expect(find.byKey(const ValueKey('welcome-scroll-cue')), findsOneWidget);
    final beginButton = find.widgetWithText(FilledButton, 'Begin Day 1');
    await tester.ensureVisible(beginButton);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    await tester.tap(beginButton);
    await tester.pumpAndSettle();

    expect(find.text('Come and Rest'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('What Would Jesus Say?'), findsOneWidget);
    expect(find.text('Pray with Jesus'), findsNothing);
    expect(find.text('PRAY WITH JESUS'), findsOneWidget);
  });

  testWidgets('onboarding artwork follows the selected theme', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();

    await tester.pumpWidget(WWJSApp(controller: controller));
    await tester.pumpAndSettle();

    expect(
      find.image(const AssetImage('assets/images/dawn-path.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/dawn-path-dark.png')),
      findsNothing,
    );

    final themeToggle = find.byKey(const ValueKey('welcome-theme-toggle'));
    await tester.ensureVisible(themeToggle);
    await tester.tap(
      find.descendant(of: themeToggle, matching: find.text('Dark')),
    );
    await tester.pumpAndSettle();

    expect(
      find.image(const AssetImage('assets/images/dawn-path-dark.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/dawn-path.png')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('dark-onboarding-wordmark-scrim')),
      findsOneWidget,
    );
    final wordmark = tester.widget<BrandWordmark>(find.byType(BrandWordmark));
    expect(wordmark.color, AppSemanticColors.dark.primaryText);
    expect(
      wordmark.secondaryColor,
      Color.lerp(
        AppSemanticColors.dark.scriptureText,
        AppSemanticColors.dark.primaryText,
        .42,
      ),
    );
  });

  testWidgets('home shows today without day navigation arrows', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      contentRepository: _ReversedContentRepository(),
    );
    await controller.initialize();
    await controller.finishOnboarding();

    await tester.pumpWidget(
      MaterialApp(home: TodayScreen(controller: controller)),
    );

    expect(find.text('Day 1'), findsOneWidget);
    expect(find.byTooltip('Previous day'), findsNothing);
    expect(find.byTooltip('Next day'), findsNothing);
    expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  testWidgets('begin prayer action has no playback icon', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.finishOnboarding();

    await tester.pumpWidget(
      MaterialApp(home: TodayScreen(controller: controller)),
    );

    expect(find.widgetWithText(FilledButton, 'Begin Prayer'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byIcon(Icons.play_circle_outline), findsNothing);
  });

  testWidgets('home offers a completed prayer again', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.finishOnboarding();
    await controller.markCompleted(1);

    await tester.pumpWidget(
      MaterialApp(home: TodayScreen(controller: controller)),
    );

    expect(find.text('Pray Again'), findsOneWidget);
  });

  testWidgets('dark home matches the immersive prayer treatment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(426, 840);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.finishOnboarding();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: TodayScreen(controller: controller),
      ),
    );

    expect(
      find.image(const AssetImage('assets/images/dawn-path-dark.png')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('dark-today-prayer-panel')), findsOneWidget);
    expect(find.byKey(const Key('dark-today-prayer-button')), findsOneWidget);
    expect(find.byKey(const Key('dark-today-wordmark-scrim')), findsOneWidget);
    final wordmark = tester.widget<BrandWordmark>(find.byType(BrandWordmark));
    expect(
      wordmark.secondaryColor,
      Color.lerp(
        AppSemanticColors.dark.scriptureText,
        AppSemanticColors.dark.primaryText,
        .42,
      ),
    );
    expect(find.widgetWithText(OutlinedButton, 'Begin Prayer'), findsOneWidget);
    expect(find.text('PRAY WITH JESUS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ReversedContentRepository implements ContentRepository {
  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async =>
      prayers.reversed.toList();
}
