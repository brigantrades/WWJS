import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/app.dart';
import 'package:wwjs/data/prayers.dart';
import 'package:wwjs/models/prayer_content.dart';
import 'package:wwjs/screens/today_screen.dart';
import 'package:wwjs/services/content_repository.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';

void main() {
  testWidgets('onboarding starts at Day 1', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();

    await tester.pumpWidget(WWJSApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('A quiet daily rhythm with Jesus'), findsOneWidget);
    expect(find.text('Make it yours'), findsOneWidget);
    expect(find.text('Your journey starts here'), findsOneWidget);
    final beginButton = find.widgetWithText(FilledButton, 'Begin Day 1');
    await tester.ensureVisible(beginButton);
    await tester.tap(beginButton);
    await tester.pumpAndSettle();

    expect(find.text('Come and Rest'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
  });

  testWidgets('home arrows browse every published prayer day', (tester) async {
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
    await tester.tap(find.byTooltip('Next day'));
    await tester.pump();
    expect(find.text('Day 2'), findsOneWidget);
  });
}

class _ReversedContentRepository implements ContentRepository {
  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async =>
      prayers.reversed.toList();
}
