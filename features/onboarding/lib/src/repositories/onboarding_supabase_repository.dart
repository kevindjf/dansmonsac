import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/repository/course_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';

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

      return preferenceRepository.storeFinishOnboarding();
    });
  }

  @override
  Future<Either<Failure, CourseWithSupplies>> storeCourse(
      String courseName, List<String> supplies) {
    return courseRepository.store(AddCourseCommand(courseName, supplies));
  }
}
