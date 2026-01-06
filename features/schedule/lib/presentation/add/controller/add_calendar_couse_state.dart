import 'package:course/models/cours_with_supplies.dart';
import 'package:flutter/material.dart';
import 'package:schedule/models/calendar_course.dart';

class AddCalendarCourseState {
  final String? courseId;
  final String roomName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final WeekType weekType;
  final int dayOfWeek;
  final String? errorCourseId;
  final String? errorRoomName;
  final String? errorStartTime;
  final String? errorEndTime;
  final List<CourseWithSupplies> courses;

  AddCalendarCourseState({
    required this.courses,
    this.courseId,
    this.roomName = '',
    required this.startTime,
    required this.endTime,
    this.weekType = WeekType.BOTH,
    int? dayOfWeek,
    this.errorCourseId,
    this.errorRoomName,
    this.errorStartTime,
    this.errorEndTime,
  }) : dayOfWeek = dayOfWeek ?? 1; // Default to Monday, will be set by page

  AddCalendarCourseState copyWith({
    String? courseId,
    String? roomName,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    WeekType? weekType,
    int? dayOfWeek,
    String? errorCourseId,
    String? errorRoomName,
    String? errorStartTime,
    String? errorEndTime,
  }) {
    return AddCalendarCourseState(
      courses: courses,
      courseId: courseId ?? this.courseId,
      roomName: roomName ?? this.roomName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weekType: weekType ?? this.weekType,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      errorCourseId: errorCourseId,
      errorRoomName: errorRoomName,
      errorStartTime: errorStartTime,
      errorEndTime: errorEndTime,
    );
  }
}
