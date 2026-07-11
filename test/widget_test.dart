import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/app.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';

void main() {
  testWidgets('onboarding starts at Day 1', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();

    await tester.pumpWidget(WWJSApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Begin with Day 1'), findsWidgets);
    final beginButton = find.widgetWithText(FilledButton, 'Begin with Day 1');
    await tester.ensureVisible(beginButton);
    await tester.tap(beginButton);
    await tester.pumpAndSettle();

    expect(find.text('Come and Rest'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
  });
}
