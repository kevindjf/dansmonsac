import 'package:common/src/services/log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/providers/database_provider.dart';
import 'package:schedule/models/calendar_course_with_supplies.dart';
import 'package:schedule/repository/calendar_course_repository.dart';

part 'riverpod_di.g.dart';

@riverpod
CalendarCourseRepository calendarCourseRepository(
        Ref<CalendarCourseRepository> ref) =>
    CalendarCourseSupabaseRepository(
        ref.watch(supabaseClient), ref.watch(preferenceRepositoryProvider));
