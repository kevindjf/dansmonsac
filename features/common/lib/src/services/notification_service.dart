import 'package:common/src/services/preferences_service.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/database/app_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _baseNotificationId = 1001;
  static const int _maxScheduledDays = 14;
  // Reminder IDs start right after main IDs: 1015-1028
  static const int _reminderBaseId = _baseNotificationId + _maxScheduledDays;

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
        LogService.d(
            '🔔 Exact alarms permission: ${exactAlarmGranted ?? false}');
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

  /// Schedule a single fallback notification (used by onboarding before schedule is set up)
  static Future<void> scheduleDailyNotification({
    String? customTitle,
    String? customBody,
  }) async {
    try {
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        LogService.d(
            '⚠️ Cannot schedule exact alarms. Please enable in settings.');
      }

      final packTime = await PreferencesService.getPackTime();
      final title = customTitle ?? 'Préparez votre sac ! 🎒';
      final body =
          customBody ?? 'Il est temps de préparer votre sac pour demain';

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        packTime.hour,
        packTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _scheduleOneShot(
        id: _baseNotificationId,
        dateTime: scheduledDate,
        title: title,
        body: body,
      );

      LogService.d('✅ Fallback notification scheduled for: $scheduledDate');
    } catch (e) {
      LogService.d('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Cancel all scheduled notifications (main + streak reminders)
  static Future<void> cancelAllNotifications() async {
    for (int i = 0; i < _maxScheduledDays; i++) {
      await _notifications.cancel(_baseNotificationId + i);
      await _notifications.cancel(_reminderBaseId + i);
    }
  }

  /// Cancel only streak reminder notifications
  static Future<void> cancelStreakReminders() async {
    for (int i = 0; i < _maxScheduledDays; i++) {
      await _notifications.cancel(_reminderBaseId + i);
    }
  }

  static Future<void> cancelNotification() async {
    await cancelAllNotifications();
  }

  /// Main entry point: schedule smart notifications for the next 14 days.
  /// Skips days during vacation and days with no courses the next day.
  /// [currentStreak] is used for streak reminder notifications (1h30 after pack time).
  static Future<void> updateNotificationIfEnabled({
    required CalendarCourseRepository repository,
    required AppDatabase database,
    int currentStreak = 0,
  }) async {
    final enabled = await PreferencesService.getNotificationsEnabled();
    if (!enabled) {
      await cancelAllNotifications();
      return;
    }

    await _scheduleUpcomingNotifications(
      repository: repository,
      database: database,
      currentStreak: currentStreak,
    );
  }

  /// Schedule one-shot notifications for each of the next 14 days,
  /// skipping vacation days and days with no courses the next day.
  /// Also schedules streak reminders 1h30 later if streak >= 1.
  static Future<void> _scheduleUpcomingNotifications({
    required CalendarCourseRepository repository,
    required AppDatabase database,
    required int currentStreak,
  }) async {
    await cancelAllNotifications();

    final canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      LogService.d('⚠️ Cannot schedule exact alarms.');
    }

    final packTime = await PreferencesService.getPackTime();
    final isVacation = await PreferencesService.isVacationModeActive();
    final vacationEndDate = await PreferencesService.getVacationModeEndDate();
    final now = tz.TZDateTime.now(tz.local);

    LogService.d(
        '📅 Scheduling notifications for next $_maxScheduledDays days (streak: $currentStreak)');
    LogService.d(
        '🏖️ Vacation active: $isVacation, end date: $vacationEndDate');

    int scheduledMain = 0;
    int scheduledReminders = 0;

    for (int i = 0; i < _maxScheduledDays; i++) {
      final notifDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + i,
        packTime.hour,
        packTime.minute,
      );

      // Skip if notification time already passed
      if (notifDate.isBefore(now)) continue;

      // The school day we're preparing for (tomorrow relative to notification)
      final schoolDay = DateTime(notifDate.year, notifDate.month, notifDate.day)
          .add(const Duration(days: 1));

      // Skip if school day is still in vacation period
      if (_isDayInVacation(schoolDay, isVacation, vacationEndDate)) continue;

      // Build contextual content for the school day's courses
      final content = await _buildContentForDate(
        repository,
        database,
        schoolDay,
        checkBag: i == 0,
      );

      if (content == null) continue; // No courses that day

      // Schedule main notification at pack time
      await _scheduleOneShot(
        id: _baseNotificationId + i,
        dateTime: notifDate,
        title: content.title,
        body: content.body,
      );
      scheduledMain++;

      // Schedule streak reminder 1h30 later (only if streak >= 1)
      if (currentStreak >= 1) {
        final reminderDate =
            notifDate.add(const Duration(hours: 1, minutes: 30));

        // Don't schedule if reminder time already passed (for today)
        if (!reminderDate.isBefore(now)) {
          final reminderBody = currentStreak == 1
              ? 'Tu as commencé une série, ne t\'arrête pas ! Prépare ton sac.'
              : 'Tu as déjà $currentStreak jours d\'affilée ! Prépare ton sac.';

          await _scheduleOneShot(
            id: _reminderBaseId + i,
            dateTime: reminderDate,
            title: 'Ne perds pas ta streak ! 🔥',
            body: reminderBody,
          );
          scheduledReminders++;
        }
      }
    }

    LogService.d(
        '✅ Scheduled $scheduledMain main + $scheduledReminders reminders');

    // Debug: show pending notifications
    final pending = await _notifications.pendingNotificationRequests();
    LogService.d('📋 Pending notifications: ${pending.length}');
    for (final notification in pending) {
      LogService.d('  - ID: ${notification.id}, Title: ${notification.title}');
    }
  }

  /// Check if a day falls within the vacation period.
  /// [day] is the school day being checked (not the notification day).
  static bool _isDayInVacation(
    DateTime day,
    bool vacationActive,
    DateTime? vacationEndDate,
  ) {
    if (!vacationActive) return false;
    if (vacationEndDate == null)
      return true; // Manual vacation, all days blocked

    final dayOnly = DateTime(day.year, day.month, day.day);
    final endOnly = DateTime(
        vacationEndDate.year, vacationEndDate.month, vacationEndDate.day);
    return !dayOnly.isAfter(endOnly); // day <= endDate → still in vacation
  }

  /// Build notification content for courses on a specific date.
  /// Returns null if no courses on that date (notification should be suppressed).
  static Future<({String title, String body})?> _buildContentForDate(
    CalendarCourseRepository repository,
    AppDatabase database,
    DateTime date, {
    bool checkBag = false,
  }) async {
    final coursesResult = await repository.getCoursesForDate(date);

    final courses = coursesResult.fold(
      (failure) {
        LogService.e('Failed to fetch courses for $date', failure);
        return null;
      },
      (courses) => courses,
    );

    if (courses == null || courses.isEmpty) return null;

    // Count total supplies
    final totalSupplies = courses.fold<int>(
      0,
      (sum, course) => sum + course.supplies.length,
    );

    // Build subject list
    final String subjectsText;
    if (courses.length <= 4) {
      final names = courses.map((c) => c.courseName).toList();
      if (names.length == 1) {
        subjectsText = 'Demain tu as ${names[0]}';
      } else if (names.length == 2) {
        subjectsText = 'Demain tu as ${names[0]} et ${names[1]}';
      } else {
        final allButLast = names.sublist(0, names.length - 1).join(', ');
        subjectsText = 'Demain tu as $allButLast et ${names.last}';
      }
    } else {
      subjectsText = 'Demain tu as ${courses.length} matières';
    }

    final title = 'Prépare ton sac pour demain 🎒';
    String body;

    // Only check bag completion for today's notification (future days not packed yet)
    if (checkBag) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final bagCompleted = await _isBagCompletedForDate(database, dateOnly);
      if (bagCompleted) {
        body =
            'Ton sac est déjà prêt! ✅ ($subjectsText, $totalSupplies fournitures)';
        return (title: title, body: body);
      }
    }

    body = '$subjectsText. $totalSupplies fournitures à préparer.';
    return (title: title, body: body);
  }

  /// Public wrapper: builds content for tomorrow specifically
  static Future<({String title, String body})?>
      buildTomorrowNotificationContent(
    CalendarCourseRepository repository,
    AppDatabase database,
  ) async {
    LogService.d('📝 Building notification content for tomorrow');
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _buildContentForDate(repository, database, tomorrow, checkBag: true);
  }

  /// Schedule a single one-shot notification
  static Future<void> _scheduleOneShot({
    required int id,
    required tz.TZDateTime dateTime,
    required String title,
    required String body,
  }) async {
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
      id,
      title,
      body,
      dateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
