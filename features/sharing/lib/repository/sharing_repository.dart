import 'package:dartz/dartz.dart';
import 'package:common/src/models/network/network_failure.dart';
import '../models/shared_schedule.dart';
import '../models/shared_schedule_data.dart';

/// Abstract repository for schedule sharing operations
abstract class SharingRepository {
  /// Create a share record and return the generated code
  Future<Either<Failure, String>> createShare({
    String? sharerName,
    required SharedScheduleData data,
  });

  /// Fetch shared schedule by code
  Future<Either<Failure, SharedSchedule>> fetchByCode(String code);

  /// Check if a code already exists
  Future<Either<Failure, bool>> codeExists(String code);

  /// Update an existing share with new data
  Future<Either<Failure, void>> updateShare({
    required String code,
    String? sharerName,
    required SharedScheduleData data,
  });
}
