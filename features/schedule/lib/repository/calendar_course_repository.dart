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

  CalendarCourseSupabaseRepository(
      this.supabaseClient, this.preferenceRepository);

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
      await supabaseClient.from('calendar_courses').update({
        'course_id': calendarCourse.courseId,
        'room_name': calendarCourse.roomName,
        'start_time_hour': calendarCourse.startTime.hour,
        'start_time_minute': calendarCourse.startTime.minute,
        'end_time_hour': calendarCourse.endTime.hour,
        'end_time_minute': calendarCourse.endTime.minute,
        'week_type': calendarCourse.weekType.value,
        'day_of_week': calendarCourse.dayOfWeek,
      }).eq('id', calendarCourse.id);
    });
  }

  @override
  Future<Either<Failure, void>> deleteCalendarCourse(String id) {
    return handleErrors(() async {
      await supabaseClient.from('calendar_courses').delete().eq('id', id);
    });
  }
}
