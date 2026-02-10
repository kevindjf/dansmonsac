import 'package:common/src/providers/database_provider.dart';
import 'package:common/src/repository/sharedPreferences_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:streak/repository/streak_repository.dart';

part 'riverpod_di.g.dart';

/// Provider for the StreakRepository
///
/// Provides access to streak tracking functionality including:
/// - Current streak calculation
/// - Bag completion history
/// - Marking bag as complete
@riverpod
StreakRepository streakRepository(Ref ref) {
  final database = ref.watch(databaseProvider);
  final preferenceRepository = SharedPreferencesRepository();
  return StreakRepository(database, preferenceRepository);
}

/// Provider for the current streak count
///
/// Returns the current streak as an AsyncValue<int>.
/// The streak represents consecutive school days with bag preparation completed.
///
/// Usage:
/// ```dart
/// final streakAsync = ref.watch(currentStreakProvider);
/// streakAsync.when(
///   data: (count) => Text('Streak: \$count days'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: \$err'),
/// );
/// ```
@riverpod
Future<int> currentStreak(Ref ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  final result = await repository.getCurrentStreak();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (streak) => streak,
  );
}

/// Provider for the previous streak count (before last break)
///
/// Returns the previous streak value stored in preferences.
/// Returns 0 if no previous streak exists.
@riverpod
Future<int> previousStreak(Ref ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  final result = await repository.getPreviousStreak();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (streak) => streak,
  );
}

/// Provider for the best streak ever achieved
///
/// Returns the highest streak value the user has ever reached.
/// Returns 0 if no best streak exists.
@riverpod
Future<int> bestStreak(Ref ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  final result = await repository.getBestStreak();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (streak) => streak,
  );
}

/// Provider for detecting broken streaks
///
/// Returns true if the streak was broken since last check.
/// This provider checks for missed school days without bag completion.
@riverpod
Future<bool> brokenStreak(Ref ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  final result = await repository.detectBrokenStreak();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (isBroken) => isBroken,
  );
}
