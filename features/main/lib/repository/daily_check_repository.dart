import 'dart:convert';

import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/sync/sync_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

/// Repository for managing daily supply check state
///
/// Responsibilities:
/// - Toggle supply check state (checked/unchecked)
/// - Load daily checks for a specific date
/// - Queue sync operations to Supabase via SyncManager
/// - Maintain offline-first architecture
class DailyCheckRepository {
  final AppDatabase _database;
  final SyncManager _syncManager;
  final _uuid = const Uuid();

  DailyCheckRepository(this._database, this._syncManager);

  /// Toggle supply check state (insert new or update existing)
  ///
  /// AC1: Immediate persistence on check/uncheck
  /// AC3: Uncheck updates state
  /// AC5: Sync queued for Supabase
  ///
  /// Parameters:
  /// - [supplyId]: ID of the supply being checked
  /// - [courseId]: ID of the course (can be empty for standalone supplies)
  /// - [date]: Target date for the checklist
  /// - [isChecked]: New check state (true = checked, false = unchecked)
  ///
  /// Returns: Either<Failure, void>
  Future<Either<Failure, void>> toggleSupplyCheck(
    String supplyId,
    String courseId,
    DateTime date,
    bool isChecked,
  ) {
    return handleErrors(() async {
      // Normalize date to start of day (AC4: Daily reset at midnight)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      LogService.d(
        'DailyCheckRepository.toggleSupplyCheck: supply=$supplyId, '
        'course=$courseId, date=$normalizedDate, checked=$isChecked',
      );

      // Check if daily check already exists for this supply and date
      final existing = await _database.getDailyCheckBySupply(
        supplyId,
        normalizedDate,
      );

      if (existing != null) {
        // UPDATE existing check (AC3: Uncheck updates state)
        LogService.d(
          'DailyCheckRepository: Updating existing check ${existing.id}',
        );

        // Create updated entity using copyWith
        final updatedCheck = existing.copyWith(isChecked: isChecked);

        // Convert to Companion for update
        await _database.updateDailyCheck(
          DailyChecksCompanion(
            id: drift.Value(updatedCheck.id),
            date: drift.Value(updatedCheck.date),
            supplyId: drift.Value(updatedCheck.supplyId),
            courseId: drift.Value(updatedCheck.courseId),
            isChecked: drift.Value(isChecked),
            createdAt: drift.Value(updatedCheck.createdAt),
          ),
        );

        // Queue sync UPDATE operation (AC5: Sync queued for Supabase)
        await _syncManager.queueOperation(
          entityType: 'daily_check',
          entityId: existing.id,
          operationType: 'update',
          data: jsonEncode({
            'is_checked': isChecked,
          }),
        );

        LogService.i(
          'Daily check updated: supply=$supplyId, checked=$isChecked',
        );
      } else {
        // INSERT new check (AC1: Immediate persistence on check/uncheck)
        final checkId = _uuid.v4();

        LogService.d(
          'DailyCheckRepository: Creating new check $checkId',
        );

        await _database.insertDailyCheck(
          DailyChecksCompanion.insert(
            id: checkId,
            date: normalizedDate,
            supplyId: supplyId,
            courseId: courseId,
            isChecked: drift.Value(isChecked),
          ),
        );

        // Queue sync INSERT operation (AC5: Sync queued for Supabase)
        await _syncManager.queueOperation(
          entityType: 'daily_check',
          entityId: checkId,
          operationType: 'insert',
          data: jsonEncode({
            'supply_id': supplyId,
            'course_id': courseId,
            'date': normalizedDate.toIso8601String(),
            'is_checked': isChecked,
          }),
        );

        LogService.i(
          'Daily check created: supply=$supplyId, checked=$isChecked',
        );
      }
    });
  }

  /// Get all daily checks for a specific date
  ///
  /// AC2: State restored on app reopen
  /// AC4: Daily reset at midnight
  ///
  /// Parameters:
  /// - [date]: Target date to load checks for
  ///
  /// Returns: Either<Failure, List<DailyCheckEntity>>
  Future<Either<Failure, List<DailyCheckEntity>>> getDailyChecksForDate(
    DateTime date,
  ) {
    return handleErrors(() async {
      // Normalize date to start of day (AC4: Daily reset at midnight)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      LogService.d(
        'DailyCheckRepository.getDailyChecksForDate: date=$normalizedDate',
      );

      // Load all checks for the normalized date (AC2: State restored)
      final checks = await _database.getDailyChecksByDate(normalizedDate);

      LogService.d(
        'DailyCheckRepository: Loaded ${checks.length} checks for $normalizedDate',
      );

      return checks;
    });
  }
}
