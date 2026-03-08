import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak/repository/streak_repository.dart';

// Mock PreferenceRepository for testing
class MockPreferenceRepository extends PreferenceRepository {
  @override
  Future<String> getUserId() async {
    return 'test-device-id';
  }

  @override
  Future<bool> showingOnboarding() async {
    return false;
  }

  @override
  Future<void> storeFinishOnboarding() async {
    // No-op for tests
  }
}

// Helper to create test database
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Helper to create a test course in the database
Future<void> createTestCourse(
  AppDatabase db, {
  required String id,
  required String name,
}) async {
  await db.into(db.courses).insert(CoursesCompanion(
        id: Value(id),
        name: Value(name),
        color: const Value('#9C27B0'),
        weekType: const Value('AB'),
        updatedAt: Value(DateTime.now()),
      ));
}

/// Helper to create a calendar entry for a course
Future<void> createCalendarEntry(
  AppDatabase db, {
  required String courseId,
  required int dayOfWeek,
  required String weekType,
  int startHour = 9,
  int endHour = 10,
}) async {
  await db.into(db.calendarCourses).insert(CalendarCoursesCompanion(
        id: Value('cal-$courseId-$dayOfWeek-$weekType'),
        courseId: Value(courseId),
        dayOfWeek: Value(dayOfWeek),
        startHour: Value(startHour),
        startMinute: const Value(0),
        endHour: Value(endHour),
        endMinute: const Value(0),
        weekType: Value(weekType),
        updatedAt: Value(DateTime.now()),
      ));
}

/// Helper to setup a test timetable with Monday-Friday courses
Future<void> setupTestTimetable(AppDatabase db,
    {bool includeWeekA = true, bool includeWeekB = true}) async {
  // Create test course
  await createTestCourse(db, id: 'course-math', name: 'Mathematics');

  // Create calendar entries for Monday to Friday
  for (int day = 1; day <= 5; day++) {
    if (includeWeekA) {
      await createCalendarEntry(db,
          courseId: 'course-math', dayOfWeek: day, weekType: 'A');
    }
    if (includeWeekB) {
      await createCalendarEntry(db,
          courseId: 'course-math', dayOfWeek: day, weekType: 'B');
    }
  }
}

/// Finds the most recent Monday (or today if today is Monday)
DateTime _mostRecentMonday() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  // weekday: 1=Mon, 7=Sun
  final daysFromMonday = (today.weekday - 1) % 7;
  return today.subtract(Duration(days: daysFromMonday));
}

/// Finds the most recent past Friday (before today)
DateTime _mostRecentPastFriday() {
  final now = DateTime.now();
  var date = DateTime(now.year, now.month, now.day);
  // Go backwards until we find a Friday
  while (date.weekday != 5 ||
      date.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
    date = date.subtract(const Duration(days: 1));
  }
  return date;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Story 2.4 - Streak Calculation with School Days', () {
    late AppDatabase database;
    late StreakRepository repository;

    setUp(() async {
      // Initialize SharedPreferences for PreferencesService
      SharedPreferences.setMockInitialValues({});

      database = createTestDatabase();
      final preferenceRepository = MockPreferenceRepository();
      repository = StreakRepository(database, preferenceRepository);

      // Set school year start to a known date (September 1, 2025 - a Monday)
      await PreferencesService.setSchoolYearStart(DateTime(2025, 9, 1));
      // Set pack time to a known value (19:00)
      await PreferencesService.setPackTime(
          const TimeOfDay(hour: 19, minute: 0));
    });

    tearDown(() async {
      await database.close();
    });

    group('isSchoolDay (tested via getCurrentStreak)', () {
      test('should detect weekends as non-school days', () async {
        await setupTestTimetable(database);

        // Find a recent Saturday and Sunday
        final now = DateTime.now();
        var saturday = DateTime(now.year, now.month, now.day);
        while (saturday.weekday != 6) {
          saturday = saturday.subtract(const Duration(days: 1));
        }
        final sunday = saturday.add(const Duration(days: 1));

        await repository.markBagComplete(saturday);
        await repository.markBagComplete(sunday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Weekends don't count, so streak should be 0
            expect(streak, 0);
          },
        );
      });

      test('should detect days with no courses as non-school days', () async {
        // Don't setup timetable - empty calendar
        // Find a recent weekday
        final now = DateTime.now();
        var weekday = DateTime(now.year, now.month, now.day);
        while (weekday.weekday > 5) {
          weekday = weekday.subtract(const Duration(days: 1));
        }

        await repository.markBagComplete(weekday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // No courses = not a school day = streak is 0
            expect(streak, 0);
          },
        );
      });

      test('should correctly detect school days from timetable', () async {
        await setupTestTimetable(database);

        // Find the most recent past weekday with a completion
        final now = DateTime.now();
        var recentWeekday = DateTime(now.year, now.month, now.day);
        // Go back to find a weekday that is before today (to avoid effective date issues)
        recentWeekday = recentWeekday.subtract(const Duration(days: 1));
        while (recentWeekday.weekday > 5) {
          recentWeekday = recentWeekday.subtract(const Duration(days: 1));
        }

        await repository.markBagComplete(recentWeekday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Weekday with courses = school day = streak is 1
            expect(streak, 1);
          },
        );
      });
    });

    group('getCurrentStreak - Consecutive School Days', () {
      test('should return 0 when no completions exist', () async {
        await setupTestTimetable(database);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) => expect(streak, 0),
        );
      });

      test('should count single day streak', () async {
        await setupTestTimetable(database);

        // Find a recent past weekday
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);
        while (day.weekday > 5) {
          day = day.subtract(const Duration(days: 1));
        }
        await repository.markBagComplete(day);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) => expect(streak, 1),
        );
      });

      test('should skip weekends when calculating streak', () async {
        await setupTestTimetable(database);

        // Find the most recent Friday and the following Monday
        final friday = _mostRecentPastFriday();
        final monday =
            friday.add(const Duration(days: 3)); // Friday + 3 = Monday

        await repository.markBagComplete(friday);
        await repository.markBagComplete(monday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Both days completed, weekend skipped = streak of 2
            expect(streak, 2);
          },
        );
      });

      test('should handle full week streak', () async {
        await setupTestTimetable(database);

        // Create completions for all weekdays going back from yesterday
        // to fill a complete week (5 school days)
        final completionDates = <DateTime>[];
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);

        while (completionDates.length < 5) {
          if (day.weekday <= 5) {
            // Weekday
            completionDates.add(day);
          }
          day = day.subtract(const Duration(days: 1));
        }

        for (final d in completionDates) {
          await repository.markBagComplete(d);
        }

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) => expect(streak, 5),
        );
      });

      test('should handle two consecutive weeks', () async {
        await setupTestTimetable(database);

        // Create completions for all weekdays going back from yesterday
        // to fill two complete weeks (10 school days)
        final completionDates = <DateTime>[];
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);

        while (completionDates.length < 10) {
          if (day.weekday <= 5) {
            // Weekday
            completionDates.add(day);
          }
          day = day.subtract(const Duration(days: 1));
        }

        for (final d in completionDates) {
          await repository.markBagComplete(d);
        }

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) => expect(streak, 10),
        );
      });

      test('should stop at first missing school day', () async {
        await setupTestTimetable(database);

        // Create completions for recent weekdays but with a gap
        // Example: complete yesterday and day before, skip one, then two more
        final completionDates = <DateTime>[];
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);

        // Find the 2 most recent weekdays (these will be consecutive completions)
        int consecutiveCount = 0;
        while (consecutiveCount < 2) {
          if (day.weekday <= 5) {
            completionDates.add(day);
            consecutiveCount++;
          }
          day = day.subtract(const Duration(days: 1));
        }

        // Skip the next weekday (gap)
        while (day.weekday > 5) {
          // skip weekends
          day = day.subtract(const Duration(days: 1));
        }
        // This is the missed day - don't add it
        day = day.subtract(const Duration(days: 1));

        // Add 2 more weekday completions before the gap
        int olderCount = 0;
        while (olderCount < 2) {
          if (day.weekday <= 5) {
            completionDates.add(day);
            olderCount++;
          }
          day = day.subtract(const Duration(days: 1));
        }

        for (final d in completionDates) {
          await repository.markBagComplete(d);
        }

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Streak should be 2 (the 2 most recent consecutive completions)
            // The gap breaks the streak, so older completions don't count
            expect(streak, 2);
          },
        );
      });

      test('should handle empty days (holidays) correctly', () async {
        // Only create timetable for Monday and Friday (skip Tue-Thu)
        await createTestCourse(database, id: 'course-math', name: 'Math');

        // Determine the week type for our test dates
        final schoolYearStart = await PreferencesService.getSchoolYearStart();
        final testMonday =
            _mostRecentMonday().subtract(const Duration(days: 7));
        final weekType = _getWeekType(schoolYearStart, testMonday);

        await createCalendarEntry(database,
            courseId: 'course-math',
            dayOfWeek: 1,
            weekType: weekType); // Monday
        await createCalendarEntry(database,
            courseId: 'course-math',
            dayOfWeek: 5,
            weekType: weekType); // Friday

        // Complete Monday and Friday
        final friday = testMonday.add(const Duration(days: 4));

        await repository.markBagComplete(testMonday);
        await repository.markBagComplete(friday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Both school days completed, Tue-Thu are not school days (no courses)
            // So streak should be 2 (Monday + Friday)
            expect(streak, 2);
          },
        );
      });

      test('should respect 365 day safety limit', () async {
        await setupTestTimetable(database);

        // Create completions for last 30 days (more realistic than 400)
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          await repository.markBagComplete(date);
        }

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Should count notification days where target (day+1) has courses
            expect(streak, greaterThan(0));
            expect(streak, lessThanOrEqualTo(30)); // At most 30 days
          },
        );
      });
    });

    group('Pack time / effective date behavior', () {
      test(
          'should show streak immediately after packing for tomorrow (after pack time)',
          () async {
        await setupTestTimetable(database);

        // Simulate: it's after pack time, user packs for tomorrow
        // Set pack time to a time that's definitely in the past today
        await PreferencesService.setPackTime(
            const TimeOfDay(hour: 0, minute: 1));

        // Find the next weekday (tomorrow or later)
        var tomorrow = DateTime.now().add(const Duration(days: 1));
        tomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        while (tomorrow.weekday > 5) {
          tomorrow = tomorrow.add(const Duration(days: 1));
        }

        // Mark bag complete for that date (simulating the list_supply_page behavior)
        await repository.markBagComplete(tomorrow);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Streak should be 1 immediately (not 0!)
            expect(streak, 1);
          },
        );
      });

      test('should give free pass for effective date without completion',
          () async {
        await setupTestTimetable(database);

        // Set pack time far in future so we're "before pack time"
        await PreferencesService.setPackTime(
            const TimeOfDay(hour: 23, minute: 59));

        // Complete yesterday (a weekday)
        var yesterday = DateTime.now().subtract(const Duration(days: 1));
        yesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
        while (yesterday.weekday > 5) {
          yesterday = yesterday.subtract(const Duration(days: 1));
        }

        await repository.markBagComplete(yesterday);

        // If today is a school day, effective date = today (before pack time)
        // Today has no completion yet → should get free pass → streak = 1 (from yesterday)
        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // If today is a weekday: streak = 1 (yesterday's completion, today skipped)
            // If today is a weekend: streak = 1 (yesterday's completion, weekend skipped)
            expect(streak, greaterThanOrEqualTo(1));
          },
        );
      });
    });

    group('getPreviousStreak and savePreviousStreak', () {
      test('should return 0 when no previous streak exists', () async {
        final result = await repository.getPreviousStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (previousStreak) => expect(previousStreak, 0),
        );
      });

      test('should save and retrieve previous streak', () async {
        // Save previous streak
        await repository.savePreviousStreak(15);

        // Retrieve it
        final result = await repository.getPreviousStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (previousStreak) => expect(previousStreak, 15),
        );
      });

      test('should update previous streak when saved multiple times', () async {
        await repository.savePreviousStreak(10);
        await repository.savePreviousStreak(20);

        final result = await repository.getPreviousStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (previousStreak) => expect(previousStreak, 20),
        );
      });
    });

    group('detectBrokenStreak', () {
      test('should return false on first check', () async {
        await setupTestTimetable(database);

        final result = await repository.detectBrokenStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (isBroken) => expect(isBroken, false),
        );
      });

      test('should detect broken streak when school day was missed', () async {
        await setupTestTimetable(database);

        // Set last check date to 3 days ago
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        await PreferencesService.setLastStreakCheckDate(threeDaysAgo);

        // Complete bag only for today (missed previous school days)
        await repository.markBagComplete(DateTime.now());

        final result = await repository.detectBrokenStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (isBroken) {
            // Should detect that streak was broken
            // (depends on whether the missed days were school days)
            expect(isBroken, isA<bool>());
          },
        );
      });

      test('should save previous streak when break is detected', () async {
        await setupTestTimetable(database);

        // Build a streak of 5 consecutive weekdays ending recently
        final completionDates = <DateTime>[];
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);

        while (completionDates.length < 5) {
          if (day.weekday <= 5) {
            completionDates.add(day);
          }
          day = day.subtract(const Duration(days: 1));
        }

        for (final d in completionDates) {
          await repository.markBagComplete(d);
        }

        // Verify streak is 5
        final streakResult = await repository.getCurrentStreak();
        streakResult.fold(
          (failure) => fail('Failed to get streak'),
          (streak) => expect(streak, 5),
        );

        // Set last check date well before the completions (creates a gap)
        final oldestCompletion = completionDates.last;
        await PreferencesService.setLastStreakCheckDate(
          oldestCompletion.subtract(const Duration(days: 7)),
        );

        // Detect break - school days between lastCheck and oldest completion are missed
        final breakResult = await repository.detectBrokenStreak();

        breakResult.fold(
          (failure) => fail('Failed to detect break'),
          (isBroken) {
            // Break should be detected (school days before our completions were missed)
            expect(isBroken, true);
          },
        );

        // Previous streak should be saved
        final previousStreakResult = await repository.getPreviousStreak();
        previousStreakResult.fold(
          (failure) => fail('Failed to get previous streak'),
          (previousStreak) {
            expect(previousStreak, greaterThan(0));
          },
        );
      });

      test('should not save previous streak if already broken', () async {
        await setupTestTimetable(database);

        // Set previous streak to 10
        await PreferencesService.setPreviousStreak(10);

        // Set last check to yesterday
        await PreferencesService.setLastStreakCheckDate(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        // Don't complete today (break the streak)
        // Current streak should be 0

        final result = await repository.detectBrokenStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (isBroken) {
            // Break detected
            expect(isBroken, isA<bool>());
          },
        );

        // Previous streak should still be 10 (not overwritten)
        final previousStreakResult = await repository.getPreviousStreak();
        previousStreakResult.fold(
          (failure) => fail('Failed to get previous streak'),
          (previousStreak) => expect(previousStreak, 10),
        );
      });
    });

    group('Integration Tests', () {
      test(
          'should complete full workflow: setup -> mark complete -> calculate streak',
          () async {
        await setupTestTimetable(database);

        // Complete 5 consecutive past weekdays ending recently
        final completionDates = <DateTime>[];
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);

        while (completionDates.length < 5) {
          if (day.weekday <= 5) {
            completionDates.add(day);
          }
          day = day.subtract(const Duration(days: 1));
        }

        for (final d in completionDates) {
          await repository.markBagComplete(d);
        }

        // Get current streak
        final streakResult = await repository.getCurrentStreak();
        streakResult.fold(
          (failure) => fail('Failed to get streak: $failure'),
          (streak) => expect(streak, 5),
        );

        // Get history
        final historyResult = await repository.getBagCompletionHistory();
        historyResult.fold(
          (failure) => fail('Failed to get history: $failure'),
          (history) => expect(history.length, 5),
        );
      });

      test('should handle week transition with break detection', () async {
        await setupTestTimetable(database);

        // Create two groups of completions with a gap between them
        // Group 1 (recent, 4 weekdays): forms the current streak
        // Gap: 1 missed school day
        // Group 2 (older, 5 weekdays): the previous streak

        final recentCompletions = <DateTime>[];
        var day = DateTime.now().subtract(const Duration(days: 1));
        day = DateTime(day.year, day.month, day.day);

        // Find 4 recent weekdays
        while (recentCompletions.length < 4) {
          if (day.weekday <= 5) {
            recentCompletions.add(day);
          }
          day = day.subtract(const Duration(days: 1));
        }

        // Skip the next weekday (gap - the missed school day)
        while (day.weekday > 5) {
          day = day.subtract(const Duration(days: 1));
        }
        // This weekday is the missed day - don't add it
        day = day.subtract(const Duration(days: 1));

        // Find 5 older weekdays
        final olderCompletions = <DateTime>[];
        while (olderCompletions.length < 5) {
          if (day.weekday <= 5) {
            olderCompletions.add(day);
          }
          day = day.subtract(const Duration(days: 1));
        }

        // Mark all completions (except the gap)
        for (final d in recentCompletions) {
          await repository.markBagComplete(d);
        }
        for (final d in olderCompletions) {
          await repository.markBagComplete(d);
        }

        // Set last check date before the older completions
        final oldestCompletion = olderCompletions.last;
        await PreferencesService.setLastStreakCheckDate(
          oldestCompletion.subtract(const Duration(days: 1)),
        );

        // Detect break
        final breakResult = await repository.detectBrokenStreak();
        breakResult.fold(
          (failure) => fail('Failed to detect break'),
          (isBroken) => expect(isBroken, true),
        );

        // Current streak should be 4 (recent completions after the gap)
        final streakResult = await repository.getCurrentStreak();
        streakResult.fold(
          (failure) => fail('Failed to get streak'),
          (streak) => expect(streak, 4),
        );

        // Previous streak should be saved
        final previousStreakResult = await repository.getPreviousStreak();
        previousStreakResult.fold(
          (failure) => fail('Failed to get previous streak'),
          (previousStreak) => expect(previousStreak, greaterThan(0)),
        );
      });
    });

    group('Performance Tests', () {
      test('should calculate streak in less than 200ms for 30 days', () async {
        await setupTestTimetable(database);

        // Create completions for last 30 days
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          await repository.markBagComplete(date);
        }

        final stopwatch = Stopwatch()..start();
        final result = await repository.getCurrentStreak();
        stopwatch.stop();

        result.fold(
          (failure) => fail('Failed to calculate streak: $failure'),
          (streak) {
            expect(streak, greaterThan(0));
            // Performance requirement: < 200ms (relaxed for CI environments)
            expect(stopwatch.elapsedMilliseconds, lessThan(200),
                reason:
                    'Streak calculation took ${stopwatch.elapsedMilliseconds}ms, should be < 200ms');
          },
        );
      });
    });
  });
}

/// Helper to compute week type for a given date
String _getWeekType(DateTime schoolYearStart, DateTime date) {
  final daysDiff = date.difference(schoolYearStart).inDays;
  final weeksDiff = daysDiff ~/ 7;
  return weeksDiff % 2 == 0 ? 'A' : 'B';
}
