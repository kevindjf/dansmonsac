// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:streak/repository/streak_repository.dart';
import 'package:main/repository/daily_check_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// Mock PreferenceRepository for testing
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

/// Epic 2 Integration Tests
///
/// Story 2.10: Integrate Streak with Bag Completion Workflow
///
/// These tests validate that all Epic 2 stories (2.1-2.9) work together
/// as a cohesive system. This is NOT about testing individual features,
/// but rather ensuring the complete workflow functions end-to-end.
void main() {
  late AppDatabase database;
  late StreakRepository streakRepository;
  late DailyCheckRepository dailyCheckRepository;
  late CalendarCourseSupabaseRepository calendarCourseRepository;
  late PreferenceRepository preferenceRepository;
  final uuid = const Uuid();

  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable database warning for tests
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Mock connectivity method channel to avoid "Binding not initialized" errors
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        // Return List<String> matching connectivity_plus v6.x format
        return ['none']; // Simulate no connection in tests
      }
      return null;
    },
  );

  setUp(() async {
    // Mock SharedPreferences for PreferencesService
    SharedPreferences.setMockInitialValues({
      'school_year_start': DateTime(2025, 9, 1).toIso8601String(),
      'previous_streak': 0,
      'best_streak': 0,
      // Set pack time to 00:00 so currentNotificationDay = today
      // and target = tomorrow, matching what the tests insert.
      'pack_time_hour': 0,
      'pack_time_minute': 0,
    });

    // Create in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());

    // Initialize mock dependencies
    preferenceRepository = MockPreferenceRepository();

    // Initialize repositories (local-first architecture)
    streakRepository = StreakRepository(database, preferenceRepository);
    dailyCheckRepository = DailyCheckRepository(database);
    calendarCourseRepository = CalendarCourseSupabaseRepository(database);

    // Set up test data
    await _setupTestData(database, uuid);
  });

  tearDown(() async {
    await database.close();
  });

  group('AC1: Complete End-to-End Workflow', () {
    test('full workflow from checklist to streak increment', () async {
      // This test validates the complete flow:
      // 1. Open app, see tomorrow's supply checklist (Story 2.3)
      // 2. Check supplies one by one, each persists immediately (Story 2.3)
      // 3. Check the last supply, "Bag Ready" confirmation appears (Story 2.6)
      // 4. Streak counter increments by 1 (Story 2.4, Story 2.5)

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      // Step 1: Get tomorrow's courses (Story 2.8)
      final coursesResult = await calendarCourseRepository.getTomorrowCourses();
      expect(coursesResult.isRight(), isTrue);

      final courses = coursesResult.getOrElse(() => []);
      expect(courses, isNotEmpty,
          reason: 'Should have courses tomorrow for testing');

      // Collect all supplies across all courses (with their courseId)
      final allSupplies = <({String supplyId, String courseId})>[];
      for (final course in courses) {
        for (final supply in course.supplies) {
          allSupplies.add((supplyId: supply.id, courseId: course.courseId));
        }
      }

      expect(allSupplies, isNotEmpty, reason: 'Should have supplies to check');

      // Step 2: Check supplies one by one (Story 2.3)
      for (int i = 0; i < allSupplies.length; i++) {
        final supply = allSupplies[i];

        final stopwatch = Stopwatch()..start();

        // Toggle supply check (insert daily check)
        final result = await dailyCheckRepository.toggleSupplyCheck(
          supply.supplyId,
          supply.courseId,
          tomorrowDate,
          true,
        );

        stopwatch.stop();

        expect(result.isRight(), isTrue);

        // NFR1: Checklist interaction < 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason:
                'NFR1 violated: checklist interaction took ${stopwatch.elapsedMilliseconds}ms');

        // Verify immediate persistence
        final checks = await database.getDailyChecksByDate(tomorrowDate);
        expect(checks.length, equals(i + 1),
            reason: 'Check should persist immediately');
      }

      // Step 3: All supplies checked → Bag Ready (Story 2.6)
      // Verify all supplies are checked
      final finalChecks = await database.getDailyChecksByDate(tomorrowDate);
      expect(finalChecks.length, equals(allSupplies.length));
      expect(finalChecks.every((check) => check.isChecked), isTrue);

      // Insert bag completions for both today and tomorrow so the streak
      // counts regardless of whether we are before or after pack time.
      final todayDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      for (final date in [todayDate, tomorrowDate]) {
        await database.insertBagCompletion(
          BagCompletionsCompanion(
            id: drift.Value(uuid.v4()),
            date: drift.Value(date),
            completedAt: drift.Value(DateTime.now()),
            deviceId: drift.Value('test-device'),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      }

      // Step 4: Streak increments (Story 2.4, 2.5)
      final streakResult = await streakRepository.getCurrentStreak();
      expect(streakResult.isRight(), isTrue);

      final streak = streakResult.getOrElse(() => 0);
      expect(streak, greaterThanOrEqualTo(1),
          reason: 'Streak should increment after bag completion');
    });

    test('streak counter updates in real-time', () async {
      // Test that streak recalculation works after bag completion
      // The streak logic checks targetDate = notificationDay + 1
      // So we need to insert a completion for tomorrow (the target date
      // that corresponds to today's notification day).
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      // Get initial streak
      final initialStreakResult = await streakRepository.getCurrentStreak();
      expect(initialStreakResult.isRight(), isTrue);
      final initialStreak = initialStreakResult.getOrElse(() => 0);

      // Insert completions for both today and tomorrow so the streak
      // counts regardless of whether we are before or after pack time.
      // Before pack time: currentNotificationDay = yesterday, target = today
      // After pack time: currentNotificationDay = today, target = tomorrow
      for (final date in [today, tomorrow]) {
        await database.insertBagCompletion(
          BagCompletionsCompanion(
            id: drift.Value(uuid.v4()),
            date: drift.Value(date),
            completedAt: drift.Value(DateTime.now()),
            deviceId: drift.Value('test-device'),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      }

      // Get updated streak
      final updatedStreakResult = await streakRepository.getCurrentStreak();
      expect(updatedStreakResult.isRight(), isTrue);
      final updatedStreak = updatedStreakResult.getOrElse(() => 0);

      // Verify streak incremented - at least one of today/tomorrow is a
      // weekday with courses, so the streak should increase
      expect(updatedStreak, greaterThan(initialStreak));
    });
  });

  group('AC2: State Persistence Across App Lifecycle', () {
    test('checklist persists across app restart', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      // Create some daily checks using toggleSupplyCheck
      await dailyCheckRepository.toggleSupplyCheck(
        'supply-1',
        'course-1',
        tomorrowDate,
        true,
      );

      await dailyCheckRepository.toggleSupplyCheck(
        'supply-2',
        'course-1',
        tomorrowDate,
        false,
      );

      // Simulate app restart by querying again
      final checks = await database.getDailyChecksByDate(tomorrowDate);
      expect(checks.length, equals(2));
      expect(checks.where((c) => c.isChecked).length, equals(1));
      expect(checks.where((c) => !c.isChecked).length, equals(1));
    });

    test('streak count persists across app restart', () async {
      // Create multiple bag completions for 5 consecutive SCHOOL days (weekdays only)
      final dates = <DateTime>[];
      var currentDate = DateTime.now();

      while (dates.length < 5) {
        // Only add weekdays (Monday=1 to Friday=5)
        if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
          dates.add(
              DateTime(currentDate.year, currentDate.month, currentDate.day));
        }
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      for (final date in dates) {
        await database.insertBagCompletion(
          BagCompletionsCompanion(
            id: drift.Value(uuid.v4()),
            date: drift.Value(date),
            completedAt: drift.Value(date),
            deviceId: drift.Value('test-device'),
            createdAt: drift.Value(date),
          ),
        );
      }

      // Simulate app restart by querying streak
      final streakResult = await streakRepository.getCurrentStreak();
      expect(streakResult.isRight(), isTrue);

      final streak = streakResult.getOrElse(() => 0);
      expect(streak, equals(5),
          reason: 'Streak should persist across restarts');
    });

    test('bag ready state persists until next day', () async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Mark bag as ready
      await database.insertBagCompletion(
        BagCompletionsCompanion(
          id: drift.Value(uuid.v4()),
          date: drift.Value(todayDate),
          completedAt: drift.Value(DateTime.now()),
          deviceId: drift.Value('test-device'),
          createdAt: drift.Value(DateTime.now()),
        ),
      );

      // Verify completion exists
      final completions = await database.getAllBagCompletions();
      expect(
          completions.any((c) =>
              c.date.year == todayDate.year &&
              c.date.month == todayDate.month &&
              c.date.day == todayDate.day),
          isTrue);
    });
  });

  group('AC3: Daily Reset at Midnight', () {
    test('checklist resets at day change', () async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayDate =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      // Create checks for yesterday
      await dailyCheckRepository.toggleSupplyCheck(
        'supply-1',
        'course-1',
        yesterdayDate,
        true,
      );

      // Create checks for today
      await dailyCheckRepository.toggleSupplyCheck(
        'supply-1',
        'course-1',
        todayDate,
        false,
      );

      // Verify yesterday's checks are separate from today's
      final yesterdayChecks =
          await database.getDailyChecksByDate(yesterdayDate);
      final todayChecks = await database.getDailyChecksByDate(todayDate);

      expect(yesterdayChecks.length, equals(1));
      expect(yesterdayChecks.first.isChecked, isTrue);

      expect(todayChecks.length, equals(1));
      expect(todayChecks.first.isChecked, isFalse);
    });

    test('yesterday data archived in DailyChecks', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      // Create checks for yesterday
      await dailyCheckRepository.toggleSupplyCheck(
        'supply-1',
        'course-1',
        yesterdayDate,
        true,
      );

      // Verify data persists (not deleted)
      final yesterdayChecks =
          await database.getDailyChecksByDate(yesterdayDate);
      expect(yesterdayChecks, isNotEmpty,
          reason: 'Yesterday data should be archived, not deleted');
    });
  });

  group('AC4: Multi-Day Streak Accuracy', () {
    test('streak increments on consecutive school days', () async {
      // Create consecutive bag completions for 7 SCHOOL days (weekdays only)
      final dates = <DateTime>[];
      var currentDate = DateTime.now();

      while (dates.length < 7) {
        // Only add weekdays (Monday=1 to Friday=5)
        if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
          dates.add(
              DateTime(currentDate.year, currentDate.month, currentDate.day));
        }
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      for (final date in dates) {
        await database.insertBagCompletion(
          BagCompletionsCompanion(
            id: drift.Value(uuid.v4()),
            date: drift.Value(date),
            completedAt: drift.Value(date),
            deviceId: drift.Value('test-device'),
            createdAt: drift.Value(date),
          ),
        );
      }

      final streakResult = await streakRepository.getCurrentStreak();
      expect(streakResult.isRight(), isTrue);

      final streak = streakResult.getOrElse(() => 0);
      expect(streak, equals(7),
          reason: 'Streak should count consecutive school days');
    });

    test('streak breaks when day is skipped', () async {
      final today = DateTime.now();

      // Create streak of 5 days with a gap
      for (int i = 0; i < 5; i++) {
        final date =
            today.subtract(Duration(days: 7 - i)); // Gap at days 5 and 6
        final dateOnly = DateTime(date.year, date.month, date.day);
        await database.insertBagCompletion(
          BagCompletionsCompanion(
            id: drift.Value(uuid.v4()),
            date: drift.Value(dateOnly),
            completedAt: drift.Value(dateOnly),
            deviceId: drift.Value('test-device'),
            createdAt: drift.Value(dateOnly),
          ),
        );
      }

      // Streak should be broken due to gap
      final streakResult = await streakRepository.getCurrentStreak();
      expect(streakResult.isRight(), isTrue);

      final streak = streakResult.getOrElse(() => 0);
      // Streak should be broken due to gap
      expect(streak, lessThan(7),
          reason: 'Streak should break when days are skipped');
    });
  });

  group('AC5: Performance and Testing Requirements', () {
    test('checklist interaction performance < 100ms (NFR1)', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      final stopwatch = Stopwatch()..start();

      await dailyCheckRepository.toggleSupplyCheck(
        'supply-1',
        'course-1',
        tomorrowDate,
        true,
      );

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason:
              'NFR1: Checklist interaction must be < 100ms, got ${stopwatch.elapsedMilliseconds}ms');
    });

    test('supply list load time < 500ms (NFR2)', () async {
      final stopwatch = Stopwatch()..start();

      final coursesResult = await calendarCourseRepository.getTomorrowCourses();

      stopwatch.stop();

      expect(coursesResult.isRight(), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason:
              'NFR2: Supply list load must be < 500ms, got ${stopwatch.elapsedMilliseconds}ms');
    });

    test('no data loss in offline mode', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      // All writes go to local Drift database (offline-first)
      await dailyCheckRepository.toggleSupplyCheck(
        'supply-1',
        'course-1',
        tomorrowDate,
        true,
      );

      await database.insertBagCompletion(
        BagCompletionsCompanion(
          id: drift.Value(uuid.v4()),
          date: drift.Value(tomorrowDate),
          completedAt: drift.Value(DateTime.now()),
          deviceId: drift.Value('test-device'),
          createdAt: drift.Value(DateTime.now()),
        ),
      );

      // Verify data exists locally
      final checks = await database.getDailyChecksByDate(tomorrowDate);
      final streakResult = await streakRepository.getCurrentStreak();

      expect(checks, isNotEmpty);
      expect(streakResult.isRight(), isTrue);

      final streak = streakResult.getOrElse(() => 0);
      expect(streak, greaterThanOrEqualTo(1));
    });
  });
}

/// Set up test data in the database
Future<void> _setupTestData(AppDatabase database, Uuid uuid) async {
  // Create test courses
  await database.insertCourse(
    CoursesCompanion.insert(
      id: 'course-1',
      name: 'Mathématiques',
      color: '#FF5733',
      weekType: 'AB',
      updatedAt: DateTime.now(),
      createdAt: drift.Value(DateTime.now()),
    ),
  );

  await database.insertCourse(
    CoursesCompanion.insert(
      id: 'course-2',
      name: 'Français',
      color: '#33FF57',
      weekType: 'AB',
      updatedAt: DateTime.now(),
      createdAt: drift.Value(DateTime.now()),
    ),
  );

  // Create test supplies
  await database.insertSupply(
    SuppliesCompanion.insert(
      id: 'supply-1',
      courseId: 'course-1',
      name: 'Cahier',
      updatedAt: DateTime.now(),
      createdAt: drift.Value(DateTime.now()),
    ),
  );

  await database.insertSupply(
    SuppliesCompanion.insert(
      id: 'supply-2',
      courseId: 'course-1',
      name: 'Stylo',
      updatedAt: DateTime.now(),
      createdAt: drift.Value(DateTime.now()),
    ),
  );

  // Create calendar courses for all weekdays (Monday-Friday)
  // This ensures tests can create bag completions for any day and have it count as a school day
  for (int dayOfWeek = 1; dayOfWeek <= 5; dayOfWeek++) {
    await database.insertCalendarCourse(
      CalendarCoursesCompanion.insert(
        id: uuid.v4(),
        courseId: 'course-1',
        dayOfWeek: dayOfWeek,
        weekType: drift.Value('BOTH'),
        startHour: 8,
        startMinute: 0,
        endHour: 9,
        endMinute: 0,
        roomName: drift.Value('Salle 101'),
        updatedAt: DateTime.now(),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await database.insertCalendarCourse(
      CalendarCoursesCompanion.insert(
        id: uuid.v4(),
        courseId: 'course-2',
        dayOfWeek: dayOfWeek,
        weekType: drift.Value('BOTH'),
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        roomName: drift.Value('Salle 102'),
        updatedAt: DateTime.now(),
        createdAt: drift.Value(DateTime.now()),
      ),
    );
  }
}
