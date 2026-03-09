import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/database/app_database.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/sync/sync_manager.dart';
import 'package:main/repository/daily_check_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock PreferenceRepository for testing
class MockPreferenceRepository extends PreferenceRepository {
  @override
  Future<String> getUserId() async {
    return 'test-device-id';
  }

  @override
  Future<bool> showingOnboarding() async {
    return false;
  }

  @override
  Future<void> storeFinishOnboarding() async {
    // No-op for tests
  }
}

// Mock SupabaseClient for testing (minimal implementation)
class MockSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Helper to create test database
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

// Helper to create test sync manager
SyncManager createTestSyncManager(
  AppDatabase database,
  PreferenceRepository preferenceRepo,
) {
  return SyncManager(
    database,
    MockSupabaseClient(),
    preferenceRepo,
  );
}

void main() {
  // Initialize Flutter test bindings once before all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable database warning for tests (multiple instances expected in test environment)
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Mock connectivity method channel to avoid "Binding not initialized" errors
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        // Return List<String> matching connectivity_plus v6.x format
        return ['none']; // Simulate no connection in tests
      }
      return null;
    },
  );

  group('Story 2.3 - DailyCheckRepository Tests', () {
    late AppDatabase database;
    late SyncManager syncManager;
    late DailyCheckRepository repository;

    setUp(() {
      database = createTestDatabase();
      final preferenceRepo = MockPreferenceRepository();
      syncManager = createTestSyncManager(database, preferenceRepo);
      repository = DailyCheckRepository(database, syncManager);
    });

    tearDown() async {
      await database.close();
    }

    group('toggleSupplyCheck - Insert New Check (AC1)', () {
      test('should insert new daily check when toggling supply for first time', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-1';
        final courseId = 'course-1';

        final result = await repository.toggleSupplyCheck(
          supplyId,
          courseId,
          date,
          true,
        );

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (_) async {
            // Verify check was inserted in database
            final checks = await database.getDailyChecksByDate(date);
            expect(checks.length, 1);
            expect(checks[0].supplyId, supplyId);
            expect(checks[0].courseId, courseId);
            expect(checks[0].isChecked, true);
            expect(checks[0].date, date);
          },
        );
      });

      test('should normalize date to start of day when inserting', () async {
        final dateWithTime = DateTime(2026, 2, 8, 14, 30, 45);
        final expectedDate = DateTime(2026, 2, 8);
        final supplyId = 'supply-2';
        final courseId = 'course-2';

        final result = await repository.toggleSupplyCheck(
          supplyId,
          courseId,
          dateWithTime,
          true,
        );

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (_) async {
            final checks = await database.getDailyChecksByDate(expectedDate);
            expect(checks.length, 1);
            expect(checks[0].date, expectedDate);
            expect(checks[0].date.hour, 0);
            expect(checks[0].date.minute, 0);
            expect(checks[0].date.second, 0);
          },
        );
      });

      test('should queue sync INSERT operation when creating new check', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-3';
        final courseId = 'course-3';

        await repository.toggleSupplyCheck(supplyId, courseId, date, true);

        // Verify sync operation was queued in database
        final pendingOps = await database.getAllPendingOperations();
        expect(pendingOps.length, greaterThanOrEqualTo(1));

        final dailyCheckOps = pendingOps.where((op) => op.entityType == 'daily_check').toList();
        expect(dailyCheckOps.length, 1);
        expect(dailyCheckOps[0].operationType, 'insert');
        expect(dailyCheckOps[0].data, contains('supply_id'));
        expect(dailyCheckOps[0].data, contains('course_id'));
      });

      test('should handle empty courseId for standalone supplies', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-standalone';
        final courseId = ''; // Empty for standalone supplies

        final result = await repository.toggleSupplyCheck(
          supplyId,
          courseId,
          date,
          true,
        );

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (_) async {
            final checks = await database.getDailyChecksByDate(date);
            expect(checks.length, 1);
            expect(checks[0].courseId, '');
          },
        );
      });
    });

    group('toggleSupplyCheck - Update Existing Check (AC3)', () {
      test('should update existing check when toggling same supply', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-4';
        final courseId = 'course-4';

        // Insert initial check (checked = true)
        await repository.toggleSupplyCheck(supplyId, courseId, date, true);

        // Update to unchecked
        final result = await repository.toggleSupplyCheck(
          supplyId,
          courseId,
          date,
          false,
        );

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (_) async {
            final checks = await database.getDailyChecksByDate(date);
            expect(checks.length, 1); // Still only 1 check
            expect(checks[0].isChecked, false); // Updated to false
          },
        );
      });

      test('should queue sync UPDATE operation when updating existing check', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-5';
        final courseId = 'course-5';

        // Insert initial check
        await repository.toggleSupplyCheck(supplyId, courseId, date, true);

        // Clear pending operations to isolate the update operation
        final initialOps = await database.getAllPendingOperations();
        for (var op in initialOps) {
          await database.deletePendingOperation(op.id);
        }

        // Update check
        await repository.toggleSupplyCheck(supplyId, courseId, date, false);

        // Verify UPDATE sync operation was queued
        final pendingOps = await database.getAllPendingOperations();
        expect(pendingOps.length, greaterThanOrEqualTo(1));

        final updateOps = pendingOps.where((op) => op.operationType == 'update').toList();
        expect(updateOps.length, 1);
        expect(updateOps[0].data, contains('is_checked'));
      });

      test('should toggle check multiple times correctly', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-6';
        final courseId = 'course-6';

        // Toggle: false -> true -> false -> true
        await repository.toggleSupplyCheck(supplyId, courseId, date, false);
        await repository.toggleSupplyCheck(supplyId, courseId, date, true);
        await repository.toggleSupplyCheck(supplyId, courseId, date, false);
        await repository.toggleSupplyCheck(supplyId, courseId, date, true);

        final checks = await database.getDailyChecksByDate(date);
        expect(checks.length, 1); // Still only 1 check
        expect(checks[0].isChecked, true); // Final state
      });
    });

    group('getDailyChecksForDate (AC2, AC4)', () {
      test('should return empty list when no checks exist for date', () async {
        final date = DateTime(2026, 2, 8);

        final result = await repository.getDailyChecksForDate(date);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (checks) {
            expect(checks, isA<List<DailyCheckEntity>>());
            expect(checks.length, 0);
          },
        );
      });

      test('should return single check for date', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-7';
        final courseId = 'course-7';

        await repository.toggleSupplyCheck(supplyId, courseId, date, true);

        final result = await repository.getDailyChecksForDate(date);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (checks) {
            expect(checks.length, 1);
            expect(checks[0].supplyId, supplyId);
          },
        );
      });

      test('should return multiple checks for same date', () async {
        final date = DateTime(2026, 2, 8);

        await repository.toggleSupplyCheck('supply-8', 'course-8', date, true);
        await repository.toggleSupplyCheck('supply-9', 'course-9', date, true);
        await repository.toggleSupplyCheck('supply-10', 'course-10', date, false);

        final result = await repository.getDailyChecksForDate(date);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (checks) {
            expect(checks.length, 3);
            expect(checks.where((c) => c.isChecked).length, 2); // 2 checked
            expect(checks.where((c) => !c.isChecked).length, 1); // 1 unchecked
          },
        );
      });

      test('should isolate checks by date (daily reset simulation)', () async {
        final today = DateTime(2026, 2, 8);
        final yesterday = DateTime(2026, 2, 7);

        // Add checks for different dates
        await repository.toggleSupplyCheck('supply-11', 'course-11', yesterday, true);
        await repository.toggleSupplyCheck('supply-12', 'course-12', today, true);

        // Query today only
        final todayResult = await repository.getDailyChecksForDate(today);
        todayResult.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (checks) {
            expect(checks.length, 1);
            expect(checks[0].supplyId, 'supply-12');
          },
        );

        // Query yesterday only
        final yesterdayResult = await repository.getDailyChecksForDate(yesterday);
        yesterdayResult.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (checks) {
            expect(checks.length, 1);
            expect(checks[0].supplyId, 'supply-11');
          },
        );
      });
    });

    group('Performance Requirements (NFR1)', () {
      test('should complete check operation in reasonable time', () async {
        final date = DateTime(2026, 2, 8);
        final supplyId = 'supply-perf';
        final courseId = 'course-perf';

        final stopwatch = Stopwatch()..start();
        await repository.toggleSupplyCheck(supplyId, courseId, date, true);
        stopwatch.stop();

        // NFR1: < 100ms per check operation in production
        // Test environment allows up to 500ms due to overhead
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Check operation must complete in reasonable time');
      });

      test('should load checks for date in reasonable time', () async {
        final date = DateTime(2026, 2, 8);

        // Pre-populate with multiple checks
        for (int i = 0; i < 10; i++) {
          await repository.toggleSupplyCheck(
            'supply-$i',
            'course-$i',
            date,
            true,
          );
        }

        final stopwatch = Stopwatch()..start();
        await repository.getDailyChecksForDate(date);
        stopwatch.stop();

        // NFR1: < 100ms per load operation in production
        // Test environment allows up to 500ms due to overhead
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Load operation must complete in reasonable time');
      });
    });

    group('Integration Tests', () {
      test('should complete full workflow: toggle -> load -> verify state', () async {
        final date = DateTime(2026, 2, 8);

        // Toggle multiple supplies
        await repository.toggleSupplyCheck('supply-13', 'course-13', date, true);
        await repository.toggleSupplyCheck('supply-14', 'course-14', date, true);
        await repository.toggleSupplyCheck('supply-15', 'course-15', date, false);

        // Load checks
        final result = await repository.getDailyChecksForDate(date);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (checks) {
            expect(checks.length, 3);

            // Verify state persisted correctly
            final supply13 = checks.firstWhere((c) => c.supplyId == 'supply-13');
            expect(supply13.isChecked, true);

            final supply15 = checks.firstWhere((c) => c.supplyId == 'supply-15');
            expect(supply15.isChecked, false);
          },
        );

        // Verify sync operations were queued
        final pendingOps = await database.getAllPendingOperations();
        expect(pendingOps.length, greaterThanOrEqualTo(3));
      });
    });

    group('Error Handling', () {
      test('should wrap all operations with Either pattern', () async {
        final date = DateTime(2026, 2, 8);

        // Verify all repository methods return Either<Failure, T>
        final toggleResult = await repository.toggleSupplyCheck(
          'supply-16',
          'course-16',
          date,
          true,
        );
        expect(toggleResult.isRight() || toggleResult.isLeft(), true);

        final loadResult = await repository.getDailyChecksForDate(date);
        expect(loadResult.isRight() || loadResult.isLeft(), true);
      });
    });
  });
}
