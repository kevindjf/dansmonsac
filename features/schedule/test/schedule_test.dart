import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedule/models/calendar_course.dart';

void main() {
  group('WeekType', () {
    test('fromString returns correct enum values', () {
      expect(WeekType.fromString('A'), WeekType.A);
      expect(WeekType.fromString('B'), WeekType.B);
      expect(WeekType.fromString('BOTH'), WeekType.BOTH);
    });

    test('fromString is case insensitive', () {
      expect(WeekType.fromString('a'), WeekType.A);
      expect(WeekType.fromString('b'), WeekType.B);
      expect(WeekType.fromString('both'), WeekType.BOTH);
    });

    test('fromString defaults to BOTH for unknown values', () {
      expect(WeekType.fromString('C'), WeekType.BOTH);
      expect(WeekType.fromString(''), WeekType.BOTH);
      expect(WeekType.fromString('invalid'), WeekType.BOTH);
    });

    test('value property returns correct string', () {
      expect(WeekType.A.value, 'A');
      expect(WeekType.B.value, 'B');
      expect(WeekType.BOTH.value, 'BOTH');
    });
  });

  group('CalendarCourse', () {
    CalendarCourse createSample() {
      return CalendarCourse(
        id: 'test-id',
        courseId: 'course-1',
        roomName: 'Salle 101',
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 9, minute: 30),
        weekType: WeekType.A,
        dayOfWeek: 1,
      );
    }

    test('creates instance with correct properties', () {
      final course = createSample();

      expect(course.id, 'test-id');
      expect(course.courseId, 'course-1');
      expect(course.roomName, 'Salle 101');
      expect(course.startTime, const TimeOfDay(hour: 8, minute: 30));
      expect(course.endTime, const TimeOfDay(hour: 9, minute: 30));
      expect(course.weekType, WeekType.A);
      expect(course.dayOfWeek, 1);
    });

    test('weekType defaults to BOTH', () {
      final course = CalendarCourse(
        id: 'id',
        courseId: 'cid',
        roomName: 'Room',
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 0),
        dayOfWeek: 2,
      );

      expect(course.weekType, WeekType.BOTH);
    });

    test('toJson produces correct snake_case keys', () {
      final course = createSample();
      final json = course.toJson();

      expect(json['id'], 'test-id');
      expect(json['course_id'], 'course-1');
      expect(json['room_name'], 'Salle 101');
      expect(json['start_time_hour'], 8);
      expect(json['start_time_minute'], 30);
      expect(json['end_time_hour'], 9);
      expect(json['end_time_minute'], 30);
      expect(json['week_type'], 'A');
      expect(json['day_of_week'], 1);
    });

    test('fromJson with snake_case keys', () {
      final json = {
        'id': 'json-id',
        'course_id': 'c-1',
        'room_name': 'Salle 202',
        'start_time_hour': 14,
        'start_time_minute': 0,
        'end_time_hour': 15,
        'end_time_minute': 30,
        'week_type': 'B',
        'day_of_week': 3,
      };

      final course = CalendarCourse.fromJson(json);

      expect(course.id, 'json-id');
      expect(course.courseId, 'c-1');
      expect(course.roomName, 'Salle 202');
      expect(course.startTime.hour, 14);
      expect(course.startTime.minute, 0);
      expect(course.endTime.hour, 15);
      expect(course.endTime.minute, 30);
      expect(course.weekType, WeekType.B);
      expect(course.dayOfWeek, 3);
    });

    test('fromJson with camelCase keys (backward compatibility)', () {
      final json = {
        'id': 'id-1',
        'courseId': 'c-2',
        'roomName': 'Room A',
        'startTimeHour': 10,
        'startTimeMinute': 15,
        'endTimeHour': 11,
        'endTimeMinute': 15,
        'weekType': 'A',
        'dayOfWeek': 5,
      };

      final course = CalendarCourse.fromJson(json);

      expect(course.courseId, 'c-2');
      expect(course.roomName, 'Room A');
      expect(course.startTime.hour, 10);
      expect(course.weekType, WeekType.A);
      expect(course.dayOfWeek, 5);
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = createSample();
      final json = original.toJson();
      final restored = CalendarCourse.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.courseId, original.courseId);
      expect(restored.roomName, original.roomName);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.weekType, original.weekType);
      expect(restored.dayOfWeek, original.dayOfWeek);
    });

    test('copyWith creates modified copy', () {
      final original = createSample();
      final modified = original.copyWith(
        roomName: 'Salle 303',
        weekType: WeekType.B,
        dayOfWeek: 5,
      );

      expect(modified.id, original.id);
      expect(modified.courseId, original.courseId);
      expect(modified.roomName, 'Salle 303');
      expect(modified.weekType, WeekType.B);
      expect(modified.dayOfWeek, 5);
      // Original unchanged
      expect(original.roomName, 'Salle 101');
      expect(original.weekType, WeekType.A);
    });

    test('copyWith with no arguments returns equivalent copy', () {
      final original = createSample();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.courseId, original.courseId);
      expect(copy.roomName, original.roomName);
      expect(copy.dayOfWeek, original.dayOfWeek);
    });
  });
}
