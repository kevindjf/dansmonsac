import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:common/src/services/preferences_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _dailyNotificationId = 0;

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    // Set local timezone to Europe/Paris for France
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    // Use ic_launcher as notification icon (available in all Android projects)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<bool> requestPermissions() async {
    // Request permissions for Android 13+ and iOS
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? androidGranted;
    bool? iosGranted;

    if (androidPlugin != null) {
      androidGranted = await androidPlugin.requestNotificationsPermission();

      // Request exact alarm permission for Android 12+
      try {
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        print('🔔 Exact alarms permission: ${exactAlarmGranted ?? false}');
      } catch (e) {
        print('⚠️ Exact alarms permission not available or error: $e');
      }
    }

    if (iosPlugin != null) {
      iosGranted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final granted = androidGranted ?? iosGranted ?? false;
    print('🔔 Notification permissions granted: $granted');
    return granted;
  }

  /// Check if exact alarms permission is granted (Android 12+)
  static Future<bool> canScheduleExactAlarms() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try {
        final canSchedule = await androidPlugin.canScheduleExactNotifications();
        print('📱 Can schedule exact alarms: ${canSchedule ?? false}');
        return canSchedule ?? false;
      } catch (e) {
        print('⚠️ Error checking exact alarms permission: $e');
        return false;
      }
    }

    return true; // iOS doesn't need this
  }

  static Future<void> scheduleDailyNotification() async {
    try {
      // Check if we can schedule exact alarms
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        print('⚠️ Cannot schedule exact alarms. Please enable in settings.');
        // Still try to schedule, but it might not work
      }

      // Get pack time from preferences
      final packTime = await PreferencesService.getPackTime();

      // Cancel existing notification
      await _notifications.cancel(_dailyNotificationId);

      // Schedule new notification
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        packTime.hour,
        packTime.minute,
      );

      // If the scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print('📅 Scheduling notification for: $scheduledDate');
      print('🕐 Pack time: ${packTime.hour}:${packTime.minute}');
      print('🌍 Timezone: ${tz.local.name}');
      print('⏰ Current time: $now');

      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Rappel quotidien',
        channelDescription: 'Rappel pour préparer votre sac',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        enableLights: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _dailyNotificationId,
        'Préparez votre sac ! 🎒',
        'Il est temps de préparer votre sac pour demain',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Notification scheduled successfully');

      // Show pending notifications for debugging
      final pending = await _notifications.pendingNotificationRequests();
      print('📋 Pending notifications: ${pending.length}');
      for (final notification in pending) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> cancelNotification() async {
    await _notifications.cancel(_dailyNotificationId);
  }

  static Future<void> updateNotificationIfEnabled() async {
    final enabled = await PreferencesService.getNotificationsEnabled();
    if (enabled) {
      await scheduleDailyNotification();
    } else {
      await cancelNotification();
    }
  }
}
