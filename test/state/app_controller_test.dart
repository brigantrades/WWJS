import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/state/app_controller.dart';

void main() {
  test('restores favorite, completion, and playback position', () async {
    SharedPreferences.setMockInitialValues({});
    final first = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 11),
    );
    await first.initialize();
    await first.finishOnboarding();
    await first.toggleFavorite(1);
    await first.markCompleted(1);
    await first.savePosition(1, const Duration(seconds: 37));

    final restored = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 11),
    );
    await restored.initialize();

    expect(restored.onboardingComplete, isTrue);
    expect(restored.favorites, contains(1));
    expect(restored.completed, contains(1));
    expect(restored.positions[1], const Duration(seconds: 37));
  });

  test('starts and continues from a chosen prayer day', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 11),
    );
    await controller.initialize();
    await controller.finishOnboarding(startingDay: 3);

    expect(controller.highestUnlockedDay, 3);
    expect(controller.todaysPrayer.day, 3);

    await controller.setCurrentDay(2);
    expect(controller.highestUnlockedDay, 2);
    expect(controller.todaysPrayer.day, 2);

    final restored = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 12),
    );
    await restored.initialize();
    expect(restored.highestUnlockedDay, 3);
  });
}
