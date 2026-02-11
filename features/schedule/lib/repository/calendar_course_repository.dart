import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:common/src/utils/week_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
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
        id: drift.Value(id),
        courseId: drift.Value(calendarCourse.courseId),
        roomName: drift.Value(calendarCourse.roomName),
        startHour: drift.Value(calendarCourse.startTime.hour),
        startMinute: drift.Value(calendarCourse.startTime.minute),
        endHour: drift.Value(calendarCourse.endTime.hour),
        endMinute: drift.Value(calendarCourse.endTime.minute),
        weekType: drift.Value(calendarCourse.weekType.value),
        dayOfWeek: drift.Value(calendarCourse.dayOfWeek),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
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
        id: drift.Value(calendarCourse.id),
        courseId: drift.Value(calendarCourse.courseId),
        roomName: drift.Value(calendarCourse.roomName),
        startHour: drift.Value(calendarCourse.startTime.hour),
        startMinute: drift.Value(calendarCourse.startTime.minute),
        endHour: drift.Value(calendarCourse.endTime.hour),
        endMinute: drift.Value(calendarCourse.endTime.minute),
        weekType: drift.Value(calendarCourse.weekType.value),
        dayOfWeek: drift.Value(calendarCourse.dayOfWeek),
        updatedAt: drift.Value(DateTime.now()),
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
      final stopwatch = Stopwatch()..start();

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Starting query');

      // 1. Calculate tomorrow's date
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDayOfWeek = tomorrow.weekday; // 1=Mon, 7=Sun

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Tomorrow = ${tomorrow.toIso8601String()}, dayOfWeek=$tomorrowDayOfWeek');

      // 2. Weekend detection (early return for performance - AC3)
      if (tomorrowDayOfWeek == DateTime.saturday || tomorrowDayOfWeek == DateTime.sunday) {
        LogService.d('CalendarCourseRepository.getTomorrowCourses: Tomorrow is weekend (day $tomorrowDayOfWeek), returning empty list');
        return <CalendarCourseWithSupplies>[];
      }

      // 3. Determine week type (A/B) using WeekUtils (AC5)
      final schoolYearStart = await PreferencesService.getSchoolYearStart();
      final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, tomorrow);

      LogService.d('CalendarCourseRepository.getTomorrowCourses: School year start = ${schoolYearStart.toIso8601String()}, weekType = $weekType');

      // 4. Query calendar_courses for tomorrow (AC1, AC5)
      // Filter: dayOfWeek = tomorrow.weekday AND (weekType = calculated OR weekType = 'BOTH')
      final query = database.select(database.calendarCourses)
        ..where((c) =>
            c.dayOfWeek.equals(tomorrowDayOfWeek) &
            (c.weekType.equals('BOTH') | c.weekType.equals(weekType)))
        ..orderBy([(c) => drift.OrderingTerm.asc(c.startHour), (c) => drift.OrderingTerm.asc(c.startMinute)]); // AC2: Order by time

      final calendarCourses = await query.get();

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Found ${calendarCourses.length} calendar courses for tomorrow');

      // 5. No classes detection (AC4)
      if (calendarCourses.isEmpty) {
        LogService.d('CalendarCourseRepository.getTomorrowCourses: Tomorrow is weekday but no courses scheduled, returning empty list');
        return <CalendarCourseWithSupplies>[];
      }

      // 6. Load course details and supplies (AC2: Group supplies by course)
      final result = <CalendarCourseWithSupplies>[];

      for (final calendarCourse in calendarCourses) {
        // Get course info
        final course = await database.getCourseById(calendarCourse.courseId);

        if (course == null) {
          LogService.w('CalendarCourseRepository.getTomorrowCourses: Course ${calendarCourse.courseId} not found, skipping');
          continue;
        }

        // Get supplies for this course
        final supplies = await database.getSuppliesByCourse(course.id);

        LogService.d('CalendarCourseRepository.getTomorrowCourses: Course "${course.name}" has ${supplies.length} supplies');

        // Map to Supply model
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

      LogService.d('CalendarCourseRepository.getTomorrowCourses: Query completed in ${elapsedMs}ms, returning ${result.length} courses');

      // Performance validation (NFR2: < 500ms)
      if (elapsedMs >= 500) {
        LogService.w('CalendarCourseRepository.getTomorrowCourses: Performance warning! Query took ${elapsedMs}ms (should be < 500ms)');
      }

      return result;
    });
  }
}
