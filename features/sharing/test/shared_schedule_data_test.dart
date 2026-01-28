import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharing/models/shared_schedule_data.dart';

void main() {
  group('SharedScheduleData serialization', () {
    test('should serialize and deserialize courses correctly', () {
      final data = SharedScheduleData(
        courses: [
          SharedCourseData(name: 'Mathematiques', supplies: ['Cahier', 'Calculatrice']),
          SharedCourseData(name: 'Francais', supplies: ['Dictionnaire']),
        ],
        calendarCourses: [],
      );

      final json = data.toJson();
      final restored = SharedScheduleData.fromJson(json);

      expect(restored.courses.length, equals(2));
      expect(restored.courses[0].name, equals('Mathematiques'));
      expect(restored.courses[0].supplies, equals(['Cahier', 'Calculatrice']));
      expect(restored.courses[1].name, equals('Francais'));
      expect(restored.courses[1].supplies, equals(['Dictionnaire']));
    });

    test('should serialize and deserialize calendar courses correctly', () {
      final data = SharedScheduleData(
        courses: [
          SharedCourseData(name: 'Mathematiques', supplies: ['Cahier']),
        ],
        calendarCourses: [
          SharedCalendarCourseData(
            courseName: 'Mathematiques',
            roomName: 'Salle 101',
            startTimeHour: 8,
            startTimeMinute: 30,
            endTimeHour: 9,
            endTimeMinute: 30,
            weekType: 'BOTH',
            dayOfWeek: 1,
          ),
          SharedCalendarCourseData(
            courseName: 'Mathematiques',
            roomName: 'Salle 102',
            startTimeHour: 14,
            startTimeMinute: 0,
            endTimeHour: 15,
            endTimeMinute: 0,
            weekType: 'A',
            dayOfWeek: 3,
          ),
        ],
      );

      final json = data.toJson();

      // Verify the JSON structure
      expect(json['courses'], isA<List>());
      expect(json['calendar_courses'], isA<List>());
      expect((json['calendar_courses'] as List).length, equals(2));

      // Verify calendar course JSON keys are correct (snake_case)
      final calendarJson = (json['calendar_courses'] as List)[0] as Map<String, dynamic>;
      expect(calendarJson.containsKey('course_name'), isTrue);
      expect(calendarJson.containsKey('room_name'), isTrue);
      expect(calendarJson.containsKey('start_time_hour'), isTrue);
      expect(calendarJson.containsKey('start_time_minute'), isTrue);
      expect(calendarJson.containsKey('end_time_hour'), isTrue);
      expect(calendarJson.containsKey('end_time_minute'), isTrue);
      expect(calendarJson.containsKey('week_type'), isTrue);
      expect(calendarJson.containsKey('day_of_week'), isTrue);

      // Restore and verify
      final restored = SharedScheduleData.fromJson(json);

      expect(restored.calendarCourses.length, equals(2));

      final entry1 = restored.calendarCourses[0];
      expect(entry1.courseName, equals('Mathematiques'));
      expect(entry1.roomName, equals('Salle 101'));
      expect(entry1.startTimeHour, equals(8));
      expect(entry1.startTimeMinute, equals(30));
      expect(entry1.endTimeHour, equals(9));
      expect(entry1.endTimeMinute, equals(30));
      expect(entry1.weekType, equals('BOTH'));
      expect(entry1.dayOfWeek, equals(1));

      final entry2 = restored.calendarCourses[1];
      expect(entry2.courseName, equals('Mathematiques'));
      expect(entry2.roomName, equals('Salle 102'));
      expect(entry2.weekType, equals('A'));
      expect(entry2.dayOfWeek, equals(3));
    });

    test('should produce valid JSON string for Supabase', () {
      final data = SharedScheduleData(
        courses: [
          SharedCourseData(name: 'Mathematiques', supplies: ['Cahier', 'Calculatrice']),
        ],
        calendarCourses: [
          SharedCalendarCourseData(
            courseName: 'Mathematiques',
            roomName: 'Salle 101',
            startTimeHour: 8,
            startTimeMinute: 30,
            endTimeHour: 9,
            endTimeMinute: 30,
            weekType: 'BOTH',
            dayOfWeek: 1,
          ),
        ],
      );

      final json = data.toJson();

      // This should not throw - valid JSON
      final jsonString = jsonEncode(json);
      expect(jsonString, isNotEmpty);

      // Parse it back
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
      final restored = SharedScheduleData.fromJson(parsed);

      expect(restored.courses.length, equals(1));
      expect(restored.calendarCourses.length, equals(1));
      expect(restored.calendarCourses[0].courseName, equals('Mathematiques'));
    });

    test('should handle empty calendar courses', () {
      final data = SharedScheduleData(
        courses: [
          SharedCourseData(name: 'Mathematiques', supplies: ['Cahier']),
        ],
        calendarCourses: [],
      );

      final json = data.toJson();
      expect(json['calendar_courses'], equals([]));

      final restored = SharedScheduleData.fromJson(json);
      expect(restored.calendarCourses, isEmpty);
    });

    test('totalSupplies should count all supplies', () {
      final data = SharedScheduleData(
        courses: [
          SharedCourseData(name: 'Mathematiques', supplies: ['Cahier', 'Calculatrice', 'Regle']),
          SharedCourseData(name: 'Francais', supplies: ['Dictionnaire', 'Stylo']),
        ],
        calendarCourses: [],
      );

      expect(data.totalSupplies, equals(5));
    });
  });
}
