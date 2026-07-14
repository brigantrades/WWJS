import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/screens/app_shell.dart';
import 'package:wwjs/services/app_update_service.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';

void main() {
  testWidgets('checks for updates on launch and whenever the app resumes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.finishOnboarding();
    final updateService = _CountingUpdateService();

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(controller: controller, updateService: updateService),
      ),
    );
    await tester.pump();

    expect(updateService.checkCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(updateService.checkCount, 2);
  });
}

class _CountingUpdateService extends AppUpdateService {
  _CountingUpdateService()
    : super(repository: const _NullUpdateRepository(), platform: 'android');

  int checkCount = 0;

  @override
  Future<AppUpdate?> availableUpdate() async {
    checkCount += 1;
    return null;
  }
}

class _NullUpdateRepository implements AppUpdateRepository {
  const _NullUpdateRepository();

  @override
  Future<AppUpdate?> fetchForPlatform(String platform) async => null;
}
