import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supply/models/command/add_supply_command.dart';
import 'package:supply/models/supply.dart';
import 'package:supply/repository/supply_repository.dart';

class SupplySupabaseRepository extends SupplyRepository {
  final SupabaseClient supabaseClient;
  final PreferenceRepository preferenceRepository;

  SupplySupabaseRepository(this.supabaseClient, this.preferenceRepository);

  @override
  Future<Either<Failure, Supply>> store(AddSupplyCommand command) {
    return handleErrors(() async {
      final supplyInsertResponse = await supabaseClient
          .from('supplies')
          .insert({
            'name': command.name,
          })
          .select('id')
          .single();

      final String supplyId = supplyInsertResponse['id'];

      await supabaseClient.from('course_supplies').insert({
        'course_id': command.courseId,
        'supply_id': supplyId,
      });

      return Supply(id: supplyId, name: command.name);
    });
  }

  @override
  Future<Either<Failure, void>> deleteSupply(String id) {
    return handleErrors(() async {
      await supabaseClient.from('supplies').delete().eq('id', id);
    });
  }

  @override
  Future<Either<Failure, void>> updateSupplyName(String id, String newName) {
    return handleErrors(() async {
      await supabaseClient
          .from('supplies')
          .update({'name': newName}).eq('id', id);
    });
  }
}
