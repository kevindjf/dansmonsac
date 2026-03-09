import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:common/src/utils/week_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:streak/models/week_day_status.dart';

/// Repository for streak tracking and bag completion management
///
/// Responsibilities:
/// - Calculate current streak (consecutive school days with bag completion)
/// - Access bag completion history
/// - Mark bag as complete for a given date
class StreakRepository {
  static const _uuid =
      Uuid(); // Singleton UUID generator for better performance

  final AppDatabase _database;
  final PreferenceRepository _preferenceRepository;

  StreakRepository(this._database, this._preferenceRepository);

  /// Get the current streak count
  ///
  /// Counts consecutive "notification days" where the user packed their bag.
  ///
  /// Key concept: the streak is based on NOTIFICATION DAYS (the day pack time fires),
  /// not target dates. A BagCompletion with date=Monday means "packed on Sunday evening"
  /// → Sunday (notification day) is validated.
  ///
  /// - After pack time: current notification day = today (notification just fired)
  /// - Before pack time: current notification day = yesterday (still in yesterday's window)
  /// - A notification day D is "relevant" if D+1 (target) has courses
  /// - If D+1 has no courses, D is skipped (doesn't break streak)
  /// - Current notification day gets a "free pass" (window still open)
  /// - Safety limit of 365 days
  Future<Either<Failure, int>> getCurrentStreak() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getCurrentStreak: Calculating streak');

      // Get all bag completions (target dates)
      final completions = await _database.getAllBagCompletions();
      final completedTargetDates = completions.map((c) {
        final d = c.date;
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      LogService.d(
          'StreakRepository.getCurrentStreak: Found ${completedTargetDates.length} completions');

      if (completedTargetDates.isEmpty) {
        LogService.d(
            'StreakRepository.getCurrentStreak: No completions, streak = 0');
        return 0;
      }

      // Determine current notification day
      // After pack time: today (notification just fired, window open)
      // Before pack time: yesterday (in yesterday's notification window)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final packTime = await PreferencesService.getPackTime();
      final isAfterPackTime = now.hour > packTime.hour ||
          (now.hour == packTime.hour && now.minute >= packTime.minute);

      final currentNotificationDay =
          isAfterPackTime ? today : today.subtract(const Duration(days: 1));

      LogService.d(
          'StreakRepository.getCurrentStreak: currentNotificationDay=$currentNotificationDay, isAfterPackTime=$isAfterPackTime');

      // Walk backward from current notification day
      var day = currentNotificationDay;
      int streak = 0;
      int daysChecked = 0;
      bool isCurrentDay = true;
      const maxDays = 365;

      while (daysChecked < maxDays) {
        final targetDate = day.add(const Duration(days: 1));

        // First check if target has courses (is it a relevant pack day?)
        final isTargetSchoolDay = await _isSchoolDay(targetDate);

        if (!isTargetSchoolDay) {
          // Target has no courses - nothing to pack for, skip entirely
          // (doesn't count, doesn't break, even if there's a completion)
          LogService.d(
              'StreakRepository.getCurrentStreak: Day $day skipped ($targetDate has no courses)');
          day = day.subtract(const Duration(days: 1));
          daysChecked++;
          continue;
        }

        // Target has courses - this is a relevant pack day
        if (completedTargetDates.contains(targetDate)) {
          // User packed for this target → notification day validated
          streak++;
          LogService.d(
              'StreakRepository.getCurrentStreak: Day $day validated (packed for $targetDate), streak=$streak');
        } else if (isCurrentDay) {
          // Current notification window still open - free pass
          LogService.d(
              'StreakRepository.getCurrentStreak: Day $day is current notification day, free pass');
        } else {
          // Target had courses but user didn't pack → streak breaks
          LogService.d(
              'StreakRepository.getCurrentStreak: Day $day breaks streak ($targetDate missed)');
          break;
        }

        isCurrentDay = false;
        day = day.subtract(const Duration(days: 1));
        daysChecked++;
      }

      LogService.d(
          'StreakRepository.getCurrentStreak: Final streak = $streak days');
      return streak;
    });
  }

  /// Get bag completion history
  ///
  /// Returns a list of dates when the bag was marked as complete.
  Future<Either<Failure, List<DateTime>>> getBagCompletionHistory() {
    return handleErrors(() async {
      LogService.d(
          'StreakRepository.getBagCompletionHistory: Fetching history');

      final completions = await _database.getAllBagCompletions();

      final dates = completions.map((c) => c.date).toList();

      LogService.d(
          'StreakRepository.getBagCompletionHistory: Found ${dates.length} completions');
      return dates;
    });
  }

  /// Mark bag as complete for a given date
  ///
  /// Creates a new BagCompletion entry for the specified date.
  /// If an entry already exists for this date, it will not create a duplicate.
  ///
  /// [date] - The date for which to mark bag as complete
  Future<Either<Failure, void>> markBagComplete(DateTime date) {
    return handleErrors(() async {
      LogService.d(
          'StreakRepository.markBagComplete: Marking bag complete for $date');

      // Normalize date to start of day (remove time component)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check if completion already exists for this date
      final existingCompletion =
          await _database.getBagCompletionByDate(normalizedDate);

      if (existingCompletion != null) {
        LogService.d(
            'StreakRepository.markBagComplete: Completion already exists for $normalizedDate');
        return; // Already completed, no need to insert again
      }

      // Get device ID from preferences
      final deviceId = await _preferenceRepository.getUserId();

      // Create new completion entry
      final companion = BagCompletionsCompanion(
        id: drift.Value(_uuid.v4()),
        date: drift.Value(normalizedDate),
        completedAt: drift.Value(DateTime.now()),
        deviceId: drift.Value(deviceId),
        createdAt: drift.Value(DateTime.now()),
      );

      await _database.insertBagCompletion(companion);

      LogService.d(
          'StreakRepository.markBagComplete: Bag marked complete for $normalizedDate');
    });
  }

  /// Determines if a given date is a school day
  ///
  /// Returns true if the date has scheduled courses, false for:
  /// - Weekends (Saturday=6, Sunday=7)
  /// - Days with no courses in the timetable
  /// - Holidays (detected by empty timetable)
  ///
  /// This method is used by streak calculation to skip non-school days.
  Future<bool> _isSchoolDay(DateTime date) async {
    LogService.d(
        'StreakRepository._isSchoolDay: === START CHECK FOR $date ===');

    // 1. Check vacation mode FIRST (takes precedence over everything)
    final isVacationMode = await PreferencesService.isVacationModeActive();
    if (isVacationMode) {
      LogService.d(
          'StreakRepository._isSchoolDay: Vacation mode active → FALSE');
      return false;
    }

    // 2. Normalize date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    LogService.d(
        'StreakRepository._isSchoolDay: Normalized date = $normalizedDate');

    // 3. Check if weekend (Saturday=6, Sunday=7 in ISO 8601)
    final dayOfWeek = normalizedDate.weekday;
    LogService.d(
        'StreakRepository._isSchoolDay: dayOfWeek = $dayOfWeek (1=Mon, 7=Sun)');

    if (dayOfWeek == 6 || dayOfWeek == 7) {
      LogService.d(
          'StreakRepository._isSchoolDay: $normalizedDate is weekend (day=$dayOfWeek) → FALSE');
      return false; // Weekends are not school days
    }

    // 4. Get week type (A or B) using WeekUtils
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    LogService.d(
        'StreakRepository._isSchoolDay: schoolYearStart = $schoolYearStart');

    final weekType =
        WeekUtils.getCurrentWeekType(schoolYearStart, normalizedDate);
    LogService.d(
        'StreakRepository._isSchoolDay: weekType calculated = $weekType');

    LogService.d(
        'StreakRepository._isSchoolDay: Querying DB with dayOfWeek=$dayOfWeek, weekType=$weekType');

    // 5. Query calendar_courses for this day and week type
    final courses =
        await _database.getCalendarCoursesByDayAndWeek(dayOfWeek, weekType);

    // 6. If no courses, it's not a school day (holiday or empty day)
    final isSchoolDay = courses.isNotEmpty;
    LogService.d(
        'StreakRepository._isSchoolDay: Found ${courses.length} courses');
    LogService.d(
        'StreakRepository._isSchoolDay: === RESULT: $normalizedDate isSchoolDay=$isSchoolDay ===');

    return isSchoolDay;
  }

  /// Gets the previous streak value (before last break)
  ///
  /// Returns 0 if no previous streak exists.
  Future<Either<Failure, int>> getPreviousStreak() {
    return handleErrors(() async {
      LogService.d(
          'StreakRepository.getPreviousStreak: Fetching previous streak');

      final previousStreak = await PreferencesService.getPreviousStreak();

      LogService.d(
          'StreakRepository.getPreviousStreak: Previous streak = $previousStreak');
      return previousStreak;
    });
  }

  /// Saves the previous streak value
  ///
  /// Called when a streak break is detected to preserve the previous streak count.
  Future<Either<Failure, void>> savePreviousStreak(int streakValue) {
    return handleErrors(() async {
      LogService.d(
          'StreakRepository.savePreviousStreak: Saving previous streak = $streakValue');

      await PreferencesService.setPreviousStreak(streakValue);

      LogService.d(
          'StreakRepository.savePreviousStreak: Previous streak saved');
    });
  }

  /// Gets the best streak ever achieved
  ///
  /// Returns 0 if no best streak exists.
  Future<Either<Failure, int>> getBestStreak() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getBestStreak: Fetching best streak');

      final bestStreak = await PreferencesService.getBestStreak();

      LogService.d('StreakRepository.getBestStreak: Best streak = $bestStreak');
      return bestStreak;
    });
  }

  /// Detects if the streak was broken since last check
  ///
  /// Checks notification days between last check and now for missed pack days.
  /// A notification day D is "missed" if D+1 (target) has courses but no completion.
  /// If a break is detected, saves the current streak as previousStreak.
  ///
  /// This method should be called on app startup and when marking bag complete.
  Future<Either<Failure, bool>> detectBrokenStreak() {
    return handleErrors(() async {
      LogService.d(
          'StreakRepository.detectBrokenStreak: Checking for broken streak');

      // Get last check date
      final lastCheckDate = await PreferencesService.getLastStreakCheckDate();

      if (lastCheckDate == null) {
        // First time checking - no break possible
        await PreferencesService.setLastStreakCheckDate(DateTime.now());
        LogService.d(
            'StreakRepository.detectBrokenStreak: First check, no break');
        return false;
      }

      // Get current streak before checking for breaks
      final currentStreakResult = await getCurrentStreak();
      final currentStreak = currentStreakResult.fold(
        (failure) => 0,
        (streak) => streak,
      );

      // Determine current notification day
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final packTime = await PreferencesService.getPackTime();
      final isAfterPackTime = now.hour > packTime.hour ||
          (now.hour == packTime.hour && now.minute >= packTime.minute);
      final currentNotificationDay =
          isAfterPackTime ? today : today.subtract(const Duration(days: 1));

      final normalizedLastCheck = DateTime(
        lastCheckDate.year,
        lastCheckDate.month,
        lastCheckDate.day,
      );

      // Load all completions (target dates) for O(1) lookup
      final completions = await _database.getAllBagCompletions();
      final completedTargetDates = completions.map((c) {
        final d = c.date;
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      // Check notification days from lastCheck+1 to before currentNotificationDay
      // (don't check current notification day - window still open)
      var checkDay = normalizedLastCheck.add(const Duration(days: 1));
      bool streakWasBroken = false;

      while (checkDay.isBefore(currentNotificationDay)) {
        final targetDate = checkDay.add(const Duration(days: 1));

        if (!completedTargetDates.contains(targetDate)) {
          // No completion for target - check if target had courses
          final isTargetSchoolDay = await _isSchoolDay(targetDate);
          if (isTargetSchoolDay) {
            // Missed pack day → streak broken
            if (!streakWasBroken && currentStreak > 0) {
              await PreferencesService.setPreviousStreak(currentStreak);
              final currentBest = await PreferencesService.getBestStreak();
              if (currentStreak > currentBest) {
                await PreferencesService.setBestStreak(currentStreak);
                LogService.d(
                    'StreakRepository.detectBrokenStreak: New best streak=$currentStreak');
              }
              LogService.d(
                  'StreakRepository.detectBrokenStreak: Streak broken on $checkDay (missed $targetDate), saved previous=$currentStreak');
              streakWasBroken = true;
            }
          }
        }

        checkDay = checkDay.add(const Duration(days: 1));
      }

      // Update last check date
      await PreferencesService.setLastStreakCheckDate(DateTime.now());

      if (streakWasBroken) {
        LogService.d('StreakRepository.detectBrokenStreak: Streak was broken');
      } else {
        LogService.d('StreakRepository.detectBrokenStreak: No break detected');
      }

      return streakWasBroken;
    });
  }

  /// Gets the weekly streak data for the current week
  ///
  /// Returns a list of 7 WeekDayStatus entries (Monday to Sunday) representing
  /// the status of each NOTIFICATION DAY in the current week:
  /// - completed: User packed their bag (completion exists for day+1)
  /// - missed: Target had courses but user didn't pack
  /// - inactive: Target (day+1) has no courses (nothing to pack for)
  /// - future: Notification hasn't happened yet
  ///
  /// Each day represents: "did you respond to the notification on this day?"
  /// The notification on day D prepares for day D+1.
  Future<Either<Failure, List<WeekDayStatus>>> getWeeklyStreakData() {
    return handleErrors(() async {
      LogService.d(
          'StreakRepository.getWeeklyStreakData: Calculating weekly data');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get Monday of current week
      final daysFromMonday = now.weekday - 1;
      final monday = today.subtract(Duration(days: daysFromMonday));

      LogService.d(
          'StreakRepository.getWeeklyStreakData: Current week Monday = $monday');

      // Get all bag completions (target dates) for O(1) lookup
      final completions = await _database.getAllBagCompletions();
      final completedTargetDates = completions.map((c) {
        final d = c.date;
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      LogService.d(
          'StreakRepository.getWeeklyStreakData: Found ${completedTargetDates.length} completed target dates');

      // Determine current notification day
      final packTime = await PreferencesService.getPackTime();
      final isAfterPackTime = now.hour > packTime.hour ||
          (now.hour == packTime.hour && now.minute >= packTime.minute);

      final currentNotificationDay =
          isAfterPackTime ? today : today.subtract(const Duration(days: 1));

      LogService.d(
          'StreakRepository.getWeeklyStreakData: currentNotificationDay=$currentNotificationDay, isAfterPackTime=$isAfterPackTime');

      // Build status for each day (Mon-Sun)
      final statuses = <WeekDayStatus>[];

      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        final targetDate = day.add(const Duration(days: 1));

        LogService.d(
            'StreakRepository.getWeeklyStreakData: Day $day → target $targetDate');

        // 1. Check if target has courses (is this a relevant pack day?)
        final isTargetSchoolDay = await _isSchoolDay(targetDate);
        if (!isTargetSchoolDay) {
          // Nothing to pack for - day is inactive
          LogService.d(
              'StreakRepository.getWeeklyStreakData: $day inactive ($targetDate has no courses)');
          statuses.add(WeekDayStatus.inactive);
          continue;
        }

        // 2. Target has courses - check if user packed
        if (completedTargetDates.contains(targetDate)) {
          LogService.d(
              'StreakRepository.getWeeklyStreakData: $day completed (packed for $targetDate)');
          statuses.add(WeekDayStatus.completed);
          continue;
        }

        // 3. Target has courses but no completion
        if (day.isAfter(currentNotificationDay)) {
          LogService.d('StreakRepository.getWeeklyStreakData: $day is future');
          statuses.add(WeekDayStatus.future);
        } else if (day.isAtSameMomentAs(currentNotificationDay)) {
          LogService.d(
              'StreakRepository.getWeeklyStreakData: $day is current notification day, not packed yet');
          statuses.add(WeekDayStatus.future);
        } else {
          LogService.d('StreakRepository.getWeeklyStreakData: $day missed');
          statuses.add(WeekDayStatus.missed);
        }
      }

      LogService.d(
          'StreakRepository.getWeeklyStreakData: Weekly data = $statuses');
      return statuses;
    });
  }
}
