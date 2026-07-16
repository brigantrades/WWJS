import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/services/local_activity_store.dart';

void main() {
  test('persists privacy-minimized lifetime and daily aggregates', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalActivityStore(now: () => DateTime(2026, 7, 16));

    await store.recordAppLaunch();
    await store.recordScreenView(LocalActivityScreen.today);
    await store.recordPrayerOpened(3, resumed: true);
    await store.recordPrayerPlaybackStarted(3);
    await store.recordPrayerCompleted(3, firstCompletion: true);
    await store.recordPrayerCompleted(3, firstCompletion: false);
    await store.recordPrayerAbandoned(
      4,
      progressPercent: 61,
      listeningDuration: const Duration(seconds: 42),
    );
    await store.recordFavoriteChanged(3, added: true);
    await store.recordReminderChanged(enabled: true);
    await store.recordForegroundDuration(const Duration(minutes: 2));

    final restored = await LocalActivityStore(
      now: () => DateTime(2026, 7, 16),
    ).load();
    expect(restored.firstRecordedLocalDay, '2026-07-16');
    expect(restored.lastRecordedLocalDay, '2026-07-16');
    expect(restored.uniqueActiveDays, 1);
    expect(restored.currentStreakDays, 1);
    expect(restored.longestStreakDays, 1);
    expect(restored.total(LocalActivityMetric.appLaunch), 1);
    expect(restored.total(LocalActivityMetric.foregroundSeconds), 120);
    expect(restored.screenViewTotal(LocalActivityScreen.today), 1);
    expect(restored.prayerTotal(LocalActivityMetric.prayerOpened), 1);
    expect(restored.prayerTotal(LocalActivityMetric.prayerResumed), 1);
    expect(restored.prayerTotal(LocalActivityMetric.prayerCompleted), 2);
    expect(restored.prayerTotal(LocalActivityMetric.prayerFirstCompleted), 1);
    expect(restored.prayerTotal(LocalActivityMetric.prayerReplayCompleted), 1);
    expect(
      restored.prayerTotal(
        LocalActivityMetric.prayerAbandonProgressPoints,
        prayerDay: 4,
      ),
      50,
    );
    expect(
      restored.prayerTotal(
        LocalActivityMetric.prayerListeningSeconds,
        prayerDay: 4,
      ),
      42,
    );
    expect(restored.days.keys, ['2026-07-16']);

    final raw = (await SharedPreferences.getInstance()).getString(
      LocalActivityStore.storageKey,
    );
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect(decoded['schemaVersion'], LocalActivityHistory.schemaVersion);
    expect(
      decoded.keys,
      containsAll(<String>{
        'schemaVersion',
        'firstRecordedLocalDay',
        'lastRecordedLocalDay',
        'uniqueActiveDays',
        'currentStreakDays',
        'longestStreakDays',
        'lastPrayerCompletionLocalDay',
        'uniquePrayerCompletionDays',
        'currentPrayerStreakDays',
        'longestPrayerStreakDays',
        'retentionMilestones',
        'lifetimeCounters',
        'lifetimeScreenViews',
        'lifetimePrayerMetrics',
        'days',
      }),
    );
    expect(raw, isNot(contains('userId')));
    expect(raw, isNot(contains('deviceId')));
    expect(raw, isNot(contains('email')));
    expect(raw, isNot(contains('prayerTitle')));
  });

  test('serializes concurrent writes without losing totals', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalActivityStore(now: () => DateTime(2026, 7, 16));

    await Future.wait([for (var i = 0; i < 50; i++) store.recordAppResume()]);

    expect((await store.load()).total(LocalActivityMetric.appResume), 50);
  });

  test('tracks active-day streaks and retention milestones', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 7, 1);
    final store = LocalActivityStore(now: () => now);

    await store.recordAppLaunch();
    now = DateTime(2026, 7, 2);
    await store.recordAppLaunch();
    now = DateTime(2026, 7, 4);
    await store.recordAppLaunch();

    final history = await store.load();
    expect(history.uniqueActiveDays, 3);
    expect(history.currentStreakDays, 1);
    expect(history.longestStreakDays, 2);
    expect(history.retentionMilestones, {1, 3});
  });

  test('tracks prayer completion days and streaks separately', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 7, 1);
    final store = LocalActivityStore(now: () => now);

    await store.recordPrayerCompleted(1, firstCompletion: true);
    await store.recordPrayerCompleted(1, firstCompletion: false);
    now = DateTime(2026, 7, 2);
    await store.recordPrayerCompleted(2, firstCompletion: true);
    now = DateTime(2026, 7, 4);
    await store.recordPrayerCompleted(3, firstCompletion: true);

    final history = await store.load();
    expect(history.lastPrayerCompletionLocalDay, '2026-07-04');
    expect(history.uniquePrayerCompletionDays, 3);
    expect(history.currentPrayerStreakDays, 1);
    expect(history.longestPrayerStreakDays, 2);
  });

  test('retains lifetime totals while pruning old daily aggregates', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 1, 1);
    final store = LocalActivityStore(now: () => now);

    await store.recordAppLaunch();
    now = DateTime(2026, 4, 1);
    await store.recordAppLaunch();

    final history = await store.load();
    expect(history.total(LocalActivityMetric.appLaunch), 2);
    expect(history.days.keys, ['2026-04-01']);
    expect(history.retentionMilestones, contains(90));
  });

  test(
    'recovers safely from invalid data and reset preserves other keys',
    () async {
      SharedPreferences.setMockInitialValues({
        LocalActivityStore.storageKey: '{not-json',
        'supabase.auth.token': 'anonymous-session',
      });
      final store = LocalActivityStore(now: () => DateTime(2026, 7, 16));

      expect((await store.load()).uniqueActiveDays, 0);
      await store.recordAppLaunch();
      expect((await store.load()).total(LocalActivityMetric.appLaunch), 1);

      await store.reset();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalActivityStore.storageKey), isNull);
      expect(prefs.getString('supabase.auth.token'), 'anonymous-session');
    },
  );
}
