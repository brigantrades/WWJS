import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/local_day.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.onboardingComplete,
    required this.startDate,
    required this.highestUnlockedDay,
    required this.journeyProgressionVersion,
    required this.favorites,
    required this.completed,
    required this.completedOn,
    required this.positions,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.themeMode,
    required this.textScale,
  });

  final bool onboardingComplete;
  final DateTime? startDate;
  final int highestUnlockedDay;
  final int journeyProgressionVersion;
  final Set<int> favorites;
  final Set<int> completed;
  final Map<int, DateTime> completedOn;
  final Map<int, Duration> positions;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;
  final ThemeMode themeMode;
  final double textScale;
}

class AppStorage {
  static const _onboarding = 'onboarding_complete';
  static const _startDate = 'start_date';
  static const _highestUnlocked = 'highest_unlocked';
  static const _journeyProgressionVersion = 'journey_progression_version';
  static const _favorites = 'favorites';
  static const _completed = 'completed';
  static const _completedOn = 'completed_on';
  static const _positions = 'positions';
  static const _reminderEnabled = 'reminder_enabled';
  static const _reminderHour = 'reminder_hour';
  static const _reminderMinute = 'reminder_minute';
  static const _theme = 'theme';
  static const _textScale = 'text_scale';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<AppSnapshot> load() async {
    final prefs = await _prefs;
    final positionJson = prefs.getString(_positions);
    final decoded = positionJson == null
        ? <String, dynamic>{}
        : (jsonDecode(positionJson) as Map<String, dynamic>);
    final positions = decoded.map(
      (key, value) =>
          MapEntry(int.parse(key), Duration(milliseconds: value as int)),
    );
    final completedOnJson = prefs.getString(_completedOn);
    final completedOnDecoded = completedOnJson == null
        ? <String, dynamic>{}
        : (jsonDecode(completedOnJson) as Map<String, dynamic>);
    final completedOn = <int, DateTime>{};
    for (final entry in completedOnDecoded.entries) {
      final day = int.tryParse(entry.key);
      final date = decodeLocalDay(entry.value as String?);
      if (day != null && date != null) completedOn[day] = date;
    }

    return AppSnapshot(
      onboardingComplete: prefs.getBool(_onboarding) ?? false,
      startDate: decodeLocalDay(prefs.getString(_startDate)),
      highestUnlockedDay: prefs.getInt(_highestUnlocked) ?? 1,
      journeyProgressionVersion: prefs.getInt(_journeyProgressionVersion) ?? 1,
      favorites: (prefs.getStringList(_favorites) ?? const [])
          .map(int.parse)
          .toSet(),
      completed: (prefs.getStringList(_completed) ?? const [])
          .map(int.parse)
          .toSet(),
      completedOn: completedOn,
      positions: positions,
      reminderEnabled: prefs.getBool(_reminderEnabled) ?? false,
      reminderTime: TimeOfDay(
        hour: prefs.getInt(_reminderHour) ?? 7,
        minute: prefs.getInt(_reminderMinute) ?? 30,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == prefs.getString(_theme),
        orElse: () => ThemeMode.system,
      ),
      textScale: prefs.getDouble(_textScale) ?? 1,
    );
  }

  Future<void> saveOnboarding(DateTime startDate) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboarding, true);
    await prefs.setString(_startDate, encodeLocalDay(startDate));
  }

  Future<void> saveHighestUnlocked(int day) async {
    await (await _prefs).setInt(_highestUnlocked, day);
  }

  Future<void> saveJourneyProgressionVersion(int version) async {
    await (await _prefs).setInt(_journeyProgressionVersion, version);
  }

  Future<void> saveFavorites(Set<int> days) async {
    await (await _prefs).setStringList(
      _favorites,
      days.map((day) => '$day').toList()..sort(),
    );
  }

  Future<void> saveCompleted(Set<int> days) async {
    await (await _prefs).setStringList(
      _completed,
      days.map((day) => '$day').toList()..sort(),
    );
  }

  Future<void> saveCompletedOn(Map<int, DateTime> dates) async {
    await (await _prefs).setString(
      _completedOn,
      jsonEncode(
        dates.map((day, date) => MapEntry('$day', encodeLocalDay(date))),
      ),
    );
  }

  Future<void> savePositions(Map<int, Duration> positions) async {
    await (await _prefs).setString(
      _positions,
      jsonEncode(
        positions.map((day, value) => MapEntry('$day', value.inMilliseconds)),
      ),
    );
  }

  Future<void> saveReminder(bool enabled, TimeOfDay time) async {
    final prefs = await _prefs;
    await prefs.setBool(_reminderEnabled, enabled);
    await prefs.setInt(_reminderHour, time.hour);
    await prefs.setInt(_reminderMinute, time.minute);
  }

  Future<void> saveTheme(ThemeMode mode) async {
    await (await _prefs).setString(_theme, mode.name);
  }

  Future<void> saveTextScale(double scale) async {
    await (await _prefs).setDouble(_textScale, scale);
  }

  Future<void> reset() async {
    final prefs = await _prefs;
    for (final key in [
      _onboarding,
      _startDate,
      _highestUnlocked,
      _journeyProgressionVersion,
      _favorites,
      _completed,
      _completedOn,
      _positions,
      _reminderEnabled,
      _reminderHour,
      _reminderMinute,
      _theme,
      _textScale,
    ]) {
      await prefs.remove(key);
    }
  }
}
