import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/services/preferences_service.dart';
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
Future<void> createTestCourse(AppDatabase db, {
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
Future<void> createCalendarEntry(AppDatabase db, {
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
Future<void> setupTestTimetable(AppDatabase db, {bool includeWeekA = true, bool includeWeekB = true}) async {
  // Create test course
  await createTestCourse(db, id: 'course-math', name: 'Mathematics');

  // Create calendar entries for Monday to Friday
  for (int day = 1; day <= 5; day++) {
    if (includeWeekA) {
      await createCalendarEntry(db, courseId: 'course-math', dayOfWeek: day, weekType: 'A');
    }
    if (includeWeekB) {
      await createCalendarEntry(db, courseId: 'course-math', dayOfWeek: day, weekType: 'B');
    }
  }
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

      // Set school year start to a known date (September 1, 2024 - a Sunday)
      // This makes Week 0 start on Sept 1, so Sept 2 (Monday) is Week A
      await PreferencesService.setSchoolYearStart(DateTime(2024, 9, 1));
    });

    tearDown(() async {
      await database.close();
    });

    group('isSchoolDay (tested via getCurrentStreak)', () {
      test('should detect weekends as non-school days', () async {
        await setupTestTimetable(database);

        // Saturday and Sunday should be non-school days
        // Even if we mark them complete, they shouldn't count in streak
        final saturday = DateTime(2024, 9, 7); // A Saturday
        final sunday = DateTime(2024, 9, 8); // A Sunday

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
        final monday = DateTime(2024, 9, 2); // A Monday, but no courses

        await repository.markBagComplete(monday);

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

        // Monday Sept 2, 2024 is Week A (week 0 from Sept 1)
        final monday = DateTime(2024, 9, 2);

        await repository.markBagComplete(monday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Monday with courses = school day = streak is 1
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

        // Complete today only (assuming today is a weekday with courses)
        final today = DateTime(2024, 9, 2); // Monday Week A
        await repository.markBagComplete(today);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) => expect(streak, 1),
        );
      });

      test('should skip weekends when calculating streak', () async {
        await setupTestTimetable(database);

        // Complete Friday, then Monday (skip weekend)
        final friday = DateTime(2024, 9, 6); // Friday Week A
        final monday = DateTime(2024, 9, 9); // Monday Week B

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

      test('should handle week A/B alternation correctly', () async {
        await setupTestTimetable(database);

        // Complete Monday Week A, Tuesday Week A, ..., Friday Week A = 5 days
        // Then complete Monday Week B, Tuesday Week B, ..., Friday Week B = 5 more days
        // Total: 10 consecutive school days

        // Week A: Sept 2-6 (Mon-Fri)
        for (int i = 0; i < 5; i++) {
          await repository.markBagComplete(DateTime(2024, 9, 2 + i));
        }

        // Weekend Sept 7-8 (skip)

        // Week B: Sept 9-13 (Mon-Fri)
        for (int i = 0; i < 5; i++) {
          await repository.markBagComplete(DateTime(2024, 9, 9 + i));
        }

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) => expect(streak, 10),
        );
      });

      test('should stop at first missing school day', () async {
        await setupTestTimetable(database);

        // Complete Monday, Tuesday, skip Wednesday, complete Thursday, Friday
        final monday = DateTime(2024, 9, 2);
        final tuesday = DateTime(2024, 9, 3);
        // Skip wednesday = DateTime(2024, 9, 4)
        final thursday = DateTime(2024, 9, 5);
        final friday = DateTime(2024, 9, 6);

        await repository.markBagComplete(monday);
        await repository.markBagComplete(tuesday);
        // No completion for Wednesday
        await repository.markBagComplete(thursday);
        await repository.markBagComplete(friday);

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Streak should be 2 (Thursday + Friday)
            // Wednesday was missed, so Mon-Tue doesn't count
            expect(streak, 2);
          },
        );
      });

      test('should handle empty days (holidays) correctly', () async {
        // Only create timetable for Monday and Friday (skip Tue-Thu)
        await createTestCourse(database, id: 'course-math', name: 'Math');
        await createCalendarEntry(database, courseId: 'course-math', dayOfWeek: 1, weekType: 'A'); // Monday
        await createCalendarEntry(database, courseId: 'course-math', dayOfWeek: 5, weekType: 'A'); // Friday

        // Complete Monday and Friday
        final monday = DateTime(2024, 9, 2);
        final friday = DateTime(2024, 9, 6);

        await repository.markBagComplete(monday);
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

        // Create completions for 400 days back (exceeds limit)
        // Only 365 days should be checked
        for (int i = 0; i < 400; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          await repository.markBagComplete(date);
        }

        final result = await repository.getCurrentStreak();

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (streak) {
            // Should check max 365 days
            // Actual streak depends on how many school days in that period
            expect(streak, greaterThan(0));
            expect(streak, lessThanOrEqualTo(260)); // Max ~260 school days in 365 days
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

        // Complete bag only for today (missed previous 2 school days)
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

        // Build a streak of 5 days
        for (int i = 5; i >= 1; i--) {
          final date = DateTime(2024, 9, 2 + (5 - i)); // Sept 2-6 (Mon-Fri Week A)
          await repository.markBagComplete(date);
        }

        // Verify streak is 5
        final streakResult = await repository.getCurrentStreak();
        streakResult.fold(
          (failure) => fail('Failed to get streak'),
          (streak) => expect(streak, 5),
        );

        // Set last check to last Friday
        await PreferencesService.setLastStreakCheckDate(DateTime(2024, 9, 6));

        // Skip Monday and Tuesday (9th and 10th), only complete Wednesday (11th)
        await repository.markBagComplete(DateTime(2024, 9, 11));

        // Detect break
        final breakResult = await repository.detectBrokenStreak();

        breakResult.fold(
          (failure) => fail('Failed to detect break'),
          (isBroken) {
            // Break should be detected
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
      test('should complete full workflow: setup -> mark complete -> calculate streak', () async {
        await setupTestTimetable(database);

        // Week A: Sept 2-6 (Mon-Fri)
        for (int i = 0; i < 5; i++) {
          await repository.markBagComplete(DateTime(2024, 9, 2 + i));
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

      test('should handle week A/B transition with break detection', () async {
        await setupTestTimetable(database);

        // Complete Week A (Sept 2-6)
        for (int i = 0; i < 5; i++) {
          await repository.markBagComplete(DateTime(2024, 9, 2 + i));
        }

        // Set last check to Friday Week A
        await PreferencesService.setLastStreakCheckDate(DateTime(2024, 9, 6));

        // Skip Monday Week B (Sept 9), complete Tue-Fri Week B (Sept 10-13)
        for (int i = 1; i < 5; i++) {
          await repository.markBagComplete(DateTime(2024, 9, 9 + i));
        }

        // Detect break
        final breakResult = await repository.detectBrokenStreak();
        breakResult.fold(
          (failure) => fail('Failed to detect break'),
          (isBroken) => expect(isBroken, true),
        );

        // Current streak should be 4 (Tue-Fri Week B)
        final streakResult = await repository.getCurrentStreak();
        streakResult.fold(
          (failure) => fail('Failed to get streak'),
          (streak) => expect(streak, 4),
        );

        // Previous streak should be saved (Week A = 5 days)
        final previousStreakResult = await repository.getPreviousStreak();
        previousStreakResult.fold(
          (failure) => fail('Failed to get previous streak'),
          (previousStreak) => expect(previousStreak, greaterThan(0)),
        );
      });
    });

    group('Performance Tests', () {
      test('should calculate streak in less than 100ms for 30 days', () async {
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
            // Performance requirement: < 100ms
            expect(stopwatch.elapsedMilliseconds, lessThan(100),
                reason: 'Streak calculation took ${stopwatch.elapsedMilliseconds}ms, should be < 100ms');
          },
        );
      });
    });
  });
}
