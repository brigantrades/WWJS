import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/screens/prayer_list_screen.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';

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
    final indicator = tabBar.indicator! as BoxDecoration;

    expect(indicator.color, AppColors.sage);
    expect(tabBar.labelColor, Colors.white);
    expect(tabBar.labelStyle?.fontWeight, FontWeight.w600);
    expect(tabBar.unselectedLabelStyle?.fontWeight, FontWeight.w400);
  });
}
