import 'package:clock/clock.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:common/src/utils/week_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:schedule/models/calendar_course_with_supplies.dart';
import 'package:supply/models/supply.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class CalendarCourseRepository {
  Future<Either<Failure, CalendarCourse>> addCalendarCourse(CalendarCourse calendarCourse);
  Future<Either<Failure, void>> updateCalendarCourse(CalendarCourse calendarCourse);
  Future<Either<Failure, List<CalendarCourse>>> fetchCalendarCourses();
  Future<Either<Failure, void>> deleteCalendarCourse(String id);

  /// Gets all courses scheduled for tomorrow with their associated supplies
  /// Returns empty list if tomorrow is a weekend or has no classes
  /// Performance: query must complete in < 500ms (NFR2)
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getTomorrowCourses();
}

class CalendarCourseSupabaseRepository extends CalendarCourseRepository {
  final SupabaseClient supabaseClient;
  final PreferenceRepository preferenceRepository;
  final AppDatabase database;

  CalendarCourseSupabaseRepository(
    this.supabaseClient,
    this.preferenceRepository,
    this.database,
  );

  @override
  Future<Either<Failure, CalendarCourse>> addCalendarCourse(CalendarCourse calendarCourse) {
    return handleErrors(() async {
      final deviceId = await preferenceRepository.getUserId();
      final id = const Uuid().v4();

      LogService.d('CalendarCourseRepository.addCalendarCourse: Adding course (double write)');

      // 1. INSERT INTO DRIFT (local DB) - CRITICAL for offline-first
      // IMPORTANT: Always provide updatedAt field to avoid silent insertion failures
      final now = DateTime.now();
      final companion = CalendarCoursesCompanion(
        id: Value(id),
        courseId: Value(calendarCourse.courseId),
        roomName: Value(calendarCourse.roomName),
        startHour: Value(calendarCourse.startTime.hour),
        startMinute: Value(calendarCourse.startTime.minute),
        endHour: Value(calendarCourse.endTime.hour),
        endMinute: Value(calendarCourse.endTime.minute),
        weekType: Value(calendarCourse.weekType.value),
        dayOfWeek: Value(calendarCourse.dayOfWeek),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await database.into(database.calendarCourses).insert(companion);
      LogService.d('CalendarCourseRepository.addCalendarCourse: Inserted into Drift (local)');

      // 2. INSERT INTO SUPABASE (remote sync)
      try {
        final response = await supabaseClient
            .from('calendar_courses')
            .insert({
              'id': id,
              'device_id': deviceId,
              'course_id': calendarCourse.courseId,
              'room_name': calendarCourse.roomName,
              'start_time_hour': calendarCourse.startTime.hour,
              'start_time_minute': calendarCourse.startTime.minute,
              'end_time_hour': calendarCourse.endTime.hour,
              'end_time_minute': calendarCourse.endTime.minute,
              'week_type': calendarCourse.weekType.value,
              'day_of_week': calendarCourse.dayOfWeek,
            })
            .select()
            .single();

        LogService.d('CalendarCourseRepository.addCalendarCourse: Synced to Supabase');
        return CalendarCourse.fromJson(response);
      } catch (e) {
        LogService.w('CalendarCourseRepository.addCalendarCourse: Supabase sync failed (will retry later): $e');
        // Return local data even if Supabase sync fails (offline-first)
        return CalendarCourse(
          id: id,
          courseId: calendarCourse.courseId,
          roomName: calendarCourse.roomName,
          startTime: calendarCourse.startTime,
          endTime: calendarCourse.endTime,
          weekType: calendarCourse.weekType,
          dayOfWeek: calendarCourse.dayOfWeek,
        );
      }
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourse>>> fetchCalendarCourses() async {
    return handleErrors(() async {
      LogService.d('CalendarCourseRepository.fetchCalendarCourses: Reading from Drift (local)');

      // READ FROM DRIFT (local DB) - offline-first
      final courses = await database.select(database.calendarCourses).get();

      LogService.d('CalendarCourseRepository.fetchCalendarCourses: Found ${courses.length} courses in Drift');

      // Log each course for debugging
      for (final entity in courses) {
        LogService.d('  Course: id=${entity.id}, courseId=${entity.courseId}, day=${entity.dayOfWeek}, '
            'weekType=${entity.weekType}, time=${entity.startHour}:${entity.startMinute}-${entity.endHour}:${entity.endMinute}');
      }

      final result = courses.map((entity) {
        return CalendarCourse(
          id: entity.id,
          courseId: entity.courseId,
          roomName: entity.roomName,
          startTime: TimeOfDay(hour: entity.startHour, minute: entity.startMinute),
          endTime: TimeOfDay(hour: entity.endHour, minute: entity.endMinute),
          weekType: WeekType.fromString(entity.weekType),
          dayOfWeek: entity.dayOfWeek,
        );
      }).toList();

      LogService.d('CalendarCourseRepository.fetchCalendarCourses: Returning ${result.length} mapped courses');
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> updateCalendarCourse(CalendarCourse calendarCourse) {
    return handleErrors(() async {
      final deviceId = await preferenceRepository.getUserId();

      LogService.d('CalendarCourseRepository.updateCalendarCourse: Updating course (double write)');

      // 1. UPDATE IN DRIFT (local DB)
      final companion = CalendarCoursesCompanion(
        id: Value(calendarCourse.id),
        courseId: Value(calendarCourse.courseId),
        roomName: Value(calendarCourse.roomName),
        startHour: Value(calendarCourse.startTime.hour),
        startMinute: Value(calendarCourse.startTime.minute),
        endHour: Value(calendarCourse.endTime.hour),
        endMinute: Value(calendarCourse.endTime.minute),
        weekType: Value(calendarCourse.weekType.value),
        dayOfWeek: Value(calendarCourse.dayOfWeek),
        updatedAt: Value(DateTime.now()),
      );

      await database
          .update(database.calendarCourses)
          .replace(companion);

      LogService.d('CalendarCourseRepository.updateCalendarCourse: Updated in Drift (local)');

      // 2. UPDATE IN SUPABASE (remote sync)
      try {
        final response = await supabaseClient
            .from('calendar_courses')
            .update({
              'course_id': calendarCourse.courseId,
              'room_name': calendarCourse.roomName,
              'start_time_hour': calendarCourse.startTime.hour,
              'start_time_minute': calendarCourse.startTime.minute,
              'end_time_hour': calendarCourse.endTime.hour,
              'end_time_minute': calendarCourse.endTime.minute,
              'week_type': calendarCourse.weekType.value,
              'day_of_week': calendarCourse.dayOfWeek,
            })
            .eq('id', calendarCourse.id)
            .eq('device_id', deviceId)
            .select();

        if ((response as List).isEmpty) {
          LogService.w('CalendarCourseRepository.updateCalendarCourse: Course not found in Supabase');
        } else {
          LogService.d('CalendarCourseRepository.updateCalendarCourse: Synced to Supabase');
        }
      } catch (e) {
        LogService.w('CalendarCourseRepository.updateCalendarCourse: Supabase sync failed: $e');
        // Continue - local update succeeded (offline-first)
      }
    });
  }

  @override
  Future<Either<Failure, void>> deleteCalendarCourse(String id) {
    return handleErrors(() async {
      LogService.d('CalendarCourseRepository.deleteCalendarCourse: Deleting course (double write)');

      // 1. DELETE FROM DRIFT (local DB)
      await (database.delete(database.calendarCourses)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

      LogService.d('CalendarCourseRepository.deleteCalendarCourse: Deleted from Drift (local)');

      // 2. DELETE FROM SUPABASE (remote sync)
      try {
        await supabaseClient
            .from('calendar_courses')
            .delete()
            .eq('id', id);

        LogService.d('CalendarCourseRepository.deleteCalendarCourse: Synced to Supabase');
      } catch (e) {
        LogService.w('CalendarCourseRepository.deleteCalendarCourse: Supabase sync failed: $e');
        // Continue - local delete succeeded (offline-first)
      }
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getTomorrowCourses() {
    return handleErrors(() async {
      LogService.d('CalendarCourseRepository.getTomorrowCourses: Starting query');

      // 1. Calculate tomorrow's date (using clock for testability)
      final tomorrow = clock.now().add(const Duration(days: 1));
      final tomorrowDayOfWeek = tomorrow.weekday; // 1=Mon, 7=Sun

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Tomorrow = ${tomorrow.toIso8601String()}, dayOfWeek=$tomorrowDayOfWeek');

      // 2. Determine week type (A/B) using WeekUtils (AC5)
      final schoolYearStart = await PreferencesService.getSchoolYearStart();
      final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, tomorrow);

      LogService.d('CalendarCourseRepository.getTomorrowCourses: School year start = ${schoolYearStart.toIso8601String()}, weekType = $weekType');

      // Start stopwatch AFTER SharedPreferences I/O for accurate Drift-only measurement
      final stopwatch = Stopwatch()..start();

      // 3. Optimized query strategy (fixes N+1 query problem)
      // Instead of N individual queries, use 2 batch queries + in-memory join
      // NOTE: No early return for weekends - some students may have Saturday/Sunday classes

      // Query 1: Get tomorrow's calendar courses (filtered by day + week type)
      // Note: 'BOTH' is the app-level value, 'AB' is the Drift schema default — handle both for safety
      final calendarQuery = database.select(database.calendarCourses)
        ..where((c) =>
            c.dayOfWeek.equals(tomorrowDayOfWeek) &
            (c.weekType.equals('BOTH') | c.weekType.equals('AB') | c.weekType.equals(weekType)))
        ..orderBy([(c) => OrderingTerm.asc(c.startHour), (c) => OrderingTerm.asc(c.startMinute)]);

      final calendarCourses = await calendarQuery.get();

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Found ${calendarCourses.length} calendar courses for tomorrow');

      // 4. No classes detection (AC3, AC4)
      if (calendarCourses.isEmpty) {
        LogService.d('CalendarCourseRepository.getTomorrowCourses: No courses scheduled for tomorrow (dayOfWeek=$tomorrowDayOfWeek), returning empty list');
        return <CalendarCourseWithSupplies>[];
      }

      // Query 2: Batch load all courses (instead of N individual getCourseById calls)
      final courseIds = calendarCourses.map((c) => c.courseId).toSet().toList();
      final coursesQuery = database.select(database.courses)
        ..where((c) => c.id.isIn(courseIds));
      final coursesMap = {for (var c in await coursesQuery.get()) c.id: c};

      // Query 3: Batch load all supplies for these courses (instead of N individual getSuppliesByCourse calls)
      final suppliesQuery = database.select(database.supplies)
        ..where((s) => s.courseId.isIn(courseIds));
      final allSupplies = await suppliesQuery.get();

      // Group supplies by courseId in memory
      final suppliesByCourse = <String, List<SupplyEntity>>{};
      for (final supply in allSupplies) {
        suppliesByCourse.putIfAbsent(supply.courseId, () => []).add(supply);
      }

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Batch loaded ${coursesMap.length} courses and ${allSupplies.length} supplies');

      // 5. Build final result with in-memory join (AC2: Group supplies by course)
      final result = <CalendarCourseWithSupplies>[];

      for (final calendarCourse in calendarCourses) {
        final course = coursesMap[calendarCourse.courseId];

        if (course == null) {
          LogService.w('CalendarCourseRepository.getTomorrowCourses: Course ${calendarCourse.courseId} not found, skipping');
          continue;
        }

        final supplies = suppliesByCourse[course.id] ?? [];
        final supplyModels = supplies.map((s) => Supply(id: s.id, name: s.name)).toList();

        result.add(
          CalendarCourseWithSupplies(
            courseId: course.id,
            courseName: course.name,
            startHour: calendarCourse.startHour,
            startMinute: calendarCourse.startMinute,
            endHour: calendarCourse.endHour,
            endMinute: calendarCourse.endMinute,
            room: calendarCourse.roomName.isEmpty ? null : calendarCourse.roomName,
            supplies: supplyModels,
          ),
        );
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Batch query completed in ${elapsedMs}ms (3 queries: calendar courses, courses, supplies), returning ${result.length} courses');

      // Performance validation (NFR2: < 500ms)
      if (elapsedMs >= 500) {
        LogService.w('CalendarCourseRepository.getTomorrowCourses: Performance warning! Query took ${elapsedMs}ms (should be < 500ms)');
      }

      return result;
    });
  }
}
