import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/repository/course_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/preferences_service.dart';

import '../data/default_courses.dart';
import '../models/command/pack_time_command.dart';

class OnboardingSupabaseRepository extends OnboardingRepository {
  final SupabaseClient supabaseClient;
  final PreferenceRepository preferenceRepository;
  final CourseRepository courseRepository;

  OnboardingSupabaseRepository(
      this.supabaseClient, this.preferenceRepository, this.courseRepository);

  @override
  Future<Either<Failure, void>> storePackTime(PackTimeCommand command) async {
    return handleErrors(() async {
      final deviceId = await preferenceRepository.getUserId();

      // Prépare les données à insérer
      final data = {
        'device_id': deviceId,
        'hour': command.hour,
        'minute': command.minute,
      };

      await supabaseClient
          .from('users_preferences')
          .upsert(data, onConflict: 'device_id');

      // Save pack time locally for settings page and notifications
      await PreferencesService.setPackTime(
          TimeOfDay(hour: command.hour, minute: command.minute));

      return preferenceRepository.storeFinishOnboarding();
    });
  }

  @override
  Future<Either<Failure, CourseWithSupplies>> storeCourse(
      String courseName, List<String> supplies) {
    return courseRepository.store(AddCourseCommand(courseName, supplies));
  }

  @override
  Future<Either<Failure, void>> createDefaultCourses() async {
    return handleErrors(() async {
      // Check if user already has courses (from import)
      final existingCoursesResult = await courseRepository.fetchCourses();
      final existingCourses = existingCoursesResult.fold(
        (failure) => <CourseWithSupplies>[],
        (courses) => courses,
      );

      // Only create default courses if user has no courses
      if (existingCourses.isEmpty) {
        for (final course in DefaultCourses.frenchSchoolSubjects) {
          await courseRepository.store(AddCourseCommand(
            course['name'] as String,
            (course['supplies'] as List).cast<String>(),
          ));
        }
      }
    });
  }
}
