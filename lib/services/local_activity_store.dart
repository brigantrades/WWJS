import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/local_day.dart';

enum LocalActivityMetric {
  appLaunch('app_launch'),
  appResume('app_resume'),
  foregroundSeconds('foreground_seconds'),
  onboardingCompleted('onboarding_completed'),
  startingDaySelected('starting_day_selected'),
  journeyDayChanged('journey_day_changed'),
  prayerOpened('prayer_opened'),
  prayerResumed('prayer_resumed'),
  prayerPlaybackStarted('prayer_playback_started'),
  prayerCompleted('prayer_completed'),
  prayerFirstCompleted('prayer_first_completed'),
  prayerReplayCompleted('prayer_replay_completed'),
  prayerAbandoned('prayer_abandoned'),
  prayerAbandonProgressPoints('prayer_abandon_progress_points'),
  prayerListeningSeconds('prayer_listening_seconds'),
  favoriteAdded('favorite_added'),
  favoriteRemoved('favorite_removed'),
  reminderEnabled('reminder_enabled'),
  reminderDisabled('reminder_disabled'),
  reminderPermissionDenied('reminder_permission_denied');

  const LocalActivityMetric(this.key);

  final String key;
}

enum LocalActivityScreen {
  today('today'),
  prayers('prayers'),
  settings('settings');

  const LocalActivityScreen(this.key);

  final String key;
}

class LocalActivityDay {
  LocalActivityDay({
    Map<String, int>? counters,
    Map<String, int>? screenViews,
    Map<String, Map<String, int>>? prayerMetrics,
  }) : counters = counters ?? {},
       screenViews = screenViews ?? {},
       prayerMetrics = prayerMetrics ?? {};

  factory LocalActivityDay.fromJson(Object? value) {
    if (value is! Map) return LocalActivityDay();
    return LocalActivityDay(
      counters: _decodeIntMap(value['counters']),
      screenViews: _decodeIntMap(value['screenViews']),
      prayerMetrics: _decodeNestedIntMap(value['prayerMetrics']),
    );
  }

  final Map<String, int> counters;
  final Map<String, int> screenViews;
  final Map<String, Map<String, int>> prayerMetrics;

  Map<String, Object> toJson() => {
    'counters': counters,
    'screenViews': screenViews,
    'prayerMetrics': prayerMetrics,
  };
}

class LocalActivityHistory {
  LocalActivityHistory({
    this.firstRecordedLocalDay,
    this.lastRecordedLocalDay,
    this.uniqueActiveDays = 0,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.lastPrayerCompletionLocalDay,
    this.uniquePrayerCompletionDays = 0,
    this.currentPrayerStreakDays = 0,
    this.longestPrayerStreakDays = 0,
    Set<int>? retentionMilestones,
    Map<String, int>? lifetimeCounters,
    Map<String, int>? lifetimeScreenViews,
    Map<String, Map<String, int>>? lifetimePrayerMetrics,
    Map<String, LocalActivityDay>? days,
  }) : retentionMilestones = retentionMilestones ?? {},
       lifetimeCounters = lifetimeCounters ?? {},
       lifetimeScreenViews = lifetimeScreenViews ?? {},
       lifetimePrayerMetrics = lifetimePrayerMetrics ?? {},
       days = days ?? {};

  factory LocalActivityHistory.fromJson(Object? value) {
    if (value is! Map || value['schemaVersion'] != schemaVersion) {
      return LocalActivityHistory();
    }

    final decodedDays = <String, LocalActivityDay>{};
    final rawDays = value['days'];
    if (rawDays is Map) {
      for (final entry in rawDays.entries) {
        if (entry.key is String) {
          decodedDays[entry.key as String] = LocalActivityDay.fromJson(
            entry.value,
          );
        }
      }
    }

    return LocalActivityHistory(
      firstRecordedLocalDay: value['firstRecordedLocalDay'] as String?,
      lastRecordedLocalDay: value['lastRecordedLocalDay'] as String?,
      uniqueActiveDays: _decodeInt(value['uniqueActiveDays']),
      currentStreakDays: _decodeInt(value['currentStreakDays']),
      longestStreakDays: _decodeInt(value['longestStreakDays']),
      lastPrayerCompletionLocalDay:
          value['lastPrayerCompletionLocalDay'] as String?,
      uniquePrayerCompletionDays: _decodeInt(
        value['uniquePrayerCompletionDays'],
      ),
      currentPrayerStreakDays: _decodeInt(value['currentPrayerStreakDays']),
      longestPrayerStreakDays: _decodeInt(value['longestPrayerStreakDays']),
      retentionMilestones: _decodeIntSet(value['retentionMilestones']),
      lifetimeCounters: _decodeIntMap(value['lifetimeCounters']),
      lifetimeScreenViews: _decodeIntMap(value['lifetimeScreenViews']),
      lifetimePrayerMetrics: _decodeNestedIntMap(
        value['lifetimePrayerMetrics'],
      ),
      days: decodedDays,
    );
  }

  static const schemaVersion = 1;

  String? firstRecordedLocalDay;
  String? lastRecordedLocalDay;
  int uniqueActiveDays;
  int currentStreakDays;
  int longestStreakDays;
  String? lastPrayerCompletionLocalDay;
  int uniquePrayerCompletionDays;
  int currentPrayerStreakDays;
  int longestPrayerStreakDays;
  final Set<int> retentionMilestones;
  final Map<String, int> lifetimeCounters;
  final Map<String, int> lifetimeScreenViews;
  final Map<String, Map<String, int>> lifetimePrayerMetrics;
  final Map<String, LocalActivityDay> days;

  int total(LocalActivityMetric metric) => lifetimeCounters[metric.key] ?? 0;

  int screenViewTotal(LocalActivityScreen screen) =>
      lifetimeScreenViews[screen.key] ?? 0;

  int prayerTotal(LocalActivityMetric metric, {int? prayerDay}) {
    final values = lifetimePrayerMetrics[metric.key] ?? const {};
    if (prayerDay != null) return values['$prayerDay'] ?? 0;
    return values.values.fold(0, (total, value) => total + value);
  }

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'firstRecordedLocalDay': ?firstRecordedLocalDay,
    'lastRecordedLocalDay': ?lastRecordedLocalDay,
    'uniqueActiveDays': uniqueActiveDays,
    'currentStreakDays': currentStreakDays,
    'longestStreakDays': longestStreakDays,
    'lastPrayerCompletionLocalDay': ?lastPrayerCompletionLocalDay,
    'uniquePrayerCompletionDays': uniquePrayerCompletionDays,
    'currentPrayerStreakDays': currentPrayerStreakDays,
    'longestPrayerStreakDays': longestPrayerStreakDays,
    'retentionMilestones': retentionMilestones.toList()..sort(),
    'lifetimeCounters': lifetimeCounters,
    'lifetimeScreenViews': lifetimeScreenViews,
    'lifetimePrayerMetrics': lifetimePrayerMetrics,
    'days': days.map((day, value) => MapEntry(day, value.toJson())),
  };
}

class LocalActivityStore {
  LocalActivityStore({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const storageKey = 'local_activity_history_v1';
  static const dailyRetentionDays = 90;
  static const _retentionMilestoneDays = {1, 3, 7, 14, 30, 60, 90};

  final DateTime Function() _now;
  Future<void> _pendingWrite = Future.value();

  Future<void> recordAppLaunch() =>
      _recordCounter(LocalActivityMetric.appLaunch);

  Future<void> recordAppResume() =>
      _recordCounter(LocalActivityMetric.appResume);

  Future<void> recordForegroundDuration(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 6 * 60 * 60).toInt();
    if (seconds == 0) return Future.value();
    return _recordCounter(
      LocalActivityMetric.foregroundSeconds,
      amount: seconds,
    );
  }

  Future<void> recordScreenView(LocalActivityScreen screen) =>
      _mutate((history, day) {
        _increment(history.lifetimeScreenViews, screen.key);
        _increment(day.screenViews, screen.key);
      });

  Future<void> recordOnboardingCompleted({required int startingDay}) =>
      _mutate((history, day) {
        _increment(
          history.lifetimeCounters,
          LocalActivityMetric.onboardingCompleted.key,
        );
        _increment(day.counters, LocalActivityMetric.onboardingCompleted.key);
        _incrementPrayer(
          history.lifetimePrayerMetrics,
          LocalActivityMetric.startingDaySelected,
          startingDay,
        );
        _incrementPrayer(
          day.prayerMetrics,
          LocalActivityMetric.startingDaySelected,
          startingDay,
        );
      });

  Future<void> recordJourneyDayChanged(int dayNumber) =>
      _recordPrayer(LocalActivityMetric.journeyDayChanged, dayNumber);

  Future<void> recordPrayerOpened(int dayNumber, {required bool resumed}) =>
      _mutate((history, day) {
        _incrementPrayer(
          history.lifetimePrayerMetrics,
          LocalActivityMetric.prayerOpened,
          dayNumber,
        );
        _incrementPrayer(
          day.prayerMetrics,
          LocalActivityMetric.prayerOpened,
          dayNumber,
        );
        if (resumed) {
          _incrementPrayer(
            history.lifetimePrayerMetrics,
            LocalActivityMetric.prayerResumed,
            dayNumber,
          );
          _incrementPrayer(
            day.prayerMetrics,
            LocalActivityMetric.prayerResumed,
            dayNumber,
          );
        }
      });

  Future<void> recordPrayerPlaybackStarted(int dayNumber) =>
      _recordPrayer(LocalActivityMetric.prayerPlaybackStarted, dayNumber);

  Future<void> recordPrayerCompleted(int dayNumber) => _mutate((history, day) {
    final firstCompletion =
        history.prayerTotal(
          LocalActivityMetric.prayerCompleted,
          prayerDay: dayNumber,
        ) ==
        0;
    _markPrayerCompletionDay(history, localDay(_now()));
    for (final metric in [
      LocalActivityMetric.prayerCompleted,
      firstCompletion
          ? LocalActivityMetric.prayerFirstCompleted
          : LocalActivityMetric.prayerReplayCompleted,
    ]) {
      _incrementPrayer(history.lifetimePrayerMetrics, metric, dayNumber);
      _incrementPrayer(day.prayerMetrics, metric, dayNumber);
    }
  });

  Future<void> recordPrayerAbandoned(
    int dayNumber, {
    required int progressPercent,
    required Duration listeningDuration,
  }) => _mutate((history, day) {
    final bucketedProgress = _progressBucket(progressPercent);
    final listeningSeconds = listeningDuration.inSeconds
        .clamp(0, 6 * 60 * 60)
        .toInt();
    _incrementPrayer(
      history.lifetimePrayerMetrics,
      LocalActivityMetric.prayerAbandoned,
      dayNumber,
    );
    _incrementPrayer(
      day.prayerMetrics,
      LocalActivityMetric.prayerAbandoned,
      dayNumber,
    );
    if (bucketedProgress > 0) {
      _incrementPrayer(
        history.lifetimePrayerMetrics,
        LocalActivityMetric.prayerAbandonProgressPoints,
        dayNumber,
        amount: bucketedProgress,
      );
      _incrementPrayer(
        day.prayerMetrics,
        LocalActivityMetric.prayerAbandonProgressPoints,
        dayNumber,
        amount: bucketedProgress,
      );
    }
    if (listeningSeconds > 0) {
      _incrementPrayer(
        history.lifetimePrayerMetrics,
        LocalActivityMetric.prayerListeningSeconds,
        dayNumber,
        amount: listeningSeconds,
      );
      _incrementPrayer(
        day.prayerMetrics,
        LocalActivityMetric.prayerListeningSeconds,
        dayNumber,
        amount: listeningSeconds,
      );
    }
  });

  Future<void> recordPrayerListening(
    int dayNumber,
    Duration listeningDuration,
  ) {
    final seconds = listeningDuration.inSeconds.clamp(0, 6 * 60 * 60).toInt();
    if (seconds == 0) return Future.value();
    return _recordPrayer(
      LocalActivityMetric.prayerListeningSeconds,
      dayNumber,
      amount: seconds,
    );
  }

  Future<void> recordFavoriteChanged(int dayNumber, {required bool added}) =>
      _recordPrayer(
        added
            ? LocalActivityMetric.favoriteAdded
            : LocalActivityMetric.favoriteRemoved,
        dayNumber,
      );

  Future<void> recordReminderChanged({required bool enabled}) => _recordCounter(
    enabled
        ? LocalActivityMetric.reminderEnabled
        : LocalActivityMetric.reminderDisabled,
  );

  Future<void> recordReminderPermissionDenied() =>
      _recordCounter(LocalActivityMetric.reminderPermissionDenied);

  Future<LocalActivityHistory> load() async {
    await _pendingWrite;
    return _readHistory();
  }

  Future<void> reset() => _enqueue(() async {
    await (await SharedPreferences.getInstance()).remove(storageKey);
  });

  Future<void> _recordCounter(LocalActivityMetric metric, {int amount = 1}) =>
      _mutate((history, day) {
        _increment(history.lifetimeCounters, metric.key, amount: amount);
        _increment(day.counters, metric.key, amount: amount);
      });

  Future<void> _recordPrayer(
    LocalActivityMetric metric,
    int dayNumber, {
    int amount = 1,
  }) => _mutate((history, day) {
    _incrementPrayer(
      history.lifetimePrayerMetrics,
      metric,
      dayNumber,
      amount: amount,
    );
    _incrementPrayer(day.prayerMetrics, metric, dayNumber, amount: amount);
  });

  Future<void> _mutate(
    void Function(LocalActivityHistory history, LocalActivityDay day) update,
  ) => _enqueue(() async {
    final history = await _readHistory();
    final today = localDay(_now());
    final dayKey = encodeLocalDay(today);
    _markActive(history, today);
    final day = history.days.putIfAbsent(dayKey, LocalActivityDay.new);
    update(history, day);
    _pruneDailyHistory(history, today);
    await (await SharedPreferences.getInstance()).setString(
      storageKey,
      jsonEncode(history.toJson()),
    );
  });

  Future<LocalActivityHistory> _readHistory() async {
    try {
      final value = (await SharedPreferences.getInstance()).getString(
        storageKey,
      );
      if (value == null) return LocalActivityHistory();
      return LocalActivityHistory.fromJson(jsonDecode(value));
    } catch (_) {
      return LocalActivityHistory();
    }
  }

  void _markActive(LocalActivityHistory history, DateTime today) {
    final todayKey = encodeLocalDay(today);
    final first = decodeLocalDay(history.firstRecordedLocalDay);
    final last = decodeLocalDay(history.lastRecordedLocalDay);

    if (first == null || last == null) {
      history.firstRecordedLocalDay = todayKey;
      history.lastRecordedLocalDay = todayKey;
      history.uniqueActiveDays = 1;
      history.currentStreakDays = 1;
      history.longestStreakDays = 1;
      return;
    }

    final differenceFromLast = calendarDayDifference(last, today);
    if (differenceFromLast <= 0) return;

    history.lastRecordedLocalDay = todayKey;
    history.uniqueActiveDays += 1;
    history.currentStreakDays = differenceFromLast == 1
        ? history.currentStreakDays + 1
        : 1;
    if (history.currentStreakDays > history.longestStreakDays) {
      history.longestStreakDays = history.currentStreakDays;
    }

    final age = calendarDayDifference(first, today);
    if (_retentionMilestoneDays.contains(age)) {
      history.retentionMilestones.add(age);
    }
  }

  void _pruneDailyHistory(LocalActivityHistory history, DateTime today) {
    final latest = decodeLocalDay(history.lastRecordedLocalDay) ?? today;
    final cutoff = latest.subtract(
      const Duration(days: dailyRetentionDays - 1),
    );
    history.days.removeWhere((key, _) {
      final day = decodeLocalDay(key);
      return day == null || day.isBefore(cutoff);
    });
  }

  void _markPrayerCompletionDay(LocalActivityHistory history, DateTime today) {
    final previous = decodeLocalDay(history.lastPrayerCompletionLocalDay);
    if (previous == null) {
      history.lastPrayerCompletionLocalDay = encodeLocalDay(today);
      history.uniquePrayerCompletionDays = 1;
      history.currentPrayerStreakDays = 1;
      history.longestPrayerStreakDays = 1;
      return;
    }

    final difference = calendarDayDifference(previous, today);
    if (difference <= 0) return;
    history.lastPrayerCompletionLocalDay = encodeLocalDay(today);
    history.uniquePrayerCompletionDays += 1;
    history.currentPrayerStreakDays = difference == 1
        ? history.currentPrayerStreakDays + 1
        : 1;
    if (history.currentPrayerStreakDays > history.longestPrayerStreakDays) {
      history.longestPrayerStreakDays = history.currentPrayerStreakDays;
    }
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _pendingWrite.then((_) => operation());
    _pendingWrite = next.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return _pendingWrite;
  }
}

void _increment(Map<String, int> values, String key, {int amount = 1}) {
  if (amount <= 0) return;
  values[key] = (values[key] ?? 0) + amount;
}

void _incrementPrayer(
  Map<String, Map<String, int>> values,
  LocalActivityMetric metric,
  int prayerDay, {
  int amount = 1,
}) {
  if (prayerDay < 1 || amount <= 0) return;
  final days = values.putIfAbsent(metric.key, () => {});
  _increment(days, '$prayerDay', amount: amount);
}

int _progressBucket(int value) {
  final safe = value.clamp(0, 100);
  if (safe >= 88) return 100;
  if (safe >= 63) return 75;
  if (safe >= 38) return 50;
  if (safe >= 13) return 25;
  return 0;
}

int _decodeInt(Object? value) => value is num ? value.toInt() : 0;

Map<String, int> _decodeIntMap(Object? value) {
  if (value is! Map) return {};
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value is num)
        entry.key as String: (entry.value as num).toInt(),
  };
}

Map<String, Map<String, int>> _decodeNestedIntMap(Object? value) {
  if (value is! Map) return {};
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: _decodeIntMap(entry.value),
  };
}

Set<int> _decodeIntSet(Object? value) {
  if (value is! List) return {};
  return value.whereType<num>().map((entry) => entry.toInt()).toSet();
}
