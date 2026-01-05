import 'package:common/src/utils/week_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:schedule/di/riverpod_di.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:schedule/presentation/add/controller/add_calendar_course_controller.dart';

part 'calendar_controller.g.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String room;
  final String hour;
  final DateTime startTime;
  final DateTime endTime;
  final String weekType; // 'A', 'B', or 'BOTH'

  CalendarEvent({
    required this.id,
    required this.title,
    required this.room,
    required this.hour,
    required this.startTime,
    required this.endTime,
    required this.weekType,
  });
}

enum WeekFilter {
  all,    // Planning complet
  weekA,  // Semaine A uniquement
  weekB,  // Semaine B uniquement
}

class WeekInfo {
  final String weekType; // 'A' or 'B'

  WeekInfo({required this.weekType});
}

@riverpod
class CalendarController extends _$CalendarController {
  @override
  Future<List<CalendarEvent>> build(DateTime selectedDate, WeekFilter weekFilter) async {
    return _fetchCoursesForDate(selectedDate, weekFilter);
  }

  // Get current week info (returns null if no A/B courses exist)
  Future<WeekInfo?> getCurrentWeekInfo() async {
    final repository = ref.watch(calendarCourseRepositoryProvider);
    final result = await repository.fetchCalendarCourses();

    return result.fold(
      (failure) => null,
      (courses) {
        // Check if any course uses A/B system (not all BOTH)
        final hasABSystem = courses.any((course) =>
          course.weekType == WeekType.A || course.weekType == WeekType.B
        );

        if (!hasABSystem) return null;

        // Calculate current week type
        final today = DateTime.now();
        final currentYear = today.month >= 9 ? today.year : today.year - 1;
        final schoolYearStart = DateTime(currentYear, 9, 1);
        final currentWeekType = WeekUtils.getCurrentWeekType(schoolYearStart, today);

        return WeekInfo(weekType: currentWeekType);
      },
    );
  }

  Future<List<CalendarEvent>> _fetchCoursesForDate(DateTime targetDate, WeekFilter weekFilter) async {
    final repository = ref.watch(calendarCourseRepositoryProvider);

    // Fetch all courses for name lookup
    final allCourses = await ref.watch(coursesProvider.future);
    final courseMap = {for (var c in allCourses) c.id: c};

    // Fetch all calendar courses
    final result = await repository.fetchCalendarCourses();

    return result.fold(
      (failure) {
        // Handle error - return empty list
        return [];
      },
      (courses) {
        // Get target date's day of week
        final targetWeekday = targetDate.weekday; // 1=Monday, 7=Sunday

        // TODO: Get school year start date from preferences
        // For now, use September 1st of current school year
        final currentYear = targetDate.month >= 9 ? targetDate.year : targetDate.year - 1;
        final schoolYearStart = DateTime(currentYear, 9, 1);

        // Filter courses for target date
        final dateCourses = courses.where((course) {
          // Check if course is for target date's day of week
          if (course.dayOfWeek != targetWeekday) {
            return false;
          }

          // Apply week filter
          if (weekFilter == WeekFilter.weekA) {
            // Show only courses for week A or BOTH
            return course.weekType == WeekType.A || course.weekType == WeekType.BOTH;
          } else if (weekFilter == WeekFilter.weekB) {
            // Show only courses for week B or BOTH
            return course.weekType == WeekType.B || course.weekType == WeekType.BOTH;
          } else {
            // Show all courses (Planning complet)
            return true;
          }
        }).toList();

        // Convert to CalendarEvent
        final events = <CalendarEvent>[];

        for (final course in dateCourses) {
          // Look up course name
          final courseData = courseMap[course.courseId];
          final courseName = courseData?.name ?? 'Cours';

          // Create DateTime for target date with the course times
          final startTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            course.startTime.hour,
            course.startTime.minute,
          );

          final endTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            course.endTime.hour,
            course.endTime.minute,
          );

          // Format hour string
          final hourString = '${course.startTime.hour}h${course.startTime.minute.toString().padLeft(2, '0')}-'
              '${course.endTime.hour}h${course.endTime.minute.toString().padLeft(2, '0')}';

          events.add(CalendarEvent(
            id: course.id,
            title: courseName,
            room: course.roomName,
            hour: hourString,
            startTime: startTime,
            endTime: endTime,
            weekType: course.weekType.value,
          ));
        }

        // Sort by start time
        events.sort((a, b) => a.startTime.compareTo(b.startTime));

        return events;
      },
    );
  }

  // Method to refresh courses
  void refresh() {
    ref.invalidateSelf();
  }
}
