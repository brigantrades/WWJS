import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class ReminderScheduler {
  set onReminderTapped(VoidCallback? handler);
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleDaily(TimeOfDay time);
  Future<void> cancel();
}

class NotificationService implements ReminderScheduler {
  static const _dailyReminderId = 730;
  static const _dailyReminderPayload = 'daily_prayer';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  VoidCallback? _onReminderTapped;

  @override
  set onReminderTapped(VoidCallback? handler) {
    _onReminderTapped = handler;
  }

  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;
      if (response != null) _handleNotificationResponse(response);
    }

    tz.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  @override
  Future<void> scheduleDaily(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'Your two minutes with Jesus are ready',
      body: 'Step away from distractions and spend a quiet moment with Him.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_prayer',
          'Daily prayer reminder',
          channelDescription: 'A gentle reminder for your chosen prayer time.',
          icon: 'ic_notification',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _dailyReminderPayload,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.id == _dailyReminderId ||
        response.payload == _dailyReminderPayload) {
      _onReminderTapped?.call();
    }
  }

  @override
  Future<void> cancel() => _plugin.cancel(id: _dailyReminderId);
}

class NoopReminderScheduler implements ReminderScheduler {
  @override
  set onReminderTapped(VoidCallback? handler) {}
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDaily(TimeOfDay time) async {}
  @override
  Future<void> cancel() async {}
}
