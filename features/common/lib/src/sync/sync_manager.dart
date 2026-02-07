import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../repository/preference_repository.dart';
import '../services/log_service.dart';

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
  final SupabaseClient _supabaseClient;
  final PreferenceRepository _preferenceRepository;
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
    this._database,
    this._supabaseClient,
    this._preferenceRepository, {
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
          LogService.d('🌐 Network connection restored, starting sync...');
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
    LogService.d(
        '📝 Queued operation: $operationType $entityType $entityId');

    // Try to sync immediately if we have connectivity
    if (await hasConnectivity()) {
      sync();
    }
  }

  /// Sync all pending operations with the server
  Future<SyncResult> sync() async {
    if (_isSyncing) {
      LogService.d('⚠️ Sync already in progress, skipping...');
      return const SyncResult(success: false, operationsProcessed: 0);
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      // Check connectivity
      if (!await hasConnectivity()) {
        LogService.d('❌ No network connectivity, cannot sync');
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
        LogService.d('✅ No pending operations to sync');
        _updateStatus(SyncStatus.success);
        return const SyncResult(success: true, operationsProcessed: 0);
      }

      LogService.d('🔄 Syncing ${operations.length} pending operations...');

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
            LogService.d('✅ Synced ${operation.operationType} ${operation.entityType}');
          } else {
            // Increment retry count
            await _database.incrementRetryCount(operation.id);
            errorCount++;
            LogService.d('❌ Failed to sync ${operation.operationType} ${operation.entityType}');
          }
        } catch (e) {
          LogService.d('❌ Error processing operation ${operation.id}: $e');
          await _database.incrementRetryCount(operation.id);
          errorCount++;
        }
      }

      LogService.d('🎉 Sync completed: $successCount succeeded, $errorCount failed');

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
      LogService.d('❌ Sync error: $e');
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
    // Parse the data if present
    Map<String, dynamic>? dataMap;
    if (operation.data != null) {
      try {
        dataMap = json.decode(operation.data!) as Map<String, dynamic>;
      } catch (e) {
        LogService.d('⚠️ Failed to parse operation data: $e');
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
        LogService.d('⚠️ Unknown entity type: ${operation.entityType}');
        return false;
    }
  }

  /// Sync a course operation with Supabase
  Future<bool> _syncCourse(
    String entityId,
    String operationType,
    Map<String, dynamic>? data,
  ) async {
    LogService.d('🔄 Syncing course $operationType: $entityId');

    try {
      final deviceId = await _preferenceRepository.getUserId();

      switch (operationType) {
        case 'insert':
          if (data == null) {
            LogService.w('⚠️ No data for course insert operation');
            return false;
          }

          // Insert course into Supabase
          final courseInsertResponse = await _supabaseClient
              .from('courses')
              .insert({
                'course_name': data['course_name'],
              })
              .select('id')
              .single();

          final String remoteId = courseInsertResponse['id'];

          // Link course to user
          await _supabaseClient.from('courses_user').insert({
            'device_id': deviceId,
            'course_id': remoteId,
          });

          // Update local database with remote ID
          await _database.updateCourseRemoteId(entityId, remoteId);
          await _database.markCourseAsSynced(entityId);

          LogService.d('✅ Course inserted with remote ID: $remoteId');
          return true;

        case 'update':
          if (data == null) {
            LogService.w('⚠️ No data for course update operation');
            return false;
          }

          // Get the remote ID from local database
          final course = await _database.getCourseById(entityId);
          final remoteId = course?.remoteId ?? entityId;

          await _supabaseClient
              .from('courses')
              .update({'course_name': data['course_name']})
              .eq('id', remoteId);

          await _database.markCourseAsSynced(entityId);

          LogService.d('✅ Course updated: $remoteId');
          return true;

        case 'delete':
          // Get the remote ID from data or use entityId
          final remoteId = data?['remote_id'] ?? entityId;

          // Delete course supplies first
          final suppliesResponse = await _supabaseClient
              .from('course_supplies')
              .select('supply_id')
              .eq('course_id', remoteId);

          final supplyIds = (suppliesResponse as List)
              .map((item) => item['supply_id'] as String)
              .toList();

          await _supabaseClient
              .from('course_supplies')
              .delete()
              .eq('course_id', remoteId);

          // Delete supplies
          for (final supplyId in supplyIds) {
            await _supabaseClient
                .from('supplies')
                .delete()
                .eq('id', supplyId);
          }

          // Delete course-user relation
          await _supabaseClient
              .from('courses_user')
              .delete()
              .eq('course_id', remoteId);

          // Delete course
          await _supabaseClient
              .from('courses')
              .delete()
              .eq('id', remoteId);

          LogService.d('✅ Course deleted: $remoteId');
          return true;

        default:
          LogService.w('⚠️ Unknown operation type for course: $operationType');
          return false;
      }
    } catch (e) {
      LogService.e('❌ Error syncing course: $e');
      return false;
    }
  }

  /// Sync a supply operation with Supabase
  Future<bool> _syncSupply(
    String entityId,
    String operationType,
    Map<String, dynamic>? data,
  ) async {
    LogService.d('🔄 Syncing supply $operationType: $entityId');

    try {
      switch (operationType) {
        case 'insert':
          if (data == null) {
            LogService.w('⚠️ No data for supply insert operation');
            return false;
          }

          // Insert supply into Supabase
          final supplyInsertResponse = await _supabaseClient
              .from('supplies')
              .insert({
                'name': data['name'],
              })
              .select('id')
              .single();

          final String remoteId = supplyInsertResponse['id'];

          // Link supply to course
          final courseId = data['course_id'];
          if (courseId != null) {
            // Get remote course ID if needed
            final course = await _database.getCourseById(courseId);
            final remoteCourseId = course?.remoteId ?? courseId;

            await _supabaseClient.from('course_supplies').insert({
              'course_id': remoteCourseId,
              'supply_id': remoteId,
            });
          }

          // Update local database with remote ID
          await _database.updateSupplyRemoteId(entityId, remoteId);
          await _database.markSupplyAsSynced(entityId);

          LogService.d('✅ Supply inserted with remote ID: $remoteId');
          return true;

        case 'update':
          if (data == null) {
            LogService.w('⚠️ No data for supply update operation');
            return false;
          }

          // Get the remote ID from local database
          final supply = await _database.getSupplyById(entityId);
          final remoteId = supply?.remoteId ?? entityId;

          await _supabaseClient
              .from('supplies')
              .update({'name': data['name']})
              .eq('id', remoteId);

          await _database.markSupplyAsSynced(entityId);

          LogService.d('✅ Supply updated: $remoteId');
          return true;

        case 'delete':
          // Get the remote ID from data or use entityId
          final remoteId = data?['remote_id'] ?? entityId;

          // Delete course_supplies relation first
          await _supabaseClient
              .from('course_supplies')
              .delete()
              .eq('supply_id', remoteId);

          // Delete supply
          await _supabaseClient
              .from('supplies')
              .delete()
              .eq('id', remoteId);

          LogService.d('✅ Supply deleted: $remoteId');
          return true;

        default:
          LogService.w('⚠️ Unknown operation type for supply: $operationType');
          return false;
      }
    } catch (e) {
      LogService.e('❌ Error syncing supply: $e');
      return false;
    }
  }

  /// Sync a calendar course operation with Supabase
  Future<bool> _syncCalendarCourse(
    String entityId,
    String operationType,
    Map<String, dynamic>? data,
  ) async {
    LogService.d('🔄 Syncing calendar course $operationType: $entityId');

    try {
      final deviceId = await _preferenceRepository.getUserId();

      switch (operationType) {
        case 'insert':
          if (data == null) {
            LogService.w('⚠️ No data for calendar course insert operation');
            return false;
          }

          // Get remote course ID if needed
          final localCourseId = data['course_id'];
          final course = await _database.getCourseById(localCourseId);
          final remoteCourseId = course?.remoteId ?? localCourseId;

          // Insert calendar course into Supabase
          final response = await _supabaseClient
              .from('calendar_courses')
              .insert({
                'device_id': deviceId,
                'course_id': remoteCourseId,
                'room_name': data['room_name'],
                'start_time_hour': data['start_time_hour'],
                'start_time_minute': data['start_time_minute'],
                'end_time_hour': data['end_time_hour'],
                'end_time_minute': data['end_time_minute'],
                'week_type': data['week_type'],
                'day_of_week': data['day_of_week'],
              })
              .select('id')
              .single();

          final String remoteId = response['id'];

          // Update local database with remote ID
          await _database.updateCalendarCourseRemoteId(entityId, remoteId);
          await _database.markCalendarCourseAsSynced(entityId);

          LogService.d('✅ Calendar course inserted with remote ID: $remoteId');
          return true;

        case 'update':
          if (data == null) {
            LogService.w('⚠️ No data for calendar course update operation');
            return false;
          }

          // Get the remote ID from local database
          final calendarCourse = await _database.getCalendarCourseById(entityId);
          final remoteId = calendarCourse?.remoteId ?? entityId;

          // Get remote course ID if needed
          final localCourseId = data['course_id'];
          final course = await _database.getCourseById(localCourseId);
          final remoteCourseId = course?.remoteId ?? localCourseId;

          await _supabaseClient
              .from('calendar_courses')
              .update({
                'course_id': remoteCourseId,
                'room_name': data['room_name'],
                'start_time_hour': data['start_time_hour'],
                'start_time_minute': data['start_time_minute'],
                'end_time_hour': data['end_time_hour'],
                'end_time_minute': data['end_time_minute'],
                'week_type': data['week_type'],
                'day_of_week': data['day_of_week'],
              })
              .eq('id', remoteId)
              .eq('device_id', deviceId);

          await _database.markCalendarCourseAsSynced(entityId);

          LogService.d('✅ Calendar course updated: $remoteId');
          return true;

        case 'delete':
          // Get the remote ID from data or use entityId
          final remoteId = data?['remote_id'] ?? entityId;

          await _supabaseClient
              .from('calendar_courses')
              .delete()
              .eq('id', remoteId);

          LogService.d('✅ Calendar course deleted: $remoteId');
          return true;

        default:
          LogService.w('⚠️ Unknown operation type for calendar course: $operationType');
          return false;
      }
    } catch (e) {
      LogService.e('❌ Error syncing calendar course: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}
