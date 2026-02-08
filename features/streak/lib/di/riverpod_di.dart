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
