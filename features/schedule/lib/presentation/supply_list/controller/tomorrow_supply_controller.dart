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
/// - Before pack time -> show today's courses
/// - After pack time -> show tomorrow's courses
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
        // Before pack time -> show today's courses
        targetDate = DateTime(now.year, now.month, now.day);
      } else {
        // After pack time -> show tomorrow's courses
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

          // Map CalendarCourseWithSupplies to CourseWithSuppliesForTomorrow
          // Only include courses that have supplies
          return courses
              .where((c) => c.supplies.isNotEmpty)
              .map((c) => CourseWithSuppliesForTomorrow(
                    courseId: c.courseId,
                    courseName: c.courseName,
                    supplies: c.supplies,
                  ))
              .toList();
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
