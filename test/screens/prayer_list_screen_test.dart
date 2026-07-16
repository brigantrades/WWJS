import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/screens/prayer_list_screen.dart';
import 'package:wwjs/services/local_activity_store.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';
import 'package:wwjs/widgets/prayer_card.dart';

void main() {
  testWidgets('dark prayer filters clearly distinguish the selected tab', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: PrayerListScreen(controller: controller),
      ),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final indicator = tabBar.indicator! as BoxDecoration;
    final semantic = AppSemanticColors.dark;

    expect(appBar.toolbarHeight, 160);
    expect(indicator.color, semantic.selectedSurface);
    expect(indicator.border, Border.all(color: semantic.selectionOutline));
    expect(tabBar.labelColor, semantic.interactiveForeground);
    expect(tabBar.unselectedLabelColor, semantic.unselectedText);
    expect(tabBar.labelStyle?.fontWeight, FontWeight.w600);
    expect(tabBar.unselectedLabelStyle?.fontWeight, FontWeight.w400);
  });

  testWidgets('light prayer screen keeps the approved artwork and colors', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: PrayerListScreen(controller: controller),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/prayer-header-light.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/player-paper-texture.png',
      ),
      findsOneWidget,
    );
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final artworkPosition = tester.widget<Transform>(
      find.byKey(const Key('light-prayer-header-artwork-position')),
    );
    expect(
      find.byKey(const Key('light-prayer-header-artwork-clip')),
      findsOneWidget,
    );
    expect(tabBar.labelColor, AppColors.forest);
    expect((tabBar.indicator! as BoxDecoration).color, AppColors.warmWhite);
    expect(appBar.toolbarHeight, 168);
    expect(artworkPosition.transform.getTranslation().y, 14);
  });

  testWidgets('theme switching preserves layout across phone sizes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    controller.favorites = {1};
    controller.completed = {1};

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final size in const [Size(320, 568), Size(430, 932)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: PrayerListScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      final lightTabRect = tester.getRect(find.byType(TabBar));
      final lightCardRect = tester.getRect(find.byType(PrayerCard));

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: PrayerListScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final darkTabRect = tester.getRect(find.byType(TabBar));
      final darkCardRect = tester.getRect(find.byType(PrayerCard));
      expect(darkTabRect.size, lightTabRect.size);
      expect(darkCardRect.size, lightCardRect.size);
      expect(darkTabRect.top - lightTabRect.top, -8);
      expect(darkCardRect.top - lightCardRect.top, -8);
    }
  });

  testWidgets('dark prayer card supports large text on a narrow phone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    controller.favorites = {1};
    controller.completed = {1};
    final semantics = tester.ensureSemantics();

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          );
        },
        home: PrayerListScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrayerCard), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(PrayerCard),
        matching: find.textContaining('Completed', findRichText: true),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'Day 1, completed')), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('opening a prayer records only its numeric day locally', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    controller.favorites = {1};

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: PrayerListScreen(controller: controller),
      ),
    );
    await tester.tap(find.byType(PrayerCard));
    await tester.pump();

    final history = await controller.loadLocalActivityHistory();
    expect(
      history.prayerTotal(LocalActivityMetric.prayerOpened, prayerDay: 1),
      1,
    );
  });
}
