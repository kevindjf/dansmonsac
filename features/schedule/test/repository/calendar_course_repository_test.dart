import 'package:common/src/database/app_database.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedule/models/calendar_course_with_supplies.dart';
import 'package:schedule/repository/calendar_course_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply/models/supply.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late AppDatabase database;
  late CalendarCourseSupabaseRepository repository;
  late SupabaseClient mockSupabaseClient;
  late PreferenceRepository mockPreferenceRepository;

  setUpAll(() {
    // Initialize Flutter binding for SharedPreferences
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    // Mock SharedPreferences for PreferencesService
    SharedPreferences.setMockInitialValues({
      'school_year_start': DateTime(2025, 9, 1).toIso8601String(),
      'device_id': 'test-device-id',
      'pack_time_hour': 19,
      'pack_time_minute': 0,
    });

    // Create in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());

    // Note: Supabase client and preference repository not needed for getTomorrowCourses
    // (offline-first, uses only local Drift database)
    mockSupabaseClient = _MockSupabaseClient();
    mockPreferenceRepository = _MockPreferenceRepository();

    repository = CalendarCourseSupabaseRepository(
      mockSupabaseClient,
      mockPreferenceRepository,
      database,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('getTomorrowCourses', () {
    test('AC3: returns empty list for Saturday (weekend)', () async {
      // Arrange: Insert test data for Monday-Friday
      await _insertTestCourse(database, dayOfWeek: 1, courseName: 'Mathématiques');
      await _insertTestCourse(database, dayOfWeek: 5, courseName: 'Français');

      // TODO: Mock system date to Friday (tomorrow = Saturday)
      // Note: This test will fail until getTomorrowCourses() is implemented

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      final courses = result.getOrElse(() => []);
      expect(courses, isEmpty, reason: 'Saturday should return empty list');
    });

    test('AC3: returns empty list for Sunday (weekend)', () async {
      // Arrange: Insert test data
      await _insertTestCourse(database, dayOfWeek: 1, courseName: 'Histoire');

      // TODO: Mock system date to Saturday (tomorrow = Sunday)

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('AC4: returns empty list when no classes on weekday', () async {
      // Arrange: Insert courses only for Mon, Wed, Fri
      await _insertTestCourse(database, dayOfWeek: 1, courseName: 'Math');
      await _insertTestCourse(database, dayOfWeek: 3, courseName: 'Physics');
      await _insertTestCourse(database, dayOfWeek: 5, courseName: 'English');

      // TODO: Mock system date to Monday (tomorrow = Tuesday, no classes)

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty,
          reason: 'No classes on Tuesday should return empty list');
    });

    test('AC5: returns only week A courses on week A', () async {
      // Arrange: Insert courses with week types
      final mathId = await _insertTestCourse(
        database,
        dayOfWeek: 2, // Tuesday
        courseName: 'Mathématiques',
        weekType: 'A',
      );
      final physicsId = await _insertTestCourse(
        database,
        dayOfWeek: 2,
        courseName: 'Physique',
        weekType: 'B',
      );
      final englishId = await _insertTestCourse(
        database,
        dayOfWeek: 2,
        courseName: 'Anglais',
        weekType: 'BOTH',
      );

      // Add supplies
      await _insertTestSupply(database, mathId, 'Cahier de maths');
      await _insertTestSupply(database, physicsId, 'Cahier de physique');
      await _insertTestSupply(database, englishId, 'English book');

      // TODO: Mock system date to Monday of week A (tomorrow = Tuesday week A)

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      final courses = result.getOrElse(() => []);
      expect(courses.length, 2, reason: 'Week A: should return Math (A) and English (BOTH)');
      expect(courses.any((c) => c.courseName == 'Mathématiques'), true);
      expect(courses.any((c) => c.courseName == 'Anglais'), true);
      expect(courses.any((c) => c.courseName == 'Physique'), false,
          reason: 'Week B course should NOT appear on week A');
    });

    test('AC5: returns only week B courses on week B', () async {
      // Arrange
      final mathId = await _insertTestCourse(
        database,
        dayOfWeek: 3,
        courseName: 'Maths',
        weekType: 'A',
      );
      final historyId = await _insertTestCourse(
        database,
        dayOfWeek: 3,
        courseName: 'Histoire',
        weekType: 'B',
      );

      await _insertTestSupply(database, mathId, 'Cahier');
      await _insertTestSupply(database, historyId, 'Livre histoire');

      // TODO: Mock date to week B

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      final courses = result.getOrElse(() => []);
      expect(courses.length, 1);
      expect(courses.first.courseName, 'Histoire');
    });

    test('AC2: returns courses ordered by startHour', () async {
      // Arrange: Insert courses in random order
      final course1 = await _insertTestCourse(
        database,
        dayOfWeek: 1,
        courseName: 'Français',
        startHour: 10,
        startMinute: 0,
      );
      final course2 = await _insertTestCourse(
        database,
        dayOfWeek: 1,
        courseName: 'Maths',
        startHour: 8,
        startMinute: 0,
      );
      final course3 = await _insertTestCourse(
        database,
        dayOfWeek: 1,
        courseName: 'Anglais',
        startHour: 14,
        startMinute: 30,
      );

      await _insertTestSupply(database, course1, 'Supply 1');
      await _insertTestSupply(database, course2, 'Supply 2');
      await _insertTestSupply(database, course3, 'Supply 3');

      // TODO: Mock date to Sunday (tomorrow = Monday)

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      final courses = result.getOrElse(() => []);
      expect(courses.length, 3);
      expect(courses[0].courseName, 'Maths', reason: 'First class at 8:00');
      expect(courses[1].courseName, 'Français', reason: 'Second class at 10:00');
      expect(courses[2].courseName, 'Anglais', reason: 'Third class at 14:30');
    });

    test('AC2: groups supplies correctly by course', () async {
      // Arrange
      final mathId = await _insertTestCourse(
        database,
        dayOfWeek: 4, // Thursday
        courseName: 'Mathématiques',
      );

      // Add multiple supplies to the course
      await _insertTestSupply(database, mathId, 'Cahier de maths');
      await _insertTestSupply(database, mathId, 'Calculatrice');
      await _insertTestSupply(database, mathId, 'Compas');

      // TODO: Mock date to Wednesday (tomorrow = Thursday)

      // Act
      final result = await repository.getTomorrowCourses();

      // Assert
      expect(result.isRight(), true);
      final courses = result.getOrElse(() => []);
      expect(courses.length, 1);
      expect(courses.first.supplies.length, 3,
          reason: 'Course should have 3 supplies grouped together');
      expect(courses.first.supplies.map((s) => s.name).toList(),
          containsAll(['Cahier de maths', 'Calculatrice', 'Compas']));
    });

    test('AC1: query performance is under 500ms (NFR2)', () async {
      // Arrange: Insert realistic dataset
      for (int day = 1; day <= 5; day++) {
        for (int i = 0; i < 8; i++) {
          final courseId = await _insertTestCourse(
            database,
            dayOfWeek: day,
            courseName: 'Course $day-$i',
            startHour: 8 + i,
          );
          // Add 3 supplies per course
          await _insertTestSupply(database, courseId, 'Supply ${i * 3 + 1}');
          await _insertTestSupply(database, courseId, 'Supply ${i * 3 + 2}');
          await _insertTestSupply(database, courseId, 'Supply ${i * 3 + 3}');
        }
      }

      // Act
      final stopwatch = Stopwatch()..start();
      await repository.getTomorrowCourses();
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Query must complete in under 500ms (NFR2)');
    });
  });
}

// Helper functions

class _MockSupabaseClient extends SupabaseClient {
  _MockSupabaseClient() : super('https://test.supabase.co', 'test-key');
}

class _MockPreferenceRepository implements PreferenceRepository {
  @override
  Future<String> getUserId() async => 'test-device-id';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<String> _insertTestCourse(
  AppDatabase db, {
  required int dayOfWeek,
  required String courseName,
  String weekType = 'BOTH',
  int startHour = 8,
  int startMinute = 0,
  int endHour = 9,
  int endMinute = 0,
}) async {
  // Insert course first
  final courseId = 'course-${DateTime.now().microsecondsSinceEpoch}';
  final now = DateTime.now();
  await db.into(db.courses).insert(
        CoursesCompanion(
          id: Value(courseId),
          name: Value(courseName),
          color: Value('#FF0000'), // Required field
          weekType: Value('AB'), // Required field (A, B, or AB)
          updatedAt: Value(now),
        ),
      );

  // Insert calendar course
  final calendarId = 'cal-${DateTime.now().microsecondsSinceEpoch}';
  await db.into(db.calendarCourses).insert(
        CalendarCoursesCompanion(
          id: Value(calendarId),
          courseId: Value(courseId),
          dayOfWeek: Value(dayOfWeek),
          startHour: Value(startHour),
          startMinute: Value(startMinute),
          endHour: Value(endHour),
          endMinute: Value(endMinute),
          weekType: Value(weekType),
          roomName: Value('Room ${dayOfWeek}A'),
          updatedAt: Value(now),
        ),
      );

  // Add small delay to ensure unique IDs
  await Future.delayed(const Duration(milliseconds: 2));

  return courseId;
}

Future<void> _insertTestSupply(
  AppDatabase db,
  String courseId,
  String supplyName,
) async {
  final supplyId = 'supply-${DateTime.now().microsecondsSinceEpoch}';
  final now = DateTime.now();

  // Insert supply linked directly to course (no junction table)
  await db.into(db.supplies).insert(
        SuppliesCompanion(
          id: Value(supplyId),
          courseId: Value(courseId), // Direct foreign key
          name: Value(supplyName),
          updatedAt: Value(now),
        ),
      );

  // Add small delay to ensure unique timestamps
  await Future.delayed(const Duration(milliseconds: 2));
}
