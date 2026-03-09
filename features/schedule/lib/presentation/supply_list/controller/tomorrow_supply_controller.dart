import 'package:common/src/services/log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// Refactored to use getTomorrowCourses() repository method (Story 2.8)
@riverpod
class TomorrowSupplyController extends _$TomorrowSupplyController {
  @override
  Future<List<CourseWithSuppliesForTomorrow>> build() async {
    return _fetchTomorrowSupplies();
  }

  Future<List<CourseWithSuppliesForTomorrow>> _fetchTomorrowSupplies() async {
    try {
      LogService.d('TomorrowSupplyController: Fetching tomorrow courses via repository');

      // Use new repository method from Story 2.8
      final repository = ref.watch(calendarCourseRepositoryProvider);
      final result = await repository.getTomorrowCourses();

      return result.fold(
        (failure) {
          LogService.e('TomorrowSupplyController: Failed to fetch tomorrow courses', failure);
          return [];
        },
        (courses) {
          LogService.d('TomorrowSupplyController: Loaded ${courses.length} courses for tomorrow');

          // Map to legacy model for backwards compatibility
          // TODO: Migrate UI to use CalendarCourseWithSupplies directly
          return courses.map((course) {
            return CourseWithSuppliesForTomorrow(
              courseId: course.courseId,
              courseName: course.courseName,
              supplies: course.supplies,
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
