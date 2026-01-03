import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:schedule/repository/calendar_course_repository.dart';

part 'riverpod_di.g.dart';

@riverpod
CalendarCourseRepository calendarCourseRepository(Ref<CalendarCourseRepository> ref) =>
    CalendarCourseSupabaseRepository(
        ref.watch(supabaseClient), ref.watch(preferenceRepositoryProvider));
