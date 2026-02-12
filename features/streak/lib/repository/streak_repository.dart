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
  static const _uuid = Uuid(); // Singleton UUID generator for better performance

  final AppDatabase _database;
  final PreferenceRepository _preferenceRepository;

  StreakRepository(this._database, this._preferenceRepository);

  /// Get the current streak count
  ///
  /// Returns the number of consecutive school days where the bag was completed.
  /// This method:
  /// - Starts from today and counts backwards
  /// - Only counts school days (skips weekends and days with no courses)
  /// - Stops at the first school day without bag completion
  /// - Has a safety limit of 365 days to prevent infinite loops
  Future<Either<Failure, int>> getCurrentStreak() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getCurrentStreak: Calculating school-day streak');

      // Get all bag completions
      final completions = await _database.getAllBagCompletions();

      // Convert to normalized date set for O(1) lookup
      final completedDates = completions.map((c) {
        final d = c.date;
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      // Start from today, or from the latest completion date if it's in the future
      // (handles preparing bag tonight for tomorrow's school day)
      var currentDate = DateTime.now();
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (completedDates.isNotEmpty) {
        final latestCompletion = completedDates.reduce(
          (a, b) => a.isAfter(b) ? a : b,
        );
        if (latestCompletion.isAfter(currentDate)) {
          currentDate = latestCompletion;
        }
      }

      int streak = 0;
      int daysChecked = 0;
      const maxDaysToCheck = 365; // Safety limit

      while (daysChecked < maxDaysToCheck) {
        // Check if this date is a school day
        final isSchool = await _isSchoolDay(currentDate);

        if (!isSchool) {
          // Not a school day, skip to previous day
          currentDate = currentDate.subtract(const Duration(days: 1));
          daysChecked++;
          continue;
        }

        // This is a school day - check if bag was completed
        if (completedDates.contains(currentDate)) {
          // Bag was completed, increment streak
          streak++;
          LogService.d('StreakRepository.getCurrentStreak: Day $currentDate completed (streak=$streak)');
        } else {
          // School day but bag not completed - streak is broken
          LogService.d('StreakRepository.getCurrentStreak: Day $currentDate NOT completed, streak ends at $streak');
          break;
        }

        // Move to previous day
        currentDate = currentDate.subtract(const Duration(days: 1));
        daysChecked++;
      }

      LogService.d('StreakRepository.getCurrentStreak: Final streak = $streak days');
      return streak;
    });
  }

  /// Get bag completion history
  ///
  /// Returns a list of dates when the bag was marked as complete.
  Future<Either<Failure, List<DateTime>>> getBagCompletionHistory() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getBagCompletionHistory: Fetching history');

      final completions = await _database.getAllBagCompletions();

      final dates = completions.map((c) => c.date).toList();

      LogService.d('StreakRepository.getBagCompletionHistory: Found ${dates.length} completions');
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
      LogService.d('StreakRepository.markBagComplete: Marking bag complete for $date');

      // Normalize date to start of day (remove time component)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check if completion already exists for this date
      final existingCompletion = await _database.getBagCompletionByDate(normalizedDate);

      if (existingCompletion != null) {
        LogService.d('StreakRepository.markBagComplete: Completion already exists for $normalizedDate');
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

      LogService.d('StreakRepository.markBagComplete: Bag marked complete for $normalizedDate');
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
    LogService.d('StreakRepository._isSchoolDay: === START CHECK FOR $date ===');

    // 1. Check vacation mode FIRST (takes precedence over everything)
    final isVacationMode = await PreferencesService.isVacationModeActive();
    if (isVacationMode) {
      LogService.d('StreakRepository._isSchoolDay: Vacation mode active → FALSE');
      return false;
    }

    // 2. Normalize date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    LogService.d('StreakRepository._isSchoolDay: Normalized date = $normalizedDate');

    // 3. Check if weekend (Saturday=6, Sunday=7 in ISO 8601)
    final dayOfWeek = normalizedDate.weekday;
    LogService.d('StreakRepository._isSchoolDay: dayOfWeek = $dayOfWeek (1=Mon, 7=Sun)');

    if (dayOfWeek == 6 || dayOfWeek == 7) {
      LogService.d('StreakRepository._isSchoolDay: $normalizedDate is weekend (day=$dayOfWeek) → FALSE');
      return false; // Weekends are not school days
    }

    // 4. Get week type (A or B) using WeekUtils
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    LogService.d('StreakRepository._isSchoolDay: schoolYearStart = $schoolYearStart');

    final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, normalizedDate);
    LogService.d('StreakRepository._isSchoolDay: weekType calculated = $weekType');

    LogService.d('StreakRepository._isSchoolDay: Querying DB with dayOfWeek=$dayOfWeek, weekType=$weekType');

    // 5. Query calendar_courses for this day and week type
    final courses = await _database.getCalendarCoursesByDayAndWeek(dayOfWeek, weekType);

    // 6. If no courses, it's not a school day (holiday or empty day)
    final isSchoolDay = courses.isNotEmpty;
    LogService.d('StreakRepository._isSchoolDay: Found ${courses.length} courses');
    LogService.d('StreakRepository._isSchoolDay: === RESULT: $normalizedDate isSchoolDay=$isSchoolDay ===');

    return isSchoolDay;
  }

  /// Gets the previous streak value (before last break)
  ///
  /// Returns 0 if no previous streak exists.
  Future<Either<Failure, int>> getPreviousStreak() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getPreviousStreak: Fetching previous streak');

      final previousStreak = await PreferencesService.getPreviousStreak();

      LogService.d('StreakRepository.getPreviousStreak: Previous streak = $previousStreak');
      return previousStreak;
    });
  }

  /// Saves the previous streak value
  ///
  /// Called when a streak break is detected to preserve the previous streak count.
  Future<Either<Failure, void>> savePreviousStreak(int streakValue) {
    return handleErrors(() async {
      LogService.d('StreakRepository.savePreviousStreak: Saving previous streak = $streakValue');

      await PreferencesService.setPreviousStreak(streakValue);

      LogService.d('StreakRepository.savePreviousStreak: Previous streak saved');
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
  /// Compares the last check date with today to detect missed school days.
  /// If a school day was missed, saves the current streak as previousStreak
  /// and returns true.
  ///
  /// This method should be called on app startup and when marking bag complete.
  Future<Either<Failure, bool>> detectBrokenStreak() {
    return handleErrors(() async {
      LogService.d('StreakRepository.detectBrokenStreak: Checking for broken streak');

      // Get last check date
      final lastCheckDate = await PreferencesService.getLastStreakCheckDate();

      if (lastCheckDate == null) {
        // First time checking - no break possible
        await PreferencesService.setLastStreakCheckDate(DateTime.now());
        LogService.d('StreakRepository.detectBrokenStreak: First check, no break');
        return false;
      }

      // Get current streak before checking for breaks
      final currentStreakResult = await getCurrentStreak();
      final currentStreak = currentStreakResult.fold(
        (failure) => 0,
        (streak) => streak,
      );

      // Normalize last check date
      final normalizedLastCheck = DateTime(
        lastCheckDate.year,
        lastCheckDate.month,
        lastCheckDate.day,
      );

      // Check if there are any school days between last check and today
      // that don't have bag completions
      var checkDate = normalizedLastCheck.add(const Duration(days: 1));
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      // Load all completions once for O(1) lookup (avoid N+1 queries)
      final completions = await _database.getAllBagCompletions();
      final completedDates = completions.map((c) {
        final d = c.date;
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      bool streakWasBroken = false;
      int lastValidStreak = currentStreak;

      while (checkDate.isBefore(normalizedToday) || checkDate.isAtSameMomentAs(normalizedToday)) {
        final isSchool = await _isSchoolDay(checkDate);

        if (isSchool) {
          // Found a school day - check if bag was completed
          final hasCompletion = completedDates.contains(checkDate);

          if (!hasCompletion) {
            // School day without completion - streak is broken
            if (!streakWasBroken && lastValidStreak > 0) {
              // Save the streak value before the break
              await PreferencesService.setPreviousStreak(lastValidStreak);
              // Update best streak if this was a new personal best
              final currentBest = await PreferencesService.getBestStreak();
              if (lastValidStreak > currentBest) {
                await PreferencesService.setBestStreak(lastValidStreak);
                LogService.d('StreakRepository.detectBrokenStreak: New best streak=$lastValidStreak');
              }
              LogService.d('StreakRepository.detectBrokenStreak: Streak broken on $checkDate, saved previous=$lastValidStreak');
              streakWasBroken = true;
            }
          }
        }

        checkDate = checkDate.add(const Duration(days: 1));
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
  /// the status of each day in the current week:
  /// - completed: Day with bag completion
  /// - missed: School day without completion (in the past)
  /// - inactive: Non-school day (weekend, holiday)
  /// - future: Day that hasn't happened yet
  ///
  /// This method is used by the weekly streak view to display visual indicators
  /// for each day of the week.
  Future<Either<Failure, List<WeekDayStatus>>> getWeeklyStreakData() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getWeeklyStreakData: Calculating weekly data');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get Monday of current week (weekday 1 = Monday in ISO 8601)
      final daysFromMonday = now.weekday - 1;
      final monday = today.subtract(Duration(days: daysFromMonday));

      LogService.d('StreakRepository.getWeeklyStreakData: Current week Monday = $monday');

      // Get all bag completions once for O(1) lookup
      final completions = await _database.getAllBagCompletions();
      final completedDates = completions.map((c) {
        final d = c.date;
        return DateTime(d.year, d.month, d.day);
      }).toSet();

      LogService.d('StreakRepository.getWeeklyStreakData: Found ${completedDates.length} completed dates');

      // Build status for each day (Mon-Sun)
      final statuses = <WeekDayStatus>[];

      for (int i = 0; i < 7; i++) {
        final date = monday.add(Duration(days: i));
        final dayOfWeek = date.weekday; // 1=Mon, 7=Sun

        LogService.d('StreakRepository.getWeeklyStreakData: Processing day $i: $date (weekday=$dayOfWeek)');

        // Check if date is in the future
        if (date.isAfter(today)) {
          LogService.d('StreakRepository.getWeeklyStreakData: Day $date is future');
          statuses.add(WeekDayStatus.future);
          continue;
        }

        // Check if it's a school day
        final isSchool = await _isSchoolDay(date);

        if (!isSchool) {
          // Non-school day (weekend, holiday)
          LogService.d('StreakRepository.getWeeklyStreakData: Day $date is inactive (no courses)');
          statuses.add(WeekDayStatus.inactive);
          continue;
        }

        // School day - check if completed
        if (completedDates.contains(date)) {
          LogService.d('StreakRepository.getWeeklyStreakData: Day $date is completed');
          statuses.add(WeekDayStatus.completed);
        } else {
          LogService.d('StreakRepository.getWeeklyStreakData: Day $date is missed');
          statuses.add(WeekDayStatus.missed);
        }
      }

      LogService.d('StreakRepository.getWeeklyStreakData: Weekly data = $statuses');
      return statuses;
    });
  }
}
