import 'package:course/repository/course_repository.dart';
import 'package:course/repository/course_drift_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/providers/database_provider.dart';

part 'riverpod_di.g.dart';

@riverpod
CourseRepository courseRepository(Ref<CourseRepository> ref) =>
    CourseDriftRepository(ref.watch(databaseProvider));
