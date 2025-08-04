import 'package:course/repository/course_repository.dart';
import 'package:course/repository/course_supabase_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';

part 'riverpod_di.g.dart';

@riverpod
CourseRepository courseRepository(Ref<CourseRepository> ref) =>
    CourseSupabaseRepository(
        ref.watch(supabaseClient), ref.watch(preferenceRepositoryProvider));
