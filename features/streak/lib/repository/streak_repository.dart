import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

/// Repository for streak tracking and bag completion management
///
/// Responsibilities:
/// - Calculate current streak (consecutive school days with bag completion)
/// - Access bag completion history
/// - Mark bag as complete for a given date
class StreakRepository {
  final AppDatabase _database;

  StreakRepository(this._database);

  /// Get the current streak count
  ///
  /// Returns the number of consecutive school days where the bag was completed.
  /// Note: Full streak calculation logic with school-day detection will be
  /// implemented in Story 2.4. This foundation returns a simple count for now.
  Future<Either<Failure, int>> getCurrentStreak() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getCurrentStreak: Calculating streak');

      try {
        final completions = await _database.getAllBagCompletions();

        // Foundation logic: count total completions
        // Story 2.4 will add school-day filtering and consecutive calculation
        final streakCount = completions.length;

        LogService.d('StreakRepository.getCurrentStreak: Streak count = $streakCount');
        return streakCount;
      } catch (e, stackTrace) {
        LogService.e('StreakRepository.getCurrentStreak: Error', e, stackTrace);
        rethrow;
      }
    });
  }

  /// Get bag completion history
  ///
  /// Returns a list of dates when the bag was marked as complete.
  Future<Either<Failure, List<DateTime>>> getBagCompletionHistory() {
    return handleErrors(() async {
      LogService.d('StreakRepository.getBagCompletionHistory: Fetching history');

      try {
        final completions = await _database.getAllBagCompletions();

        final dates = completions.map((c) => c.date).toList();

        LogService.d('StreakRepository.getBagCompletionHistory: Found ${dates.length} completions');
        return dates;
      } catch (e, stackTrace) {
        LogService.e('StreakRepository.getBagCompletionHistory: Error', e, stackTrace);
        rethrow;
      }
    });
  }

  /// Mark bag as complete for a given date
  ///
  /// Creates a new BagCompletion entry for the specified date.
  /// If an entry already exists for this date, it will not create a duplicate.
  ///
  /// [date] - The date for which to mark bag as complete
  Future<Either<Failure, void>> markBagComplete(DateTime date) {
    return handleErrors(() async {
      LogService.d('StreakRepository.markBagComplete: Marking bag complete for $date');

      try {
        // Normalize date to start of day (remove time component)
        final normalizedDate = DateTime(date.year, date.month, date.day);

        // Check if completion already exists for this date
        final existingCompletion = await _database.getBagCompletionByDate(normalizedDate);

        if (existingCompletion != null) {
          LogService.d('StreakRepository.markBagComplete: Completion already exists for $normalizedDate');
          return; // Already completed, no need to insert again
        }

        // Create new completion entry
        final companion = BagCompletionsCompanion(
          id: drift.Value(const Uuid().v4()),
          date: drift.Value(normalizedDate),
          completedAt: drift.Value(DateTime.now()),
          deviceId: drift.Value(''), // Will be set by SyncManager when syncing
          createdAt: drift.Value(DateTime.now()),
        );

        await _database.insertBagCompletion(companion);

        LogService.d('StreakRepository.markBagComplete: Bag marked complete for $normalizedDate');
      } catch (e, stackTrace) {
        LogService.e('StreakRepository.markBagComplete: Error', e, stackTrace);
        rethrow;
      }
    });
  }
}
