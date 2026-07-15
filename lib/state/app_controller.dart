import 'dart:async';

import 'package:flutter/material.dart';

import '../core/local_day.dart';
import '../models/prayer_content.dart';
import '../services/app_storage.dart';
import '../services/app_review_service.dart';
import '../services/content_repository.dart';
import '../services/notification_service.dart';
import '../services/prayer_audio_session.dart';

class AppController extends ChangeNotifier {
  static const freeDayLimit = 7;

  AppController({
    AppStorage? storage,
    ReminderScheduler? reminders,
    DateTime Function()? now,
    ContentRepository? contentRepository,
    ReviewPrompter? reviewPrompter,
    this.audioSession,
  }) : _storage = storage ?? AppStorage(),
       _reminders = reminders ?? NotificationService(),
       _reviewPrompter = reviewPrompter ?? AppReviewService(),
       _contentRepository =
           contentRepository ?? const BundledContentRepository(),
       _now = now ?? DateTime.now;

  final AppStorage _storage;
  final ReminderScheduler _reminders;
  final ReviewPrompter _reviewPrompter;
  final ContentRepository _contentRepository;
  final DateTime Function() _now;
  final PrayerAudioSession? audioSession;
  List<PrayerContent> prayers = [];

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

  int get prayerCount => prayers.length;

  bool get hasCompletedFreeAccess => completed.contains(freeDayLimit);

  int get highestAccessibleDay => hasCompletedFreeAccess
      ? freeDayLimit.clamp(0, prayers.length)
      : highestUnlockedDay;

  List<PrayerContent> get unlockedPrayers =>
      prayers.take(highestAccessibleDay.clamp(0, prayers.length)).toList();

  PrayerContent get todaysPrayer => unlockedPrayers.last;

  Future<void> initialize() async {
    prayers = [...await _contentRepository.fetchPublishedPrayers()]
      ..sort((first, second) => first.day.compareTo(second.day));
    if (prayers.isEmpty) {
      throw StateError('No published prayer days were returned by Supabase.');
    }
    final snapshot = await _storage.load();
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

    await _reminders.initialize();
    if (onboardingComplete && startDate != null) {
      highestUnlockedDay = calculateUnlockedDay(
        startDate: startDate!,
        today: _now(),
        previousHighest: highestUnlockedDay,
        contentCount: prayers.length,
      );
      await _storage.saveHighestUnlocked(highestUnlockedDay);
    }
    await preloadTodayAudio();
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
    notifyListeners();
    unawaited(preloadTodayAudio());
  }

  Future<void> setCurrentDay(int selectedDay) async {
    final day = selectedDay.clamp(1, prayers.length);
    startDate = localDay(_now()).subtract(Duration(days: day - 1));
    highestUnlockedDay = day;
    await _storage.saveOnboarding(startDate!);
    await _storage.saveHighestUnlocked(day);
    notifyListeners();
    unawaited(preloadTodayAudio());
  }

  Future<void> toggleFavorite(int day) async {
    favorites.contains(day) ? favorites.remove(day) : favorites.add(day);
    notifyListeners();
    await _storage.saveFavorites(favorites);
  }

  Future<void> markCompleted(int day) async {
    completed.add(day);
    positions[day] = Duration.zero;
    notifyListeners();
    await _storage.saveCompleted(completed);
    await _storage.savePositions(positions);
  }

  Future<void> savePosition(int day, Duration position) async {
    positions[day] = position;
    await _storage.savePositions(positions);
  }

  Future<void> requestStoreReview() => _reviewPrompter.requestReview();

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

  Future<void> reset() async {
    await _reminders.cancel();
    await _storage.reset();
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
    if (audioSession != null) unawaited(audioSession!.dispose());
    super.dispose();
  }
}
