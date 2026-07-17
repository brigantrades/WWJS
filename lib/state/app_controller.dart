import 'dart:async';

import 'package:flutter/material.dart';

import '../core/local_day.dart';
import '../models/prayer_content.dart';
import '../services/app_storage.dart';
import '../services/app_review_service.dart';
import '../services/content_repository.dart';
import '../services/local_activity_store.dart';
import '../services/notification_service.dart';
import '../services/prayer_audio_session.dart';
import '../services/subscription_service.dart';

class AppController extends ChangeNotifier {
  static const freeDayLimit = 7;

  AppController({
    AppStorage? storage,
    ReminderScheduler? reminders,
    DateTime Function()? now,
    ContentRepository? contentRepository,
    ReviewPrompter? reviewPrompter,
    LocalActivityStore? activityStore,
    this.subscriptionService,
    this.audioSession,
  }) : _storage = storage ?? AppStorage(),
       _reminders = reminders ?? NotificationService(),
       _reviewPrompter = reviewPrompter ?? AppReviewService(),
       _contentRepository =
           contentRepository ?? const BundledContentRepository(),
       _activityStore = activityStore ?? LocalActivityStore(now: now),
       _now = now ?? DateTime.now {
    _reminders.onReminderTapped = _openTodayFromReminder;
    subscriptionService?.addListener(_subscriptionChanged);
  }

  final AppStorage _storage;
  final ReminderScheduler _reminders;
  final ReviewPrompter _reviewPrompter;
  final ContentRepository _contentRepository;
  final LocalActivityStore _activityStore;
  final DateTime Function() _now;
  final SubscriptionService? subscriptionService;
  final PrayerAudioSession? audioSession;
  List<PrayerContent> prayers = [];
  bool _disposed = false;
  DateTime? _foregroundStartedAt;

  bool onboardingComplete = false;
  DateTime? startDate;
  int highestUnlockedDay = 1;
  Set<int> favorites = {};
  Set<int> completed = {};
  Map<int, Duration> positions = {};
  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 7, minute: 30);
  bool notificationPermissionDenied = false;
  ThemeMode themeMode = ThemeMode.system;
  double textScale = 1;
  int _todayNavigationRequest = 0;

  int get todayNavigationRequest => _todayNavigationRequest;

  int get prayerCount => prayers.length;

  bool get hasCompletedFreeAccess => completed.contains(freeDayLimit);

  bool get hasActiveSubscription => subscriptionService?.isEntitled ?? false;

  bool get requiresSubscription =>
      hasCompletedFreeAccess && !hasActiveSubscription;

  int get highestAccessibleDay => requiresSubscription
      ? freeDayLimit.clamp(0, prayers.length)
      : highestUnlockedDay;

  List<PrayerContent> get unlockedPrayers =>
      prayers.take(highestAccessibleDay.clamp(0, prayers.length)).toList();

  PrayerContent get todaysPrayer => unlockedPrayers.last;

  Future<void> initialize() async {
    final (publishedPrayers, snapshot, _) = await (
      _contentRepository.fetchPublishedPrayers(),
      _storage.load(),
      _reminders.initialize(),
    ).wait;

    prayers = [...publishedPrayers]
      ..sort((first, second) => first.day.compareTo(second.day));
    if (prayers.isEmpty) {
      throw StateError('No published prayer days were returned by Supabase.');
    }
    onboardingComplete = snapshot.onboardingComplete;
    startDate = snapshot.startDate;
    highestUnlockedDay = snapshot.highestUnlockedDay;
    favorites = snapshot.favorites;
    completed = snapshot.completed;
    positions = snapshot.positions;
    reminderEnabled = snapshot.reminderEnabled;
    reminderTime = snapshot.reminderTime;
    themeMode = snapshot.themeMode;
    textScale = snapshot.textScale;

    if (onboardingComplete && startDate != null) {
      highestUnlockedDay = calculateUnlockedDay(
        startDate: startDate!,
        today: _now(),
        previousHighest: highestUnlockedDay,
        contentCount: prayers.length,
      );
      await _storage.saveHighestUnlocked(highestUnlockedDay);
    }
    await _activityStore.recordAppLaunch();
    _foregroundStartedAt = _now();
    unawaited(preloadTodayAudio());
    if (_contentRepository case RefreshableContentRepository repository) {
      unawaited(_refreshPublishedPrayers(repository));
    }
  }

  Future<void> _refreshPublishedPrayers(
    RefreshableContentRepository repository,
  ) async {
    try {
      final refreshed = [...await repository.refreshPublishedPrayers()]
        ..sort((first, second) => first.day.compareTo(second.day));
      if (_disposed || refreshed.isEmpty) return;

      prayers = refreshed;
      if (onboardingComplete && startDate != null) {
        final refreshedHighest = calculateUnlockedDay(
          startDate: startDate!,
          today: _now(),
          previousHighest: highestUnlockedDay,
          contentCount: prayers.length,
        );
        if (refreshedHighest != highestUnlockedDay) {
          highestUnlockedDay = refreshedHighest;
          await _storage.saveHighestUnlocked(highestUnlockedDay);
        }
      }
      if (_disposed) return;
      notifyListeners();
      unawaited(preloadTodayAudio());
    } catch (error, stackTrace) {
      debugPrint('Refreshing prayer content failed: $error\n$stackTrace');
    }
  }

  Future<void> preloadTodayAudio() async {
    if (audioSession == null || prayers.isEmpty) return;
    try {
      await audioSession!.prepare(todaysPrayer);
    } catch (_) {
      // The player screen presents audio errors and can retry preparation.
    }
  }

  Future<void> finishOnboarding({int startingDay = 1}) async {
    final day = startingDay.clamp(1, prayers.length);
    startDate = localDay(_now()).subtract(Duration(days: day - 1));
    onboardingComplete = true;
    highestUnlockedDay = day;
    await _storage.saveOnboarding(startDate!);
    await _storage.saveHighestUnlocked(day);
    await _activityStore.recordOnboardingCompleted(startingDay: day);
    notifyListeners();
    unawaited(preloadTodayAudio());
  }

  Future<void> setCurrentDay(int selectedDay) async {
    final day = selectedDay.clamp(1, prayers.length);
    startDate = localDay(_now()).subtract(Duration(days: day - 1));
    highestUnlockedDay = day;
    await _storage.saveOnboarding(startDate!);
    await _storage.saveHighestUnlocked(day);
    await _activityStore.recordJourneyDayChanged(day);
    notifyListeners();
    unawaited(preloadTodayAudio());
  }

  Future<void> toggleFavorite(int day) async {
    final added = !favorites.contains(day);
    added ? favorites.add(day) : favorites.remove(day);
    notifyListeners();
    await _storage.saveFavorites(favorites);
    await _activityStore.recordFavoriteChanged(day, added: added);
  }

  Future<void> markCompleted(int day) async {
    final firstCompletion = !completed.contains(day);
    completed.add(day);
    positions[day] = Duration.zero;
    notifyListeners();
    await _storage.saveCompleted(completed);
    await _storage.savePositions(positions);
    await _activityStore.recordPrayerCompleted(
      day,
      firstCompletion: firstCompletion,
    );
  }

  Future<void> savePosition(int day, Duration position) async {
    positions[day] = position;
    await _storage.savePositions(positions);
  }

  Future<void> requestStoreReview() async {
    await _reviewPrompter.requestReview();
  }

  Future<bool> configureReminder({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    reminderTime = time;
    notificationPermissionDenied = false;
    if (enabled) {
      final allowed = await _reminders.requestPermission();
      if (!allowed) {
        reminderEnabled = false;
        notificationPermissionDenied = true;
        await _storage.saveReminder(false, time);
        await _activityStore.recordReminderPermissionDenied();
        notifyListeners();
        return false;
      }
      reminderEnabled = true;
      await _reminders.scheduleDaily(time);
    } else {
      reminderEnabled = false;
      await _reminders.cancel();
    }
    await _storage.saveReminder(reminderEnabled, time);
    await _activityStore.recordReminderChanged(enabled: reminderEnabled);
    notifyListeners();
    return true;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await _storage.saveTheme(mode);
  }

  Future<void> setTextScale(double scale) async {
    textScale = scale;
    notifyListeners();
    await _storage.saveTextScale(scale);
  }

  Future<void> recordScreenView(LocalActivityScreen screen) =>
      _activityStore.recordScreenView(screen);

  Future<void> recordPrayerOpened(int day, {required bool resumed}) =>
      _activityStore.recordPrayerOpened(day, resumed: resumed);

  Future<void> recordPrayerPlaybackStarted(int day) =>
      _activityStore.recordPrayerPlaybackStarted(day);

  Future<void> recordPrayerAbandoned(
    int day, {
    required int progressPercent,
    required Duration listeningDuration,
  }) => _activityStore.recordPrayerAbandoned(
    day,
    progressPercent: progressPercent,
    listeningDuration: listeningDuration,
  );

  Future<void> recordPrayerListening(int day, Duration listeningDuration) =>
      _activityStore.recordPrayerListening(day, listeningDuration);

  Future<void> recordAppResumed() async {
    if (_foregroundStartedAt != null) return;
    _foregroundStartedAt = _now();
    await _activityStore.recordAppResume();
  }

  Future<void> recordAppBackgrounded() async {
    final startedAt = _foregroundStartedAt;
    if (startedAt == null) return;
    _foregroundStartedAt = null;
    final elapsed = _now().difference(startedAt);
    if (!elapsed.isNegative) {
      await _activityStore.recordForegroundDuration(elapsed);
    }
  }

  Future<LocalActivityHistory> loadLocalActivityHistory() =>
      _activityStore.load();

  void _openTodayFromReminder() {
    if (_disposed) return;
    _todayNavigationRequest += 1;
    notifyListeners();
  }

  void _subscriptionChanged() => notifyListeners();

  Future<void> reset() async {
    await _reminders.cancel();
    _foregroundStartedAt = null;
    await Future.wait([_storage.reset(), _activityStore.reset()]);
    onboardingComplete = false;
    startDate = null;
    highestUnlockedDay = 1;
    favorites = {};
    completed = {};
    positions = {};
    reminderEnabled = false;
    reminderTime = const TimeOfDay(hour: 7, minute: 30);
    notificationPermissionDenied = false;
    themeMode = ThemeMode.system;
    textScale = 1;
    notifyListeners();
    unawaited(preloadTodayAudio());
  }

  @override
  void dispose() {
    _disposed = true;
    _reminders.onReminderTapped = null;
    subscriptionService?.removeListener(_subscriptionChanged);
    subscriptionService?.dispose();
    if (audioSession != null) unawaited(audioSession!.dispose());
    super.dispose();
  }
}
