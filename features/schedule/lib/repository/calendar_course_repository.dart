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
      await database.updateCalendarCourse(companion);
    });
  }

  @override
  Future<Either<Failure, void>> deleteCalendarCourse(String id) {
    return handleErrors(() async {
      await database.deleteCalendarCourse(id);
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getTomorrowCourses() {
    return handleErrors(() async {
      final now = clock.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      return _getCoursesForDateInternal(tomorrow);
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourseWithSupplies>>> getCoursesForDate(DateTime date) {
    return handleErrors(() async {
      return _getCoursesForDateInternal(date);
    });
  }

  Future<List<CalendarCourseWithSupplies>> _getCoursesForDateInternal(DateTime date) async {
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    final weekType = WeekUtils.getCurrentWeekType(schoolYearStart, date);

    final calendarCourses = await database.getCalendarCoursesByDayAndWeek(
      date.weekday,
      weekType,
    );

    final List<CalendarCourseWithSupplies> result = [];
    final processedCourseIds = <String>{};

    for (final cc in calendarCourses) {
      if (processedCourseIds.contains(cc.courseId)) continue;
      processedCourseIds.add(cc.courseId);

      final course = await database.getCourseById(cc.courseId);
      if (course == null) continue;

      final supplies = await database.getSuppliesByCourse(cc.courseId);

      result.add(CalendarCourseWithSupplies(
        courseId: cc.courseId,
        courseName: course.name,
        startHour: cc.startHour,
        startMinute: cc.startMinute,
        endHour: cc.endHour,
        endMinute: cc.endMinute,
        room: cc.roomName,
        supplies: supplies.map((s) => Supply(id: s.id, name: s.name)).toList(),
      ));
    }

    return result;
  }
}
