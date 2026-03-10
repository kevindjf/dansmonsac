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
      final now = DateTime.now();
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
        updatedAt: Value(now),
      );

      await (database.update(database.calendarCourses)
            ..where((c) => c.id.equals(calendarCourse.id)))
          .write(companion);
    });
  }

  @override
  Future<Either<Failure, void>> deleteCalendarCourse(String id) {
    return handleErrors(() async {
      await (database.delete(database.calendarCourses)
            ..where((c) => c.id.equals(id)))
          .go();
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>>
      getTomorrowCourses() {
    return handleErrors(() async {
      final now = clock.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      return _getCoursesForDateInternal(tomorrow);
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getCoursesForDate(
      DateTime date) {
    return handleErrors(() async {
      return _getCoursesForDateInternal(date);
    });
  }

  Future<List<CalendarCourseWithSupplies>> _getCoursesForDateInternal(
      DateTime date) async {
    final dayOfWeek = date.weekday; // 1=Monday, 7=Sunday

    // Weekend check - no classes on Saturday/Sunday
    if (dayOfWeek == 6 || dayOfWeek == 7) {
      LogService.d(
          'CalendarCourseRepository: Weekend day ($dayOfWeek), returning empty');
      return [];
    }

    // Get school year start for week type calculation
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, date);

    LogService.d(
        'CalendarCourseRepository: date=$date, dayOfWeek=$dayOfWeek, weekType=$weekType');

    // Query calendar courses for this day and week type
    final calendarEntities =
        await database.getCalendarCoursesByDayAndWeek(dayOfWeek, weekType);

    if (calendarEntities.isEmpty) {
      return [];
    }

    // Batch fetch courses and supplies to avoid N+1
    final courseIds = calendarEntities.map((e) => e.courseId).toSet().toList();

    final allCourses = await database.getAllCourses();
    final courseMap = {for (final c in allCourses) c.id: c};

    final allSupplies = await database.getAllSupplies();
    final suppliesByCourse = <String, List<Supply>>{};
    for (final s in allSupplies) {
      if (courseIds.contains(s.courseId)) {
        suppliesByCourse.putIfAbsent(s.courseId, () => []).add(
              Supply(id: s.id, name: s.name),
            );
      }
    }

    // Build result list
    final result = <CalendarCourseWithSupplies>[];
    for (final entity in calendarEntities) {
      final course = courseMap[entity.courseId];
      if (course == null) continue;

      result.add(CalendarCourseWithSupplies(
        courseId: course.id,
        courseName: course.name,
        startHour: entity.startHour,
        startMinute: entity.startMinute,
        endHour: entity.endHour,
        endMinute: entity.endMinute,
        room: entity.roomName,
        supplies: suppliesByCourse[entity.courseId] ?? [],
      ));
    }

    // Sort by start time
    result.sort((a, b) {
      final cmp = a.startHour.compareTo(b.startHour);
      if (cmp != 0) return cmp;
      return a.startMinute.compareTo(b.startMinute);
    });

    LogService.d(
        'CalendarCourseRepository: Returning ${result.length} courses for $date');
    return result;
  }
}
