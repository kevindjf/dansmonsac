import 'package:common/src/providers/database_provider.dart';
import 'package:main/repository/daily_check_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_di.g.dart';

/// Provider for the DailyCheckRepository
///
/// Provides access to daily checklist persistence functionality including:
/// - Toggle supply check state (checked/unchecked)
/// - Load daily checks for a specific date
/// - Offline-first architecture with automatic sync
@riverpod
DailyCheckRepository dailyCheckRepository(Ref ref) {
  final database = ref.watch(databaseProvider);
  final syncManager = ref.watch(syncManagerProvider);
  return DailyCheckRepository(database, syncManager);
}
