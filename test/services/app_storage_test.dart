import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/services/app_storage.dart';

void main() {
  test(
    'persists favorites, progress, reminder, and playback position',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = AppStorage();

      await storage.saveOnboarding(DateTime(2026, 7, 11));
      await storage.saveFavorites({1, 3});
      await storage.saveCompleted({1});
      await storage.savePositions({1: const Duration(seconds: 42)});
      await storage.saveReminder(true, const TimeOfDay(hour: 7, minute: 30));

      final snapshot = await storage.load();
      expect(snapshot.onboardingComplete, isTrue);
      expect(snapshot.favorites, {1, 3});
      expect(snapshot.completed, {1});
      expect(snapshot.positions[1], const Duration(seconds: 42));
      expect(snapshot.reminderEnabled, isTrue);
      expect(snapshot.reminderTime, const TimeOfDay(hour: 7, minute: 30));
    },
  );

  test('reset keeps preferences owned by Supabase Auth', () async {
    SharedPreferences.setMockInitialValues({
      'supabase.auth.token': 'anonymous-session',
    });
    final storage = AppStorage();
    await storage.saveOnboarding(DateTime(2026, 7, 11));

    await storage.reset();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('supabase.auth.token'), 'anonymous-session');
    expect((await storage.load()).onboardingComplete, isFalse);
  });
}
