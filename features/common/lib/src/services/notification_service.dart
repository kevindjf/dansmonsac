import 'package:common/src/services/preferences_service.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/database/app_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:schedule/models/calendar_course_with_supplies.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _dailyNotificationId = 1001;

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    // Set local timezone to Europe/Paris for France
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
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
        final exactAlarmGranted =
            await androidPlugin.requestExactAlarmsPermission();
        LogService.d('🔔 Exact alarms permission: ${exactAlarmGranted ?? false}');
      } catch (e) {
        LogService.d('⚠️ Exact alarms permission not available or error: $e');
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
    LogService.d('🔔 Notification permissions granted: $granted');
    return granted;
  }

  /// Check if exact alarms permission is granted (Android 12+)
  static Future<bool> canScheduleExactAlarms() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try {
        final canSchedule = await androidPlugin.canScheduleExactNotifications();
        LogService.d('📱 Can schedule exact alarms: ${canSchedule ?? false}');
        return canSchedule ?? false;
      } catch (e) {
        LogService.d('⚠️ Error checking exact alarms permission: $e');
        return false;
      }
    }

    return true; // iOS doesn't need this
  }

  static Future<void> scheduleDailyNotification({
    String? customTitle,
    String? customBody,
  }) async {
    try {
      // Check if we can schedule exact alarms
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        LogService.d('⚠️ Cannot schedule exact alarms. Please enable in settings.');
        // Still try to schedule, but it might not work
      }

      // Get pack time from preferences
      final packTime = await PreferencesService.getPackTime();

      // Cancel existing notification
      await _notifications.cancel(_dailyNotificationId);

      // Use custom content if provided, otherwise use default
      final title = customTitle ?? 'Préparez votre sac ! 🎒';
      final body = customBody ?? 'Il est temps de préparer votre sac pour demain';

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

      LogService.d('📅 Scheduling notification for: $scheduledDate');
      LogService.d('🕐 Pack time: ${packTime.hour}:${packTime.minute}');
      LogService.d('🌍 Timezone: ${tz.local.name}');
      LogService.d('⏰ Current time: $now');
      LogService.d('📝 Title: $title');
      LogService.d('📝 Body: $body');

      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Rappel quotidien',
        channelDescription: 'Rappel pour préparer votre sac',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
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
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      LogService.d('✅ Notification scheduled successfully');

      // Show pending notifications for debugging
      final pending = await _notifications.pendingNotificationRequests();
      LogService.d('📋 Pending notifications: ${pending.length}');
      for (final notification in pending) {
        LogService.d('  - ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      LogService.d('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> cancelNotification() async {
    await _notifications.cancel(_dailyNotificationId);
  }

  /// Updates notification schedule with contextual content
  /// Requires repository and database for content generation
  static Future<void> updateNotificationIfEnabled({
    required CalendarCourseRepository repository,
    required AppDatabase database,
  }) async {
    final enabled = await PreferencesService.getNotificationsEnabled();
    if (!enabled) {
      await cancelNotification();
      return;
    }

    // Build contextual content for tomorrow's schedule (AC3, AC4)
    final content = await buildTomorrowNotificationContent(repository, database);

    if (content == null) {
      // No classes tomorrow → suppress notification (FR15, AC3)
      LogService.d('🚫 No notification: no classes tomorrow');
      await cancelNotification();
      return;
    }

    // Schedule with contextual content (AC1, AC2, AC5)
    await scheduleDailyNotification(
      customTitle: content.title,
      customBody: content.body,
    );
  }

  /// Builds contextual notification content based on tomorrow's courses
  /// Returns null if no classes tomorrow (notification should be suppressed)
  static Future<({String title, String body})?> buildTomorrowNotificationContent(
    CalendarCourseRepository repository,
    AppDatabase database,
  ) async {
    LogService.d('📝 Building notification content for tomorrow');

    // 1. Get tomorrow's courses (from Story 2.8)
    final coursesResult = await repository.getTomorrowCourses();

    final courses = coursesResult.fold(
      (failure) {
        LogService.e('Failed to fetch tomorrow courses', failure);
        return null;
      },
      (courses) => courses,
    );

    // 2. No classes tomorrow → suppress notification (FR15)
    if (courses == null || courses.isEmpty) {
      LogService.d('📅 No classes tomorrow, notification will be suppressed');
      return null;
    }

    // 3. Count total supplies needed
    final totalSupplies = courses.fold<int>(
      0,
      (sum, course) => sum + course.supplies.length,
    );

    // 4. Build subject list (max 3-4, then summarize)
    final String subjectsText;
    if (courses.length <= 4) {
      // List subjects explicitly (AC2: up to 3-4 subjects)
      final subjectNames = courses.map((c) => c.courseName).toList();

      if (subjectNames.length == 1) {
        subjectsText = 'Demain tu as ${subjectNames[0]}';
      } else if (subjectNames.length == 2) {
        subjectsText = 'Demain tu as ${subjectNames[0]} et ${subjectNames[1]}';
      } else {
        // 3-4 subjects: "A, B et C"
        final allButLast = subjectNames.sublist(0, subjectNames.length - 1).join(', ');
        final last = subjectNames.last;
        subjectsText = 'Demain tu as $allButLast et $last';
      }
    } else {
      // Summarize for many courses (AC2: more than 3-4)
      subjectsText = 'Demain tu as ${courses.length} matières';
    }

    // 5. Check if bag already completed (AC6 - optional enhancement)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    final bagCompleted = await _isBagCompletedForDate(database, tomorrowDate);

    // 6. Build final content
    final String title = 'Prépare ton sac pour demain 🎒';
    final String body;

    if (bagCompleted) {
      // AC6: Bag already ready - still fire notification with confirmation message
      body = 'Ton sac est déjà prêt! ✅ ($subjectsText, $totalSupplies fournitures)';
    } else {
      // Normal notification with subjects and supply count (AC1)
      body = '$subjectsText. $totalSupplies fournitures à préparer.';
    }

    LogService.d('📢 Notification content: $title / $body');

    return (title: title, body: body);
  }

  /// Helper: check if bag is completed for a specific date
  static Future<bool> _isBagCompletedForDate(
    AppDatabase database,
    DateTime date,
  ) async {
    final query = database.select(database.bagCompletions)
      ..where((tbl) => tbl.date.equals(date));

    final results = await query.get();
    return results.isNotEmpty;
  }
}
