import 'package:flutter/material.dart';

class CalendarCourse {
  final String id;
  final String courseId;
  final String roomName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  CalendarCourse({
    required this.id,
    required this.courseId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
  });

  // Pour la conversion en JSON et depuis JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'roomName': roomName,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
    };
  }

  factory CalendarCourse.fromJson(Map<String, dynamic> json) {
    return CalendarCourse(
      id: json['id'],
      courseId: json['courseId'],
      roomName: json['roomName'],
      startTime: TimeOfDay(
        hour: json['startTimeHour'],
        minute: json['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTimeHour'],
        minute: json['endTimeMinute'],
      ),
    );
  }

  CalendarCourse copyWith({
    String? id,
    String? courseId,
    String? roomName,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return CalendarCourse(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      roomName: roomName ?? this.roomName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}