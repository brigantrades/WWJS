import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/screens/app_shell.dart';
import 'package:wwjs/screens/commitment_screen.dart';
import 'package:wwjs/screens/onboarding_screen.dart';
import 'package:wwjs/screens/player_screen.dart';
import 'package:wwjs/screens/prayer_list_screen.dart';
import 'package:wwjs/screens/settings_screen.dart';
import 'package:wwjs/screens/today_screen.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';
import 'package:wwjs/widgets/dawn_artwork.dart';
import 'package:wwjs/widgets/brand_logo.dart';
import 'package:wwjs/widgets/prayer_card.dart';

void main() {
  Future<AppController> createController() async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    return controller;
  }

  void useView(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void expectFullHeightBackground(WidgetTester tester, Key key) {
    final rect = tester.getRect(find.byKey(key));
    expect(rect.width, 1024);
    expect(rect.height, greaterThanOrEqualTo(1300));
  }

  testWidgets('iPad keeps primary content centered at a readable width', (
    tester,
  ) async {
    useView(tester, const Size(1024, 1366));
    final controller = await createController();
    controller.favorites = {1};

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: TodayScreen(controller: controller),
      ),
    );
    final todayPanel = tester.widget<Container>(
      find.byKey(const Key('dark-today-prayer-panel')),
    );
    expect(todayPanel.margin, const EdgeInsets.symmetric(horizontal: 132));
    expect(find.byKey(const Key('tablet-today-background')), findsOneWidget);
    expectFullHeightBackground(tester, const Key('tablet-today-background'));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: PrayerListScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(TabBar)).width, 760);
    expect(tester.getRect(find.byType(PrayerCard)).width, 760);
    expect(find.byKey(const Key('tablet-prayers-background')), findsOneWidget);
    expectFullHeightBackground(tester, const Key('tablet-prayers-background'));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: SettingsScreen(controller: controller),
      ),
    );
    await tester.pump();
    final settingsCard = tester.getRect(
      find.byKey(const Key('dark-settings-prayer-card')),
    );
    expect(settingsCard.left, 132);
    expect(settingsCard.width, 760);
    expect(find.byKey(const Key('tablet-settings-background')), findsOneWidget);
    expectFullHeightBackground(tester, const Key('tablet-settings-background'));
  });

  testWidgets(
    'every supporting iPad page keeps artwork behind bounded content',
    (tester) async {
      useView(tester, const Size(1024, 1366));
      final controller = await createController();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: OnboardingScreen(controller: controller),
        ),
      );
      expect(
        find.byKey(const Key('tablet-onboarding-background')),
        findsOneWidget,
      );
      expectFullHeightBackground(
        tester,
        const Key('tablet-onboarding-background'),
      );
      expect(tester.getRect(find.byType(BrandLogo)).left, 132);
      expect(
        tester
            .widget<Container>(find.byKey(const Key('onboarding-setup-panel')))
            .margin,
        const EdgeInsets.symmetric(horizontal: 132),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: CommitmentScreen(controller: controller),
        ),
      );
      expect(
        find.byKey(const Key('tablet-commitment-background')),
        findsOneWidget,
      );
      expectFullHeightBackground(
        tester,
        const Key('tablet-commitment-background'),
      );
      expect(
        tester
            .widget<Container>(find.byKey(const Key('commitment-panel')))
            .margin,
        const EdgeInsets.symmetric(horizontal: 132),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: PlayerScreen(
            controller: controller,
            prayer: controller.todaysPrayer,
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('tablet-player-background')), findsOneWidget);
      expectFullHeightBackground(tester, const Key('tablet-player-background'));
      expect(tester.getRect(find.byType(Slider)).width, 760);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('iPad shell centers navigation without covering page artwork', (
    tester,
  ) async {
    useView(tester, const Size(1024, 1366));
    final controller = await createController();
    await controller.finishOnboarding();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: AppShell(controller: controller),
      ),
    );
    await tester.pump();

    expect(
      tester.getRect(find.byKey(const Key('tablet-navigation-content'))).width,
      760,
    );
    expect(find.byKey(const Key('tablet-today-background')), findsOneWidget);
  });

  testWidgets('iPad landscape keeps the player artwork and controls fitting', (
    tester,
  ) async {
    useView(tester, const Size(1366, 1024));
    final controller = await createController();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: PlayerScreen(
          controller: controller,
          prayer: controller.todaysPrayer,
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const Key('tablet-player-hero-space'))).height,
      closeTo(430.08, .01),
    );
    expect(
      tester.getRect(find.byKey(const Key('tablet-player-background'))),
      const Rect.fromLTWH(0, 0, 1366, 1024),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('light iPad pages also use full-height theme artwork', (
    tester,
  ) async {
    useView(tester, const Size(1024, 1366));
    final controller = await createController();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: TodayScreen(controller: controller),
      ),
    );
    expectFullHeightBackground(tester, const Key('tablet-today-background'));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: SettingsScreen(controller: controller),
      ),
    );
    await tester.pump();
    expectFullHeightBackground(tester, const Key('tablet-settings-background'));
  });

  testWidgets('phone content retains its existing edge insets', (tester) async {
    useView(tester, const Size(426, 924));
    final controller = await createController();
    controller.favorites = {1};

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: TodayScreen(controller: controller),
      ),
    );
    final todayPanel = tester.widget<Container>(
      find.byKey(const Key('dark-today-prayer-panel')),
    );
    expect(todayPanel.margin, const EdgeInsets.symmetric(horizontal: 15));
    expect(find.byKey(const Key('tablet-today-background')), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: PrayerListScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(TabBar)).width, 386);
    expect(tester.getRect(find.byType(PrayerCard)).width, 386);
    expect(find.byKey(const Key('tablet-prayers-background')), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: SettingsScreen(controller: controller),
      ),
    );
    await tester.pump();
    final settingsCard = tester.getRect(
      find.byKey(const Key('dark-settings-prayer-card')),
    );
    expect(settingsCard.left, 23);
    expect(settingsCard.width, 380);
    expect(find.byKey(const Key('tablet-settings-background')), findsNothing);
  });

  testWidgets('phone journey heroes retain their existing heights', (
    tester,
  ) async {
    useView(tester, const Size(426, 924));
    final controller = await createController();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: OnboardingScreen(controller: controller),
      ),
    );
    expect(tester.widget<DawnArtwork>(find.byType(DawnArtwork)).height, 350);
    expect(find.byKey(const Key('tablet-onboarding-background')), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: CommitmentScreen(controller: controller),
      ),
    );
    expect(tester.widget<DawnArtwork>(find.byType(DawnArtwork)).height, 340);
    expect(find.byKey(const Key('tablet-commitment-background')), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: PlayerScreen(
          controller: controller,
          prayer: controller.todaysPrayer,
        ),
      ),
    );
    expect(tester.widget<DawnArtwork>(find.byType(DawnArtwork)).height, 350);
    expect(find.byKey(const Key('tablet-player-background')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('phone player fits the complete scripture without scrolling', (
    tester,
  ) async {
    useView(tester, const Size(402, 874));
    final controller = await createController();
    await controller.setCurrentDay(7);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: PlayerScreen(
          controller: controller,
          prayer: controller.todaysPrayer,
        ),
      ),
    );
    await tester.pump();

    final viewport = tester.getRect(
      find.byKey(const Key('player-scripture-viewport')),
    );
    final scripture = tester.getRect(
      find.text(controller.todaysPrayer.scriptureText),
    );
    expect(scripture.top, greaterThanOrEqualTo(viewport.top));
    expect(scripture.bottom, lessThanOrEqualTo(viewport.bottom));
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
