import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wwjs/models/prayer_content.dart';
import 'package:wwjs/services/content_repository.dart';
import 'package:wwjs/services/notification_service.dart';
import 'package:wwjs/services/subscription_service.dart';
import 'package:wwjs/state/app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('keeps Day 7 current after free access is completed', () async {
    SharedPreferences.setMockInitialValues({});
    const contentRepository = _TenDayContentRepository();
    final first = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 11),
      contentRepository: contentRepository,
    );
    await first.initialize();
    await first.finishOnboarding(startingDay: 7);
    await first.markCompleted(7);

    final restored = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 14),
      contentRepository: contentRepository,
    );
    await restored.initialize();

    expect(restored.highestUnlockedDay, 10);
    expect(restored.highestAccessibleDay, 7);
    expect(restored.todaysPrayer.day, 7);
    expect(restored.unlockedPrayers.last.day, 7);
  });

  test('active subscription resumes daily progression beyond Day 7', () async {
    SharedPreferences.setMockInitialValues({});
    const contentRepository = _TenDayContentRepository();
    final first = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 11),
      contentRepository: contentRepository,
    );
    await first.initialize();
    await first.finishOnboarding(startingDay: 7);
    await first.markCompleted(7);

    final restored = AppController(
      reminders: NoopReminderScheduler(),
      now: () => DateTime(2026, 7, 14),
      contentRepository: contentRepository,
      subscriptionService: _ActiveSubscriptionService(),
    );
    await restored.initialize();

    expect(restored.highestAccessibleDay, 10);
    expect(restored.todaysPrayer.day, 10);
    expect(restored.requiresSubscription, isFalse);
    restored.dispose();
  });

  test('opens with local content while fresh content loads', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = _DeferredRefreshContentRepository();
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      contentRepository: repository,
    );

    await controller.initialize();
    expect(controller.prayerCount, 1);

    repository.refresh.complete(const _TenDayContentRepository().prayers);
    await pumpEventQueue();

    expect(controller.prayerCount, 10);
    controller.dispose();
  });
}

class _ActiveSubscriptionService extends SubscriptionService {
  _ActiveSubscriptionService()
    : super(SupabaseClient('https://example.supabase.co', 'test-key'));

  @override
  bool get isEntitled => true;
}

class _TenDayContentRepository implements ContentRepository {
  const _TenDayContentRepository();

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async => prayers;

  List<PrayerContent> get prayers => [
    for (var day = 1; day <= 10; day++)
      PrayerContent(
        day: day,
        title: 'Day $day',
        scriptureReference: 'John 15:4',
        scriptureText: 'Remain in me.',
        preparationText: 'Prepare.',
        reflectionText: 'Reflect.',
        responsePrayer: 'Amen.',
        closingText: 'Go in peace.',
        audioUrl: 'day-$day.mp3',
        estimatedDuration: const Duration(minutes: 2),
        sections: const [
          PrayerSection(
            type: PrayerSectionType.scripture,
            label: 'Scripture',
            text: 'Remain in me.',
            startsAt: Duration.zero,
          ),
        ],
      ),
  ];
}

class _DeferredRefreshContentRepository
    implements RefreshableContentRepository {
  final refresh = Completer<List<PrayerContent>>();

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async {
    final prayers = const _TenDayContentRepository().prayers;
    return [prayers.first];
  }

  @override
  Future<List<PrayerContent>> refreshPublishedPrayers() => refresh.future;
}
