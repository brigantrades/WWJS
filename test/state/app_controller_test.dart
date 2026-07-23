import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wwjs/models/prayer_content.dart';
import 'package:wwjs/services/content_repository.dart';
import 'package:wwjs/services/local_activity_store.dart';
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
    expect(restored.highestUnlockedDay, 2);
  });

  test('skipped calendar days do not advance the journey', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 7, 11, 8);
    const contentRepository = _TenDayContentRepository();
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      now: () => now,
      contentRepository: contentRepository,
    );
    await controller.initialize();
    await controller.finishOnboarding();

    now = DateTime(2026, 7, 13, 8);
    await controller.recordAppBackgrounded();
    await controller.recordAppResumed();

    expect(controller.todaysPrayer.day, 1);
    expect(controller.highestUnlockedDay, 1);
    expect(controller.completed, isEmpty);

    final restored = AppController(
      reminders: NoopReminderScheduler(),
      now: () => now,
      contentRepository: contentRepository,
    );
    await restored.initialize();
    expect(restored.todaysPrayer.day, 1);
    expect(restored.completed, isEmpty);
  });

  test('starting a prayer completes it and advances the journey', () async {
    SharedPreferences.setMockInitialValues({});
    const contentRepository = _TenDayContentRepository();
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      contentRepository: contentRepository,
    );
    await controller.initialize();
    await controller.finishOnboarding();

    await controller.recordPrayerPlaybackStarted(1);

    expect(controller.completed, contains(1));
    expect(controller.highestUnlockedDay, 2);
    expect(controller.todaysPrayer.day, 2);

    await controller.recordPrayerPlaybackStarted(1);
    expect(controller.highestUnlockedDay, 2);
  });

  test(
    'migrates calendar-skipped progress to prayers actually started',
    () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'start_date': '2026-07-01',
        'highest_unlocked': 8,
        'completed': [for (var day = 1; day <= 7; day++) '$day'],
      });
      final activityStore = LocalActivityStore(now: () => DateTime(2026, 7, 8));
      await activityStore.recordPrayerPlaybackStarted(1);

      final controller = AppController(
        reminders: NoopReminderScheduler(),
        now: () => DateTime(2026, 7, 8),
        contentRepository: const _TenDayContentRepository(),
        activityStore: activityStore,
      );
      await controller.initialize();

      expect(controller.highestUnlockedDay, 2);
      expect(controller.todaysPrayer.day, 2);
      expect(controller.completed, {1});
    },
  );

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

    expect(restored.highestUnlockedDay, 8);
    expect(restored.highestAccessibleDay, 7);
    expect(restored.todaysPrayer.day, 7);
    expect(restored.unlockedPrayers.last.day, 7);
  });

  test('active subscription continues progression beyond Day 7', () async {
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

    expect(restored.highestAccessibleDay, 8);
    expect(restored.todaysPrayer.day, 8);
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

  test('records and resets local-only activity aggregates', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 7, 16, 8);
    final activityStore = LocalActivityStore(now: () => now);
    final controller = AppController(
      reminders: NoopReminderScheduler(),
      now: () => now,
      activityStore: activityStore,
    );

    await controller.initialize();
    await controller.finishOnboarding(startingDay: 2);
    await controller.recordScreenView(LocalActivityScreen.today);
    await controller.recordPrayerOpened(2, resumed: false);
    await controller.recordPrayerPlaybackStarted(2);
    await controller.markCompleted(2);
    await controller.markCompleted(2);
    await controller.toggleFavorite(2);
    await controller.toggleFavorite(2);
    await controller.configureReminder(
      enabled: true,
      time: const TimeOfDay(hour: 7, minute: 30),
    );
    await controller.configureReminder(
      enabled: false,
      time: const TimeOfDay(hour: 7, minute: 30),
    );
    now = DateTime(2026, 7, 16, 8, 2);
    await controller.recordAppBackgrounded();

    final history = await controller.loadLocalActivityHistory();
    expect(history.total(LocalActivityMetric.appLaunch), 1);
    expect(history.total(LocalActivityMetric.foregroundSeconds), 120);
    expect(history.total(LocalActivityMetric.onboardingCompleted), 1);
    expect(history.screenViewTotal(LocalActivityScreen.today), 1);
    expect(history.prayerTotal(LocalActivityMetric.prayerOpened), 1);
    expect(history.prayerTotal(LocalActivityMetric.prayerPlaybackStarted), 1);
    expect(history.prayerTotal(LocalActivityMetric.prayerCompleted), 2);
    expect(history.prayerTotal(LocalActivityMetric.prayerFirstCompleted), 1);
    expect(history.prayerTotal(LocalActivityMetric.prayerReplayCompleted), 1);
    expect(history.prayerTotal(LocalActivityMetric.favoriteAdded), 1);
    expect(history.prayerTotal(LocalActivityMetric.favoriteRemoved), 1);
    expect(history.total(LocalActivityMetric.reminderEnabled), 1);
    expect(history.total(LocalActivityMetric.reminderDisabled), 1);

    await controller.reset();

    expect((await controller.loadLocalActivityHistory()).uniqueActiveDays, 0);
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
