import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CalendarCourseRepository {
  Future<Either<Failure, CalendarCourse>> addCalendarCourse(CalendarCourse calendarCourse);
  Future<Either<Failure, List<CalendarCourse>>> fetchCalendarCourses();
  Future<Either<Failure, void>> deleteCalendarCourse(String id);
}

class CalendarCourseSupabaseRepository extends CalendarCourseRepository {
  final SupabaseClient supabaseClient;
  final PreferenceRepository preferenceRepository;

  CalendarCourseSupabaseRepository(this.supabaseClient, this.preferenceRepository);

  @override
  Future<Either<Failure, CalendarCourse>> addCalendarCourse(CalendarCourse calendarCourse) {
    return handleErrors(() async {
      final deviceId = await preferenceRepository.getUserId();

      final response = await supabaseClient
          .from('calendar_courses')
          .insert({
            'device_id': deviceId,
            'course_id': calendarCourse.courseId,
            'room_name': calendarCourse.roomName,
            'start_time_hour': calendarCourse.startTime.hour,
            'start_time_minute': calendarCourse.startTime.minute,
            'end_time_hour': calendarCourse.endTime.hour,
            'end_time_minute': calendarCourse.endTime.minute,
          })
          .select()
          .single();

      return CalendarCourse.fromJson(response);
    });
  }

  @override
  Future<Either<Failure, List<CalendarCourse>>> fetchCalendarCourses() async {
    final deviceId = await preferenceRepository.getUserId();

    return handleErrors(() async {
      final response = await supabaseClient
          .from('calendar_courses')
          .select()
          .eq('device_id', deviceId);

      if (response.isEmpty) return [];

      return (response as List)
          .map((json) => CalendarCourse.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> deleteCalendarCourse(String id) {
    return handleErrors(() async {
      await supabaseClient
          .from('calendar_courses')
          .delete()
          .eq('id', id);
    });
  }
}
