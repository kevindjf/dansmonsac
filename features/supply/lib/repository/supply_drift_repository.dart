import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:supply/models/command/add_supply_command.dart';
import 'package:supply/models/supply.dart';
import 'package:supply/repository/supply_repository.dart';
import 'package:uuid/uuid.dart';

/// Local-first implementation of SupplyRepository using Drift (SQLite)
class SupplyDriftRepository extends SupplyRepository {
  final AppDatabase database;
  final Uuid uuid = const Uuid();

  SupplyDriftRepository(this.database);

  @override
  Future<Either<Failure, Supply>> store(AddSupplyCommand command) {
    return handleErrors(() async {
      LogService.d(
          'SupplyDriftRepository.store: Creating supply "${command.name}" for course ${command.courseId}');

      final supplyId = uuid.v4();
      final now = DateTime.now();

      await database.into(database.supplies).insert(
            SuppliesCompanion(
              id: Value(supplyId),
              remoteId: const Value(null),
              courseId: Value(command.courseId),
              name: Value(command.name),
              isChecked: const Value(false),
              checkedDate: const Value(null),
              updatedAt: Value(now),
              createdAt: Value(now),
            ),
          );

      LogService.d(
          'SupplyDriftRepository.store: Inserted supply with ID $supplyId');
      return Supply(id: supplyId, name: command.name);
    });
  }

  @override
  Future<Either<Failure, void>> deleteSupply(String id) {
    return handleErrors(() async {
      LogService.d('SupplyDriftRepository.deleteSupply: Deleting supply $id');

      // Cascade: delete DailyChecks referencing this supply
      final dailyChecksDeleted = await (database.delete(database.dailyChecks)
            ..where((c) => c.supplyId.equals(id)))
          .go();

      LogService.d(
          'SupplyDriftRepository.deleteSupply: Deleted $dailyChecksDeleted daily checks');

      // Delete the supply
      final suppliesDeleted = await (database.delete(database.supplies)
            ..where((s) => s.id.equals(id)))
          .go();

      if (suppliesDeleted == 0) {
        LogService.w(
            'SupplyDriftRepository.deleteSupply: Supply $id not found');
        throw Exception('Supply not found');
      }

      LogService.d('SupplyDriftRepository.deleteSupply: Deleted supply $id');
    });
  }

  @override
  Future<Either<Failure, void>> updateSupplyName(String id, String newName) {
    return handleErrors(() async {
      LogService.d(
          'SupplyDriftRepository.updateSupplyName: Updating supply $id to "$newName"');

      final updated = await (database.update(database.supplies)
            ..where((s) => s.id.equals(id)))
          .write(
        SuppliesCompanion(
          name: Value(newName),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (updated == 0) {
        LogService.w(
            'SupplyDriftRepository.updateSupplyName: Supply $id not found');
        throw Exception('Supply not found');
      }

      LogService.d(
          'SupplyDriftRepository.updateSupplyName: Updated supply $id');
    });
  }
}
