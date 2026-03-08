import 'package:common/src/services/log_service.dart';
import 'package:main/di/riverpod_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_check_controller.g.dart';

/// Controller for managing daily supply check state
///
/// Responsibilities:
/// - Load checks for a specific date
/// - Toggle check state (checked/unchecked)
/// - Provide reactive state updates to UI
@riverpod
class DailyCheckController extends _$DailyCheckController {
  @override
  FutureOr<Map<String, bool>> build() async {
    // Initial state: empty map
    // UI will call loadChecksForDate to populate
    return {};
  }

  /// Load all checks for a specific date and update state
  ///
  /// AC2: State restored on app reopen
  ///
  /// Parameters:
  /// - [date]: Target date to load checks for
  ///
  /// Returns: Map of supplyId -> isChecked
  Future<Map<String, bool>> loadChecksForDate(DateTime date) async {
    LogService.d('DailyCheckController.loadChecksForDate: date=$date');

    final repository = ref.read(dailyCheckRepositoryProvider);
    final result = await repository.getDailyChecksForDate(date);

    return result.fold(
      (failure) {
        LogService.e('Failed to load daily checks', failure);
        // Return empty map on failure
        return <String, bool>{};
      },
      (checks) {
        // Convert List<DailyCheckEntity> to Map<String, bool>
        final checkMap = {
          for (var check in checks) check.supplyId: check.isChecked
        };

        LogService.d(
          'DailyCheckController: Loaded ${checks.length} checks for $date',
        );

        // Update state
        state = AsyncValue.data(checkMap);
        return checkMap;
      },
    );
  }

  /// Toggle check state for a supply
  ///
  /// AC1: Immediate persistence on check/uncheck
  /// AC3: Uncheck updates state
  ///
  /// Parameters:
  /// - [supplyId]: ID of the supply to toggle
  /// - [courseId]: ID of the course (can be empty for standalone supplies)
  /// - [date]: Target date for the check
  /// - [isChecked]: New check state
  Future<void> toggleCheck(
    String supplyId,
    String courseId,
    DateTime date,
    bool isChecked,
  ) async {
    LogService.d(
      'DailyCheckController.toggleCheck: supply=$supplyId, checked=$isChecked',
    );

    final repository = ref.read(dailyCheckRepositoryProvider);
    final result = await repository.toggleSupplyCheck(
      supplyId,
      courseId,
      date,
      isChecked,
    );

    result.fold(
      (failure) {
        LogService.e('Failed to toggle supply check', failure);
        // On failure, don't update state - let UI handle error
      },
      (_) {
        // On success, update state immediately for instant UI feedback
        state.whenData((currentMap) {
          final updatedMap = Map<String, bool>.from(currentMap);
          updatedMap[supplyId] = isChecked;
          state = AsyncValue.data(updatedMap);

          LogService.d(
            'DailyCheckController: State updated for supply=$supplyId',
          );
        });
      },
    );
  }
}

