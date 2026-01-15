import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Sync status enum
enum SyncStatus {
  idle, // Not syncing
  syncing, // Currently syncing
  error, // Error occurred
  success, // Last sync successful
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final int operationsProcessed;
  final String? errorMessage;

  const SyncResult({
    required this.success,
    required this.operationsProcessed,
    this.errorMessage,
  });
}

/// Manager for handling offline operations and synchronization
class SyncManager {
  final AppDatabase _database;
  final Connectivity _connectivity = Connectivity();
  final _uuid = const Uuid();

  // Callback for when sync status changes
  final void Function(SyncStatus status)? onSyncStatusChanged;

  // Current sync status
  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  // Stream controller for sync status
  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  // Track if we're currently syncing
  bool _isSyncing = false;

  // Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SyncManager(
    this._database, {
    this.onSyncStatusChanged,
  }) {
    _listenToConnectivity();
  }

  /// Initialize and start listening to connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // Check if we have any connectivity
        final hasConnection = results.any((result) =>
            result != ConnectivityResult.none);

        if (hasConnection && !_isSyncing) {
          // Network is back, try to sync
          print('🌐 Network connection restored, starting sync...');
          sync();
        }
      },
    );
  }

  /// Check if device has network connectivity
  Future<bool> hasConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any((result) => result != ConnectivityResult.none);
  }

  /// Update sync status
  void _updateStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
    onSyncStatusChanged?.call(status);
  }

  /// Queue a pending operation
  Future<void> queueOperation({
    required String entityType,
    required String entityId,
    required String operationType,
    String? data,
  }) async {
    final operation = PendingOperationsCompanion(
      id: Value(_uuid.v4()),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      data: Value(data),
      createdAt: Value(DateTime.now()),
      retryCount: const Value(0),
    );

    await _database.insertPendingOperation(operation);
    print(
        '📝 Queued operation: $operationType $entityType $entityId');

    // Try to sync immediately if we have connectivity
    if (await hasConnectivity()) {
      sync();
    }
  }

  /// Sync all pending operations with the server
  Future<SyncResult> sync() async {
    if (_isSyncing) {
      print('⚠️ Sync already in progress, skipping...');
      return const SyncResult(success: false, operationsProcessed: 0);
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      // Check connectivity
      if (!await hasConnectivity()) {
        print('❌ No network connectivity, cannot sync');
        _updateStatus(SyncStatus.idle);
        return const SyncResult(
          success: false,
          operationsProcessed: 0,
          errorMessage: 'No network connectivity',
        );
      }

      // Get all pending operations
      final operations = await _database.getAllPendingOperations();

      if (operations.isEmpty) {
        print('✅ No pending operations to sync');
        _updateStatus(SyncStatus.success);
        return const SyncResult(success: true, operationsProcessed: 0);
      }

      print('🔄 Syncing ${operations.length} pending operations...');

      int successCount = 0;
      int errorCount = 0;

      for (final operation in operations) {
        try {
          // Process the operation based on entity type
          final success = await _processOperation(operation);

          if (success) {
            // Remove from pending operations
            await _database.deletePendingOperation(operation.id);
            successCount++;
            print('✅ Synced ${operation.operationType} ${operation.entityType}');
          } else {
            // Increment retry count
            await _database.incrementRetryCount(operation.id);
            errorCount++;
            print('❌ Failed to sync ${operation.operationType} ${operation.entityType}');
          }
        } catch (e) {
          print('❌ Error processing operation ${operation.id}: $e');
          await _database.incrementRetryCount(operation.id);
          errorCount++;
        }
      }

      print('🎉 Sync completed: $successCount succeeded, $errorCount failed');

      if (errorCount > 0) {
        _updateStatus(SyncStatus.error);
        return SyncResult(
          success: false,
          operationsProcessed: successCount,
          errorMessage: '$errorCount operations failed',
        );
      } else {
        _updateStatus(SyncStatus.success);
        return SyncResult(success: true, operationsProcessed: successCount);
      }
    } catch (e) {
      print('❌ Sync error: $e');
      _updateStatus(SyncStatus.error);
      return SyncResult(
        success: false,
        operationsProcessed: 0,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single pending operation
  /// Returns true if the operation was successful
  Future<bool> _processOperation(PendingOperationEntity operation) async {
    // This is where you would implement the actual Supabase sync logic
    // For now, we'll return a placeholder

    // Parse the data if present
    Map<String, dynamic>? dataMap;
    if (operation.data != null) {
      try {
        dataMap = json.decode(operation.data!) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ Failed to parse operation data: $e');
        return false;
      }
    }

    switch (operation.entityType) {
      case 'course':
        return await _syncCourse(
          operation.entityId,
          operation.operationType,
          dataMap,
        );

      case 'supply':
        return await _syncSupply(
          operation.entityId,
          operation.operationType,
          dataMap,
        );

      case 'calendar_course':
        return await _syncCalendarCourse(
          operation.entityId,
          operation.operationType,
          dataMap,
        );

      default:
        print('⚠️ Unknown entity type: ${operation.entityType}');
        return false;
    }
  }

  /// Sync a course operation with Supabase
  Future<bool> _syncCourse(
    String entityId,
    String operationType,
    Map<String, dynamic>? data,
  ) async {
    // TODO: Implement actual Supabase sync logic
    // This is a placeholder that will be implemented in Phase 3

    print('🔄 Syncing course $operationType: $entityId');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // For now, mark as synced in the database
    if (operationType != 'delete') {
      await _database.markCourseAsSynced(entityId);
    }

    return true; // Placeholder success
  }

  /// Sync a supply operation with Supabase
  Future<bool> _syncSupply(
    String entityId,
    String operationType,
    Map<String, dynamic>? data,
  ) async {
    // TODO: Implement actual Supabase sync logic
    // This is a placeholder that will be implemented in Phase 3

    print('🔄 Syncing supply $operationType: $entityId');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // For now, mark as synced in the database
    if (operationType != 'delete') {
      await _database.markSupplyAsSynced(entityId);
    }

    return true; // Placeholder success
  }

  /// Sync a calendar course operation with Supabase
  Future<bool> _syncCalendarCourse(
    String entityId,
    String operationType,
    Map<String, dynamic>? data,
  ) async {
    // TODO: Implement actual Supabase sync logic
    // This is a placeholder that will be implemented in Phase 3

    print('🔄 Syncing calendar course $operationType: $entityId');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // For now, mark as synced in the database
    if (operationType != 'delete') {
      await _database.markCalendarCourseAsSynced(entityId);
    }

    return true; // Placeholder success
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}
