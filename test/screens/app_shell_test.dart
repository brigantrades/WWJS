import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/screens/app_shell.dart';
import 'package:wwjs/services/app_update_service.dart';
import 'package:wwjs/services/local_activity_store.dart';
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
    expect(find.byKey(const Key('upgrade-prompt')), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(updateService.checkCount, 2);
  });

  testWidgets(
    'update opens the store once and does not prompt again on resume',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController(reminders: NoopReminderScheduler());
      await controller.initialize();
      await controller.finishOnboarding();
      final updateService = _AvailableUpdateService();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: AppShell(controller: controller, updateService: updateService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Journey Continues'), findsOneWidget);

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();

      expect(updateService.openedBuildCount, 1);
      expect(updateService.openCount, 1);
      expect(find.text('Your Journey Continues'), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(updateService.checkCount, 2);
      expect(find.text('Your Journey Continues'), findsNothing);
    },
  );

  testWidgets('keeps an upgrade action available on every main tab', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(reminders: NoopReminderScheduler());
    await controller.initialize();
    await controller.finishOnboarding(startingDay: 7);
    await controller.markCompleted(7);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: AppShell(controller: controller),
      ),
    );

    expect(find.byKey(const Key('upgrade-prompt')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pump();
    expect(find.byKey(const Key('upgrade-prompt')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    expect(find.byKey(const Key('upgrade-prompt')), findsOneWidget);
    final activity = await controller.loadLocalActivityHistory();
    expect(activity.screenViewTotal(LocalActivityScreen.today), 1);
    expect(activity.screenViewTotal(LocalActivityScreen.prayers), 1);
    expect(activity.screenViewTotal(LocalActivityScreen.settings), 1);

    await tester.tap(find.byKey(const Key('upgrade-prompt')));
    await tester.pumpAndSettle();
    expect(find.text('Continue Your\nWalk with Jesus'), findsOneWidget);
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

class _AvailableUpdateService extends AppUpdateService {
  _AvailableUpdateService()
    : super(repository: const _NullUpdateRepository(), platform: 'android');

  static final _update = AppUpdate(
    platform: 'android',
    latestBuild: 16,
    storeUrl: Uri.parse(
      'https://play.google.com/store/apps/details?id=com.wwjs.wwjs',
    ),
  );

  int checkCount = 0;
  int openedBuildCount = 0;
  int openCount = 0;
  bool _opened = false;

  @override
  Future<AppUpdate?> availableUpdate() async {
    checkCount += 1;
    return _opened ? null : _update;
  }

  @override
  Future<void> markUpdateOpened(AppUpdate update) async {
    openedBuildCount += 1;
    _opened = true;
  }

  @override
  Future<bool> openUpdate(AppUpdate update) async {
    openCount += 1;
    return true;
  }
}

class _NullUpdateRepository implements AppUpdateRepository {
  const _NullUpdateRepository();

  @override
  Future<AppUpdate?> fetchForPlatform(String platform) async => null;
}
