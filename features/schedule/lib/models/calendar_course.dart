import 'package:flutter/material.dart';

enum WeekType {
  A('A'),
  B('B'),
  BOTH('BOTH');

  final String value;
  const WeekType(this.value);

  static WeekType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'A':
        return WeekType.A;
      case 'B':
        return WeekType.B;
      case 'BOTH':
        return WeekType.BOTH;
      default:
        return WeekType.BOTH;
    }
  }
}

class CalendarCourse {
  final String id;
  final String courseId;
  final String roomName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final WeekType weekType;
  final int dayOfWeek; // 1=Lundi, 7=Dimanche

  CalendarCourse({
    required this.id,
    required this.courseId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    this.weekType = WeekType.BOTH,
    required this.dayOfWeek,
  });

  // Pour la conversion en JSON et depuis JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'room_name': roomName,
      'start_time_hour': startTime.hour,
      'start_time_minute': startTime.minute,
      'end_time_hour': endTime.hour,
      'end_time_minute': endTime.minute,
      'week_type': weekType.value,
      'day_of_week': dayOfWeek,
    };
  }

  factory CalendarCourse.fromJson(Map<String, dynamic> json) {
    return CalendarCourse(
      id: json['id'],
      courseId: json['course_id'] ?? json['courseId'],
      roomName: json['room_name'] ?? json['roomName'],
      startTime: TimeOfDay(
        hour: json['start_time_hour'] ?? json['startTimeHour'],
        minute: json['start_time_minute'] ?? json['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: json['end_time_hour'] ?? json['endTimeHour'],
        minute: json['end_time_minute'] ?? json['endTimeMinute'],
      ),
      weekType: WeekType.fromString(json['week_type'] ?? json['weekType'] ?? 'BOTH'),
      dayOfWeek: json['day_of_week'] ?? json['dayOfWeek'] ?? 1,
    );
  }

  CalendarCourse copyWith({
    String? id,
    String? courseId,
    String? roomName,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    WeekType? weekType,
    int? dayOfWeek,
  }) {
    return CalendarCourse(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      roomName: roomName ?? this.roomName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weekType: weekType ?? this.weekType,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }
}
