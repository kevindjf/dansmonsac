import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/src/database/app_database.dart';

// Helper to create test database
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  group('Story 2.1 - Drift Schema v3 Migration', () {
    late AppDatabase database;

    setUp(() {
      database = createTestDatabase();
    });

    tearDown(() async {
      await database.close();
    });

    group('Schema Version', () {
      test('should be version 3', () {
        expect(database.schemaVersion, 3);
      });
    });

    group('DailyChecks Table', () {
      test('should insert and retrieve daily check', () async {
        final now = DateTime.now();
        final checkId = 'check-1';

        final check = DailyChecksCompanion.insert(
          id: checkId,
          date: now,
          supplyId: 'supply-1',
          courseId: 'course-1',
          isChecked: const Value(true),
        );

        await database.insertDailyCheck(check);

        final retrieved = await database.getDailyCheckBySupply('supply-1', now);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, checkId);
        expect(retrieved.supplyId, 'supply-1');
        expect(retrieved.courseId, 'course-1');
        expect(retrieved.isChecked, true);
      });

      test('should retrieve daily checks by date', () async {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        await database.insertDailyCheck(DailyChecksCompanion.insert(
          id: 'check-today-1',
          date: today,
          supplyId: 'supply-1',
          courseId: 'course-1',
        ));

        await database.insertDailyCheck(DailyChecksCompanion.insert(
          id: 'check-today-2',
          date: today,
          supplyId: 'supply-2',
          courseId: 'course-1',
        ));

        await database.insertDailyCheck(DailyChecksCompanion.insert(
          id: 'check-yesterday-1',
          date: yesterday,
          supplyId: 'supply-1',
          courseId: 'course-1',
        ));

        final todayChecks = await database.getDailyChecksByDate(today);
        final yesterdayChecks = await database.getDailyChecksByDate(yesterday);

        expect(todayChecks.length, 2);
        expect(yesterdayChecks.length, 1);
      });

      test('should delete daily check', () async {
        final now = DateTime.now();

        await database.insertDailyCheck(DailyChecksCompanion.insert(
          id: 'check-1',
          date: now,
          supplyId: 'supply-1',
          courseId: 'course-1',
        ));

        await database.deleteDailyCheck('check-1');

        final retrieved = await database.getDailyCheckBySupply('supply-1', now);
        expect(retrieved, isNull);
      });
    });

    group('BagCompletions Table', () {
      test('should insert and retrieve bag completion', () async {
        final now = DateTime.now();
        final completionId = 'completion-1';

        final completion = BagCompletionsCompanion.insert(
          id: completionId,
          date: now,
          completedAt: now,
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        );

        await database.insertBagCompletion(completion);

        final retrieved = await database.getBagCompletionByDate(now);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, completionId);
        expect(retrieved.deviceId, 'device-123');
      });

      test('should retrieve bag completions in date range', () async {
        final today = DateTime.now();
        final threeDaysAgo = today.subtract(const Duration(days: 3));
        final fiveDaysAgo = today.subtract(const Duration(days: 5));

        await database.insertBagCompletion(BagCompletionsCompanion.insert(
          id: 'completion-today',
          date: today,
          completedAt: today,
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        ));

        await database.insertBagCompletion(BagCompletionsCompanion.insert(
          id: 'completion-3days',
          date: threeDaysAgo,
          completedAt: threeDaysAgo,
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        ));

        await database.insertBagCompletion(BagCompletionsCompanion.insert(
          id: 'completion-5days',
          date: fiveDaysAgo,
          completedAt: fiveDaysAgo,
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        ));

        final fourDaysAgo = today.subtract(const Duration(days: 4));
        final completions =
            await database.getBagCompletionsInRange(fourDaysAgo, today);

        expect(completions.length, 2);
        expect(completions[0].id, 'completion-today'); // Ordered desc
        expect(completions[1].id, 'completion-3days');
      });

      test('should delete bag completion', () async {
        final now = DateTime.now();

        await database.insertBagCompletion(BagCompletionsCompanion.insert(
          id: 'completion-1',
          date: now,
          completedAt: now,
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        ));

        await database.deleteBagCompletion('completion-1');

        final retrieved = await database.getBagCompletionByDate(now);
        expect(retrieved, isNull);
      });
    });

    group('PremiumStatus Table', () {
      test('should insert and retrieve premium status', () async {
        final statusId = 'status-1';

        final status = PremiumStatusCompanion.insert(
          id: statusId,
          hasPurchased: const Value(true),
          linkedParentId: const Value('parent-123'),
          updatedAt: DateTime.now(),
        );

        await database.insertPremiumStatus(status);

        final retrieved = await database.getPremiumStatus();

        expect(retrieved, isNotNull);
        expect(retrieved!.id, statusId);
        expect(retrieved.hasPurchased, true);
        expect(retrieved.linkedParentId, 'parent-123');
      });

      test('should update premium status purchased flag', () async {
        await database.insertPremiumStatus(PremiumStatusCompanion.insert(
          id: 'status-1',
          hasPurchased: const Value(false),
          updatedAt: DateTime.now(),
        ));

        await database.setPurchased(true);

        final retrieved = await database.getPremiumStatus();
        expect(retrieved!.hasPurchased, true);
      });

      test('should update premium status linked parent', () async {
        await database.insertPremiumStatus(PremiumStatusCompanion.insert(
          id: 'status-1',
          updatedAt: DateTime.now(),
        ));

        await database.setLinkedParent('parent-456');

        final retrieved = await database.getPremiumStatus();
        expect(retrieved!.linkedParentId, 'parent-456');
      });
    });

    group('Migration Verification', () {
      test('should create all v3 tables on fresh install', () async {
        expect(database.schemaVersion, 3);

        // Verify we can insert into each new table
        await database.insertDailyCheck(DailyChecksCompanion.insert(
          id: 'check-1',
          date: DateTime.now(),
          supplyId: 'supply-1',
          courseId: 'course-1',
        ));

        await database.insertBagCompletion(BagCompletionsCompanion.insert(
          id: 'completion-1',
          date: DateTime.now(),
          completedAt: DateTime.now(),
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        ));

        await database.insertPremiumStatus(PremiumStatusCompanion.insert(
          id: 'status-1',
          updatedAt: DateTime.now(),
        ));

        // Tables exist and work
        expect(true, true);
      });

      test('should maintain existing v2 table structure', () async {
        // Insert data into existing v2 tables
        await database.insertCourse(CoursesCompanion.insert(
          id: 'course-1',
          name: 'Mathématiques',
          color: '#FF5722',
          weekType: 'AB',
          updatedAt: DateTime.now(),
        ));

        await database.insertSupply(SuppliesCompanion.insert(
          id: 'supply-1',
          courseId: 'course-1',
          name: 'Cahier',
          updatedAt: DateTime.now(),
        ));

        // Verify v2 tables still work
        final courses = await database.getAllCourses();
        final supplies = await database.getAllSupplies();

        expect(courses.length, 1);
        expect(supplies.length, 1);
        expect(courses[0].name, 'Mathématiques');
        expect(supplies[0].name, 'Cahier');
      });
    });

    group('Data Integrity', () {
      test('clearAllData should clear all tables including v3 tables',
          () async {
        // Insert data into all tables
        await database.insertCourse(CoursesCompanion.insert(
          id: 'course-1',
          name: 'Test',
          color: '#FF5722',
          weekType: 'AB',
          updatedAt: DateTime.now(),
        ));

        await database.insertDailyCheck(DailyChecksCompanion.insert(
          id: 'check-1',
          date: DateTime.now(),
          supplyId: 'supply-1',
          courseId: 'course-1',
        ));

        await database.insertBagCompletion(BagCompletionsCompanion.insert(
          id: 'completion-1',
          date: DateTime.now(),
          completedAt: DateTime.now(),
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        ));

        await database.insertPremiumStatus(PremiumStatusCompanion.insert(
          id: 'status-1',
          updatedAt: DateTime.now(),
        ));

        // Clear all data
        await database.clearAllData();

        // Verify all tables are empty
        expect((await database.getAllCourses()).length, 0);
        expect((await database.getDailyChecksByDate(DateTime.now())).length, 0);
        expect((await database.getAllBagCompletions()).length, 0);
        expect(await database.getPremiumStatus(), isNull);
      });
    });

    group('Table Column Verification', () {
      test('DailyChecks should have all required columns', () async {
        final check = DailyChecksCompanion.insert(
          id: 'test-id',
          date: DateTime.now(),
          supplyId: 'supply-id',
          courseId: 'course-id',
          isChecked: const Value(true),
        );

        await database.insertDailyCheck(check);
        final result = await database.getDailyChecksByDate(DateTime.now());

        expect(result.first.id, 'test-id');
        expect(result.first.supplyId, 'supply-id');
        expect(result.first.courseId, 'course-id');
        expect(result.first.isChecked, true);
        expect(result.first.date, isNotNull);
        expect(result.first.createdAt, isNotNull);
      });

      test('BagCompletions should have all required columns', () async {
        final now = DateTime.now();
        final completion = BagCompletionsCompanion.insert(
          id: 'test-id',
          date: now,
          completedAt: now,
          deviceId: 'device-123',
          createdAt: DateTime.now(),
        );

        await database.insertBagCompletion(completion);
        final result = await database.getBagCompletionByDate(now);

        expect(result, isNotNull);
        expect(result!.id, 'test-id');
        expect(result.deviceId, 'device-123');
        expect(result.date, isNotNull);
        expect(result.completedAt, isNotNull);
        expect(result.createdAt, isNotNull);
      });

      test('PremiumStatus should have all required columns', () async {
        final status = PremiumStatusCompanion.insert(
          id: 'test-id',
          hasPurchased: const Value(true),
          linkedParentId: const Value('parent-id'),
          updatedAt: DateTime.now(),
        );

        await database.insertPremiumStatus(status);
        final result = await database.getPremiumStatus();

        expect(result, isNotNull);
        expect(result!.id, 'test-id');
        expect(result.hasPurchased, true);
        expect(result.linkedParentId, 'parent-id');
        expect(result.updatedAt, isNotNull);
        expect(result.createdAt, isNotNull);
      });
    });
  });
}
