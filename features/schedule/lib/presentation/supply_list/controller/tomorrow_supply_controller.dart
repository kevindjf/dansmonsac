import 'package:common/src/utils/week_utils.dart';
import 'package:common/src/services.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:schedule/di/riverpod_di.dart';
import 'package:schedule/presentation/add/controller/add_calendar_course_controller.dart';
import 'package:supply/models/supply.dart';

part 'tomorrow_supply_controller.g.dart';

/// Represents a course with its supplies for tomorrow
class CourseWithSuppliesForTomorrow {
  final String courseId;
  final String courseName;
  final List<Supply> supplies;

  CourseWithSuppliesForTomorrow({
    required this.courseId,
    required this.courseName,
    required this.supplies,
  });
}

@riverpod
class TomorrowSupplyController extends _$TomorrowSupplyController {
  @override
  Future<List<CourseWithSuppliesForTomorrow>> build() async {
    return _fetchTomorrowSupplies();
  }

  Future<List<CourseWithSuppliesForTomorrow>> _fetchTomorrowSupplies() async {
    final calendarRepository = ref.watch(calendarCourseRepositoryProvider);

    // Fetch all courses with their supplies
    final allCourses = await ref.watch(coursesProvider.future);
    final courseMap = {for (var c in allCourses) c.id: c};

    // Fetch all calendar courses
    final calendarResult = await calendarRepository.fetchCalendarCourses();

    // Get pack time and school year start from preferences
    final packTime = await PreferencesService.getPackTime();
    final schoolYearStart = await PreferencesService.getSchoolYearStart();

    return calendarResult.fold(
      (failure) => [],
      (calendarCourses) {
        final now = DateTime.now();

        // Determine target date: if current time is before pack time, show today's supplies
        // Otherwise, show tomorrow's supplies
        final targetDate = (now.hour < packTime.hour ||
                           (now.hour == packTime.hour && now.minute < packTime.minute))
            ? DateTime.now()
            : WeekUtils.getTomorrow();

        final targetWeekday = targetDate.weekday; // 1=Monday, 7=Sunday

        // Filter courses for target date
        final targetCourses = calendarCourses.where((course) {
          // Check if course is for target date's day of week
          if (course.dayOfWeek != targetWeekday) {
            return false;
          }

          // Check if course should be shown for target date's week (A/B or BOTH)
          return WeekUtils.shouldShowCourseForDate(
            course.weekType.value,
            schoolYearStart,
            targetDate,
          );
        }).toList();

        // Build list of courses with supplies
        final coursesWithSupplies = <CourseWithSuppliesForTomorrow>[];

        for (final calendarCourse in targetCourses) {
          final courseData = courseMap[calendarCourse.courseId];
          if (courseData == null) continue;

          // Get supplies from CourseWithSupplies
          final supplies = courseData.supplies;

          // Only add if course has supplies
          if (supplies.isNotEmpty) {
            coursesWithSupplies.add(CourseWithSuppliesForTomorrow(
              courseId: courseData.id,
              courseName: courseData.name,
              supplies: supplies,
            ));
          }
        }

        return coursesWithSupplies;
      },
    );
  }

  // Method to refresh supplies
  void refresh() {
    ref.invalidateSelf();
  }
}
