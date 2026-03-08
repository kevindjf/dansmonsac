import 'package:clock/clock.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
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
import 'package:uuid/uuid.dart';

abstract class CalendarCourseRepository {
  Future<Either<Failure, CalendarCourse>> addCalendarCourse(
      CalendarCourse calendarCourse);
  Future<Either<Failure, void>> updateCalendarCourse(
      CalendarCourse calendarCourse);
  Future<Either<Failure, List<CalendarCourse>>> fetchCalendarCourses();
  Future<Either<Failure, void>> deleteCalendarCourse(String id);

  /// Gets all courses scheduled for tomorrow with their associated supplies
  /// Returns empty list if tomorrow is a weekend or has no classes
  /// Performance: query must complete in < 500ms (NFR2)
  Future<Either<Failure, List<CalendarCourseWithSupplies>>>
      getTomorrowCourses();

  /// Gets all courses scheduled for a specific date with their associated supplies
  /// Returns empty list if the date has no classes
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getCoursesForDate(
      DateTime date);
}

class CalendarCourseSupabaseRepository extends CalendarCourseRepository {
  final AppDatabase database;

  CalendarCourseSupabaseRepository(this.database);

  @override
  Future<Either<Failure, CalendarCourse>> addCalendarCourse(
      CalendarCourse calendarCourse) {
    return handleErrors(() async {
      final id = const Uuid().v4();

      LogService.d(
          'CalendarCourseRepository.addCalendarCourse: Adding calendar course');

      // INSERT INTO DRIFT (local DB only)
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
      LogService.d(
          'CalendarCourseRepository.addCalendarCourse: Inserted into Drift');

      return CalendarCourse(
        id: id,
        courseId: calendarCourse.courseId,
        roomName: calendarCourse.roomName,
        startTime: calendarCourse.startTime,
        endTime: calendarCourse.endTime,
        weekType: calendarCourse.weekType,
        dayOfWeek: calendarCourse.dayOfWeek,
      );
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourse>>> fetchCalendarCourses() async {
    return handleErrors(() async {
      LogService.d(
          'CalendarCourseRepository.fetchCalendarCourses: Reading from Drift (local)');

      // READ FROM DRIFT (local DB) - offline-first
      final courses = await database.select(database.calendarCourses).get();

      LogService.d(
          'CalendarCourseRepository.fetchCalendarCourses: Found ${courses.length} courses in Drift');

      // Log each course for debugging
      for (final entity in courses) {
        LogService.d(
            '  Course: id=${entity.id}, courseId=${entity.courseId}, day=${entity.dayOfWeek}, '
            'weekType=${entity.weekType}, time=${entity.startHour}:${entity.startMinute}-${entity.endHour}:${entity.endMinute}');
      }

      final result = courses.map((entity) {
        return CalendarCourse(
          id: entity.id,
          courseId: entity.courseId,
          roomName: entity.roomName,
          startTime:
              TimeOfDay(hour: entity.startHour, minute: entity.startMinute),
          endTime: TimeOfDay(hour: entity.endHour, minute: entity.endMinute),
          weekType: WeekType.fromString(entity.weekType),
          dayOfWeek: entity.dayOfWeek,
        );
      }).toList();

      LogService.d(
          'CalendarCourseRepository.fetchCalendarCourses: Returning ${result.length} mapped courses');
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> updateCalendarCourse(
      CalendarCourse calendarCourse) {
    return handleErrors(() async {
      LogService.d(
          'CalendarCourseRepository.updateCalendarCourse: Updating calendar course');

      // UPDATE IN DRIFT (local DB only)
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

      await database.update(database.calendarCourses).replace(companion);

      LogService.d(
          'CalendarCourseRepository.updateCalendarCourse: Updated in Drift');
    });
  }

  @override
  Future<Either<Failure, void>> deleteCalendarCourse(String id) {
    return handleErrors(() async {
      LogService.d(
          'CalendarCourseRepository.deleteCalendarCourse: Deleting calendar course');

      // DELETE FROM DRIFT (local DB only)
      await (database.delete(database.calendarCourses)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

      LogService.d(
          'CalendarCourseRepository.deleteCalendarCourse: Deleted from Drift');
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>>
      getTomorrowCourses() {
    final tomorrow = clock.now().add(const Duration(days: 1));
    return getCoursesForDate(tomorrow);
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getCoursesForDate(
      DateTime date) {
    return handleErrors(() async {
      final targetDayOfWeek = date.weekday; // 1=Mon, 7=Sun

      LogService.d(
          'CalendarCourseRepository.getCoursesForDate: date=${date.toIso8601String()}, dayOfWeek=$targetDayOfWeek');

      // Determine week type (A/B) using WeekUtils
      final schoolYearStart = await PreferencesService.getSchoolYearStart();
      final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, date);

      LogService.d(
          'CalendarCourseRepository.getCoursesForDate: weekType=$weekType');

      final stopwatch = Stopwatch()..start();

      // Query 1: Get calendar courses for target date (filtered by day + week type)
      final calendarQuery = database.select(database.calendarCourses)
        ..where((c) =>
            c.dayOfWeek.equals(targetDayOfWeek) &
            (c.weekType.equals('BOTH') |
                c.weekType.equals('AB') |
                c.weekType.equals(weekType)))
        ..orderBy([
          (c) => OrderingTerm.asc(c.startHour),
          (c) => OrderingTerm.asc(c.startMinute)
        ]);

      final calendarCourses = await calendarQuery.get();

      LogService.d(
          'CalendarCourseRepository.getCoursesForDate: Found ${calendarCourses.length} calendar courses');

      if (calendarCourses.isEmpty) {
        LogService.d(
            'CalendarCourseRepository.getCoursesForDate: No courses scheduled, returning empty list');
        return <CalendarCourseWithSupplies>[];
      }

      // Query 2: Batch load all courses
      // IMPORTANT: courseId can be either a local Drift ID OR a Supabase remoteId
      final courseIds = calendarCourses.map((c) => c.courseId).toSet().toList();
      final coursesQuery = database.select(database.courses)
        ..where((c) => c.id.isIn(courseIds) | c.remoteId.isIn(courseIds));

      final coursesById = <String, CourseEntity>{};
      final coursesByRemoteId = <String, CourseEntity>{};
      for (var c in await coursesQuery.get()) {
        coursesById[c.id] = c;
        if (c.remoteId != null) {
          coursesByRemoteId[c.remoteId!] = c;
        }
      }

      CourseEntity? findCourse(String courseId) {
        return coursesById[courseId] ?? coursesByRemoteId[courseId];
      }

      if (coursesById.isEmpty && coursesByRemoteId.isEmpty) {
        LogService.w(
            'CalendarCourseRepository.getCoursesForDate: No courses found in Drift');
      }

      // Query 3: Batch load all supplies
      final allCourseIds = <String>[];
      allCourseIds.addAll(coursesById.keys);
      allCourseIds.addAll(coursesByRemoteId.keys);

      final suppliesQuery = database.select(database.supplies)
        ..where((s) => s.courseId.isIn(allCourseIds));
      final allSupplies = await suppliesQuery.get();

      final suppliesByCourse = <String, List<SupplyEntity>>{};
      for (final supply in allSupplies) {
        final course = findCourse(supply.courseId);
        if (course != null) {
          suppliesByCourse.putIfAbsent(course.id, () => []).add(supply);
        }
      }

      LogService.d(
          'CalendarCourseRepository.getCoursesForDate: Batch loaded ${coursesById.length} courses and ${allSupplies.length} supplies');

      // Build final result with in-memory join
      final result = <CalendarCourseWithSupplies>[];

      for (final calendarCourse in calendarCourses) {
        final course = findCourse(calendarCourse.courseId);

        if (course == null) {
          LogService.w(
              'CalendarCourseRepository.getCoursesForDate: Course ${calendarCourse.courseId} not found, skipping');
          continue;
        }

        final courseName = course.name;
        final driftSupplies = suppliesByCourse[course.id] ?? [];
        final supplies =
            driftSupplies.map((s) => Supply(id: s.id, name: s.name)).toList();

        result.add(
          CalendarCourseWithSupplies(
            courseId: calendarCourse.courseId,
            courseName: courseName,
            startHour: calendarCourse.startHour,
            startMinute: calendarCourse.startMinute,
            endHour: calendarCourse.endHour,
            endMinute: calendarCourse.endMinute,
            room: calendarCourse.roomName.isEmpty
                ? null
                : calendarCourse.roomName,
            supplies: supplies,
          ),
        );
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      LogService.d(
          'CalendarCourseRepository.getCoursesForDate: Completed in ${elapsedMs}ms, returning ${result.length} courses');

      if (elapsedMs >= 500) {
        LogService.w(
            'CalendarCourseRepository.getCoursesForDate: Performance warning! ${elapsedMs}ms (should be < 500ms)');
      }

      return result;
    });
  }
}
