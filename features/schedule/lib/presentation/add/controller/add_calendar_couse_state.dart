import 'package:course/models/cours_with_supplies.dart';
import 'package:flutter/material.dart';

class AddCalendarCourseState {
  final String? courseId;
  final String roomName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
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
    this.errorCourseId,
    this.errorRoomName,
    this.errorStartTime,
    this.errorEndTime,
  });

  AddCalendarCourseState copyWith({
    String? courseId,
    String? roomName,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
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
      errorCourseId: errorCourseId,
      errorRoomName: errorRoomName,
      errorStartTime: errorStartTime,
      errorEndTime: errorEndTime,
    );
  }
}
