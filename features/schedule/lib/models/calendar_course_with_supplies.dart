import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:supply/models/supply.dart';

/// Represents a calendar course with its associated supplies and timing information
/// Used for tomorrow's schedule detection and checklist generation
class CalendarCourseWithSupplies {
  final String courseId;
  final String courseName;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String? room;
  final List<Supply> supplies;

  CalendarCourseWithSupplies({
    required this.courseId,
    required this.courseName,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.room,
    required this.supplies,
  });

  /// Creates a TimeOfDay for the start time
  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);

  /// Creates a TimeOfDay for the end time
  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  /// Returns formatted time range (e.g., "08:00 - 09:30")
  String get timeRange {
    final start =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final end =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarCourseWithSupplies &&
          courseId == other.courseId &&
          courseName == other.courseName &&
          startHour == other.startHour &&
          startMinute == other.startMinute &&
          endHour == other.endHour &&
          endMinute == other.endMinute &&
          room == other.room &&
          listEquals(
            supplies.map((s) => s.id).toList(),
            other.supplies.map((s) => s.id).toList(),
          );

  @override
  int get hashCode => Object.hash(
        courseId,
        courseName,
        startHour,
        startMinute,
        endHour,
        endMinute,
        room,
        Object.hashAll(supplies.map((s) => s.id)),
      );

  @override
  String toString() {
    return 'CalendarCourseWithSupplies{courseName: $courseName, time: $timeRange, supplies: ${supplies.length}}';
  }

  CalendarCourseWithSupplies copyWith({
    String? courseId,
    String? courseName,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? room,
    List<Supply>? supplies,
  }) {
    return CalendarCourseWithSupplies(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      room: room ?? this.room,
      supplies: supplies ?? this.supplies,
    );
  }
}
