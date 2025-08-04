import 'package:common/src/models/network/network_failure.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/repository/course_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseSupabaseRepository extends CourseRepository {
  final SupabaseClient supabaseClient;
  final PreferenceRepository preferenceRepository;

  CourseSupabaseRepository(this.supabaseClient, this.preferenceRepository);

  @override
  Future<Either<Failure, CourseWithSupplies>> store(AddCourseCommand command) {
    return handleErrors(() async {
      final deviceId = await preferenceRepository.getUserId();

      final courseInsertResponse = await supabaseClient
          .from('courses')
          .insert({
            'course_name': command.courseName,
          })
          .select('id')
          .single();

      final String courseId = courseInsertResponse['id'];
      print("course id $courseId");

      await supabaseClient.from('courses_user').insert({
        'device_id': deviceId,
        'course_id': courseId,
      });

      if (command.supplies.isNotEmpty) {
        List<Map<String, dynamic>> newSupplies =
            command.supplies.map((supply) => {'name': supply}).toList();

        final suppliesResponse = await supabaseClient
            .from('supplies')
            .insert(newSupplies)
            .select('id, name');

        List<Map<String, dynamic>> supplyMappings = [];
        for (var supply in suppliesResponse) {
          supplyMappings.add({
            'course_id': courseId,
            'supply_id': supply['id'],
          });
        }

        await supabaseClient.from('course_supplies').insert(supplyMappings);
      }
      return CourseWithSupplies(id: courseId, name: command.courseName, supplies: []);
    });
  }

  Future<Either<Failure, List<CourseWithSupplies>>> fetchCourses() async {
    String deviceId = await preferenceRepository.getUserId();

    return handleErrors(() async {
      final response = await supabaseClient
          .from('courses_user')
          .select('courses(id, course_name, course_supplies(supply_id, supplies(id, name)))')
          .eq('device_id', deviceId);

      if (response.isEmpty) return [];

      // Transformation de la réponse pour l'adapter à votre modèle
      List<Map<String, dynamic>> formattedResponse = response
          .map((item) => item['courses'] as Map<String, dynamic>)
          .toList();

      return formattedResponse
          .map((json) => CourseWithSupplies.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) {
    return handleErrors(() async {
      // 1. Récupérer les IDs des fournitures associées à ce cours
      final suppliesResponse = await supabaseClient
          .from('course_supplies')
          .select('supply_id')
          .eq('course_id', id);

      final supplyIds = (suppliesResponse as List)
          .map((item) => item['supply_id'] as String)
          .toList();

      // 2. Supprimer les relations dans la table intermédiaire
      await supabaseClient.from('course_supplies').delete().eq('course_id', id);

      // 3. Supprimer les fournitures si nécessaire
      if (supplyIds.isNotEmpty) {

        // Alternative: supprimer les fournitures une par une
        for (final supplyId in supplyIds) {
          await supabaseClient
              .from('supplies')
              .delete()
              .eq('id', supplyId);
        }
      }

      // 4. Supprimer le cours
      await supabaseClient.from('courses').delete().eq('id', id);
    });
  }
}
