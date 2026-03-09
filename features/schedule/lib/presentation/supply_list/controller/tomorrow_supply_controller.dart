import 'package:common/src/services/log_service.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:schedule/di/riverpod_di.dart';
import 'package:supply/models/supply.dart';

part 'tomorrow_supply_controller.g.dart';

/// Represents a course with its supplies for tomorrow
/// DEPRECATED: Use CalendarCourseWithSupplies from schedule/models instead
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

/// Controller for tomorrow's supplies
/// Uses pack time to determine target date:
/// - Before pack time → show today's courses
/// - After pack time → show tomorrow's courses
@riverpod
class TomorrowSupplyController extends _$TomorrowSupplyController {
  @override
  Future<List<CourseWithSuppliesForTomorrow>> build() async {
    return _fetchTomorrowSupplies();
  }

  Future<List<CourseWithSuppliesForTomorrow>> _fetchTomorrowSupplies() async {
    try {
      // Calculate target date based on pack time
      final packTime = await PreferencesService.getPackTime();
      final now = DateTime.now();
      final DateTime targetDate;

      if (now.hour < packTime.hour ||
          (now.hour == packTime.hour && now.minute < packTime.minute)) {
        // Before pack time → show today's courses
        targetDate = DateTime(now.year, now.month, now.day);
      } else {
        // After pack time → show tomorrow's courses
        targetDate = DateTime(now.year, now.month, now.day + 1);
      }

      LogService.d(
          'TomorrowSupplyController: packTime=${packTime.hour}:${packTime.minute}, targetDate=$targetDate');

      final repository = ref.watch(calendarCourseRepositoryProvider);
      final result = await repository.getCoursesForDate(targetDate);

      return result.fold(
        (failure) {
          LogService.e(
              'TomorrowSupplyController: Failed to fetch courses', failure);
          return [];
        },
        (courses) {
          LogService.d(
              'TomorrowSupplyController: Loaded ${courses.length} courses for $targetDate');

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

        // Build list of courses with supplies (deduplicated by course ID)
        final coursesMap = <String, CourseWithSuppliesForTomorrow>{};

        for (final calendarCourse in targetCourses) {
          final courseData = courseMap[calendarCourse.courseId];
          if (courseData == null) continue;

          // Get supplies from CourseWithSupplies
          final supplies = courseData.supplies;

          // Only add if course has supplies and not already added
          if (supplies.isNotEmpty && !coursesMap.containsKey(courseData.id)) {
            coursesMap[courseData.id] = CourseWithSuppliesForTomorrow(
              courseId: courseData.id,
              courseName: courseData.name,
              supplies: supplies,
            );
          }).toList();
        },
      );
    } catch (e, stackTrace) {
      LogService.e('TomorrowSupplyController: Unexpected error', e, stackTrace);
      return [];
    }
  }

  // Method to refresh supplies
  void refresh() {
    LogService.d('TomorrowSupplyController: Invalidating and refreshing');
    ref.invalidateSelf();
  }
}
