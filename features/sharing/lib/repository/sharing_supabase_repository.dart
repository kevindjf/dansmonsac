import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart' show handleErrors;
import '../models/shared_schedule.dart';
import '../models/shared_schedule_data.dart';
import '../services/code_generator.dart';
import 'sharing_repository.dart';

/// Supabase implementation of SharingRepository
class SharingSupabaseRepository extends SharingRepository {
  final SupabaseClient supabaseClient;

  static const String _tableName = 'shared_schedules';
  static const int _maxRetries = 5;

  SharingSupabaseRepository(this.supabaseClient);

  @override
  Future<Either<Failure, String>> createShare({
    String? sharerName,
    required SharedScheduleData data,
  }) async {
    return handleErrors(() async {
      String code;
      int attempts = 0;

      // Generate unique code with retry on collision
      do {
        code = CodeGenerator.generate();
        attempts++;

        if (attempts > _maxRetries) {
          throw Exception('Failed to generate unique code after $_maxRetries attempts');
        }

        // Check if code exists
        final existsResult = await codeExists(code);
        final exists = existsResult.fold(
          (failure) => throw Exception('Failed to check code existence'),
          (exists) => exists,
        );

        if (!exists) break;
      } while (true);

      // Insert the share record
      await supabaseClient.from(_tableName).insert({
        'code': code,
        'sharer_name': sharerName,
        'data': data.toJson(),
      });

      return code;
    });
  }

  @override
  Future<Either<Failure, SharedSchedule>> fetchByCode(String code) async {
    return handleErrors(() async {
      final normalizedCode = CodeGenerator.normalize(code);

      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('code', normalizedCode)
          .single();

      return SharedSchedule.fromJson(response);
    });
  }

  @override
  Future<Either<Failure, bool>> codeExists(String code) async {
    return handleErrors(() async {
      final normalizedCode = CodeGenerator.normalize(code);

      final response = await supabaseClient
          .from(_tableName)
          .select('code')
          .eq('code', normalizedCode)
          .maybeSingle();

      return response != null;
    });
  }

  @override
  Future<Either<Failure, void>> updateShare({
    required String code,
    String? sharerName,
    required SharedScheduleData data,
  }) async {
    return handleErrors(() async {
      final normalizedCode = CodeGenerator.normalize(code);
      final jsonData = data.toJson();

      debugPrint('updateShare: Updating code $normalizedCode');
      debugPrint('updateShare: Data has ${data.courses.length} courses and ${data.calendarCourses.length} calendar entries');
      debugPrint('updateShare: JSON calendar_courses: ${jsonData['calendar_courses']}');

      // Use .select() to get the updated row back and verify the update happened
      final response = await supabaseClient.from(_tableName).update({
        'sharer_name': sharerName,
        'data': jsonData,
      }).eq('code', normalizedCode).select();

      debugPrint('updateShare: Response = $response');

      if (response.isEmpty) {
        throw Exception('No rows updated. Check if RLS policies allow updates or if the code exists.');
      }
    });
  }
}
