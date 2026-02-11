import 'package:common/src/services/log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:common/src/providers/database_provider.dart';
import 'package:schedule/models/calendar_course_with_supplies.dart';
import 'package:schedule/repository/calendar_course_repository.dart';

part 'riverpod_di.g.dart';

@riverpod
CalendarCourseRepository calendarCourseRepository(Ref<CalendarCourseRepository> ref) =>
    CalendarCourseSupabaseRepository(
      ref.watch(supabaseClient),
      ref.watch(preferenceRepositoryProvider),
      ref.watch(databaseProvider),
    );

/// Provider for tomorrow's courses with supplies
/// Returns list of courses scheduled for tomorrow, grouped by course with supplies
/// Returns empty list if tomorrow is a weekend or has no classes
@riverpod
Future<List<CalendarCourseWithSupplies>> tomorrowCourses(Ref ref) async {
  final repository = ref.watch(calendarCourseRepositoryProvider);
  final result = await repository.getTomorrowCourses();

  return result.fold(
    (failure) {
      LogService.e('tomorrowCoursesProvider: Failed to fetch tomorrow courses', failure);
      throw Exception('Failed to load tomorrow courses: ${failure.message}');
    },
    (courses) => courses,
  );
}
