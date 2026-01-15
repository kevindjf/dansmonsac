import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../sync/sync_manager.dart';

/// Provider for the app database
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Dispose the database when the provider is disposed
  ref.onDispose(() {
    database.close();
  });

  return database;
});

/// Provider for the sync manager
final syncManagerProvider = Provider<SyncManager>((ref) {
  final database = ref.watch(databaseProvider);

  final syncManager = SyncManager(database);

  // Dispose the sync manager when the provider is disposed
  ref.onDispose(() {
    syncManager.dispose();
  });

  return syncManager;
});

/// Provider for the sync status stream
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.statusStream;
});

/// Provider for the current sync status (synchronous)
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.status;
});

/// Provider to trigger a manual sync
final manualSyncProvider = FutureProvider.family<SyncResult, bool>((ref, force) async {
  final syncManager = ref.watch(syncManagerProvider);
  return await syncManager.sync();
});
