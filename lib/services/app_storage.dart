import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/local_day.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.onboardingComplete,
    required this.startDate,
    required this.highestUnlockedDay,
    required this.favorites,
    required this.completed,
    required this.positions,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.themeMode,
    required this.textScale,
  });

  final bool onboardingComplete;
  final DateTime? startDate;
  final int highestUnlockedDay;
  final Set<int> favorites;
  final Set<int> completed;
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
  static const _favorites = 'favorites';
  static const _completed = 'completed';
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

    return AppSnapshot(
      onboardingComplete: prefs.getBool(_onboarding) ?? false,
      startDate: decodeLocalDay(prefs.getString(_startDate)),
      highestUnlockedDay: prefs.getInt(_highestUnlocked) ?? 1,
      favorites: (prefs.getStringList(_favorites) ?? const [])
          .map(int.parse)
          .toSet(),
      completed: (prefs.getStringList(_completed) ?? const [])
          .map(int.parse)
          .toSet(),
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
    await (await _prefs).clear();
  }
}
