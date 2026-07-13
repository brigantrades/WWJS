import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';
import 'package:wwjs/widgets/reminder_prompt_modal.dart';

void main() {
  test('offers a reminder only after the first completion of Day 1', () {
    expect(
      shouldOfferDailyReminder(
        completedDay: 1,
        wasAlreadyCompleted: false,
        reminderEnabled: false,
      ),
      isTrue,
    );
    expect(
      shouldOfferDailyReminder(
        completedDay: 2,
        wasAlreadyCompleted: false,
        reminderEnabled: false,
      ),
      isFalse,
    );
    expect(
      shouldOfferDailyReminder(
        completedDay: 1,
        wasAlreadyCompleted: true,
        reminderEnabled: false,
      ),
      isFalse,
    );
    expect(
      shouldOfferDailyReminder(
        completedDay: 1,
        wasAlreadyCompleted: false,
        reminderEnabled: true,
      ),
      isFalse,
    );
  });

  testWidgets('shows the WWJS reminder prompt and dismisses it', (
    tester,
  ) async {
    final controller = await _controller();
    ReminderPromptAction? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async => result = await showReminderPromptModal(
              context,
              controller: controller,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Make room for Jesus'), findsOneWidget);
    expect(find.text('Reminder time'), findsOneWidget);
    expect(find.text('7:30 AM'), findsOneWidget);
    expect(find.text('Set daily reminder'), findsOneWidget);

    await tester.ensureVisible(find.text('Not now'));
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(result, ReminderPromptAction.notNow);
    expect(controller.reminderEnabled, isFalse);
  });

  testWidgets('sets the selected daily reminder', (tester) async {
    final controller = await _controller();
    ReminderPromptAction? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async => result = await showReminderPromptModal(
              context,
              controller: controller,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Set daily reminder'));
    await tester.tap(find.text('Set daily reminder'));
    await tester.pumpAndSettle();

    expect(result, ReminderPromptAction.setReminder);
    expect(controller.reminderEnabled, isTrue);
    expect(controller.reminderTime, const TimeOfDay(hour: 7, minute: 30));
  });
}

Future<AppController> _controller() async {
  SharedPreferences.setMockInitialValues({});
  final controller = AppController(reminders: NoopReminderScheduler());
  await controller.initialize();
  return controller;
}
