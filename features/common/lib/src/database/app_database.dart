import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/log_service.dart';

part 'app_database.g.dart';

/// Table for courses
@DataClassName('CourseEntity')
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId =>
      text().nullable()(); // ID from Supabase (kept for debugging)
  TextColumn get name => text()();
  TextColumn get color => text()();
  TextColumn get weekType => text()(); // 'A', 'B', or 'AB'
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for supplies associated with courses
@DataClassName('SupplyEntity')
class Supplies extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId =>
      text().nullable()(); // ID from Supabase (kept for debugging)
  TextColumn get courseId => text()();
  TextColumn get name => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get checkedDate => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for calendar courses (schedule)
@DataClassName('CalendarCourseEntity')
class CalendarCourses extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId =>
      text().nullable()(); // ID from Supabase (kept for debugging)
  TextColumn get courseId => text()();
  TextColumn get roomName => text().withDefault(const Constant(''))();
  IntColumn get dayOfWeek => integer()(); // 1-7 (Monday-Sunday)
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get weekType =>
      text().withDefault(const Constant('AB'))(); // 'A', 'B', or 'AB'
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for daily supply checks (Epic 2: Bag Preparation)
@DataClassName('DailyCheckEntity')
class DailyChecks extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get supplyId => text()();
  TextColumn get courseId => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for bag completion tracking (Epic 2: Streak System)
@DataClassName('BagCompletionEntity')
class BagCompletions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get deviceId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for premium status (Epic 4: Premium)
@DataClassName('PremiumStatusEntity')
class PremiumStatus extends Table {
  TextColumn get id => text()();
  BoolColumn get hasPurchased => boolean().withDefault(const Constant(false))();
  TextColumn get linkedParentId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Main database class
@DriftDatabase(tables: [
  Courses,
  Supplies,
  CalendarCourses,
  DailyChecks,
  BagCompletions,
  PremiumStatus,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Test constructor for in-memory database
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Migration v1 → v2: Add remoteId columns to existing tables
            await customStatement(
                'ALTER TABLE courses ADD COLUMN remote_id TEXT');
            await customStatement(
                'ALTER TABLE supplies ADD COLUMN remote_id TEXT');
            await customStatement(
                'ALTER TABLE calendar_courses ADD COLUMN remote_id TEXT');
            await customStatement(
                'ALTER TABLE calendar_courses ADD COLUMN room_name TEXT DEFAULT ""');
            await customStatement(
                'ALTER TABLE calendar_courses ADD COLUMN week_type TEXT DEFAULT "AB"');
          }
          if (from < 3) {
            // Migration v2 → v3: Add new tables for Epic 2 (Bag Preparation & Streak)
            await m.createTable(dailyChecks);
            await m.createTable(bagCompletions);
            await m.createTable(premiumStatus);
          }
          if (from < 4) {
            // Migration v3 → v4: Local-first architecture cleanup
            // 1. Remove PendingOperations table (no longer needed)
            await customStatement('DROP TABLE IF EXISTS pending_operations');

            // 2. Remove isSynced columns (no longer needed without background sync)
            // Note: SQLite supports ALTER TABLE DROP COLUMN since version 3.35.0 (2021)
            await customStatement('ALTER TABLE courses DROP COLUMN is_synced');
            await customStatement('ALTER TABLE supplies DROP COLUMN is_synced');
            await customStatement(
                'ALTER TABLE calendar_courses DROP COLUMN is_synced');
          }
        },
      );

  // Course operations
  Future<List<CourseEntity>> getAllCourses() => select(courses).get();

  Future<CourseEntity?> getCourseById(String id) =>
      (select(courses)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCourse(CoursesCompanion course) =>
      into(courses).insert(course);

  Future<bool> updateCourse(CoursesCompanion course) =>
      update(courses).replace(course);

  Future<int> deleteCourse(String id) =>
      (delete(courses)..where((c) => c.id.equals(id))).go();

  Future<int> updateCourseRemoteId(String localId, String remoteId) {
    return (update(courses)..where((c) => c.id.equals(localId)))
        .write(CoursesCompanion(remoteId: Value(remoteId)));
  }

  // Supply operations
  Future<List<SupplyEntity>> getAllSupplies() => select(supplies).get();

  Future<List<SupplyEntity>> getSuppliesByCourse(String courseId) =>
      (select(supplies)..where((s) => s.courseId.equals(courseId))).get();

  Future<SupplyEntity?> getSupplyById(String id) =>
      (select(supplies)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSupply(SuppliesCompanion supply) =>
      into(supplies).insert(supply);

  Future<bool> updateSupply(SuppliesCompanion supply) =>
      update(supplies).replace(supply);

  Future<int> deleteSupply(String id) =>
      (delete(supplies)..where((s) => s.id.equals(id))).go();

  Future<int> deleteSuppliesByCourse(String courseId) =>
      (delete(supplies)..where((s) => s.courseId.equals(courseId))).go();

  Future<int> updateSupplyRemoteId(String localId, String remoteId) {
    return (update(supplies)..where((s) => s.id.equals(localId)))
        .write(SuppliesCompanion(remoteId: Value(remoteId)));
  }

  // Calendar course operations
  Future<List<CalendarCourseEntity>> getAllCalendarCourses() =>
      select(calendarCourses).get();

  Future<List<CalendarCourseEntity>> getCalendarCoursesByDay(int dayOfWeek) =>
      (select(calendarCourses)..where((c) => c.dayOfWeek.equals(dayOfWeek)))
          .get();

  /// Get calendar courses for a specific day and week type
  /// Week type can be 'A', 'B', or courses with 'AB' (both weeks)
  Future<List<CalendarCourseEntity>> getCalendarCoursesByDayAndWeek(
    int dayOfWeek,
    String weekType,
  ) async {
    LogService.d(
        'AppDatabase.getCalendarCoursesByDayAndWeek: Query with dayOfWeek=$dayOfWeek, weekType=$weekType');

    // Get all courses first to debug
    final allCourses = await select(calendarCourses).get();
    LogService.d(
        'AppDatabase.getCalendarCoursesByDayAndWeek: Total courses in DB = ${allCourses.length}');
    for (final course in allCourses) {
      LogService.d(
          '  Course: id=${course.id}, dayOfWeek=${course.dayOfWeek}, weekType=${course.weekType}, courseId=${course.courseId}');
    }

    final result = await (select(calendarCourses)
          ..where((c) =>
              c.dayOfWeek.equals(dayOfWeek) &
              (c.weekType.equals('BOTH') |
                  c.weekType.equals('AB') |
                  c.weekType.equals(weekType))))
        .get();

    LogService.d(
        'AppDatabase.getCalendarCoursesByDayAndWeek: Filtered result = ${result.length} courses');
    return result;
  }

  Future<List<CalendarCourseEntity>> getCalendarCoursesByCourse(
          String courseId) =>
      (select(calendarCourses)..where((c) => c.courseId.equals(courseId)))
          .get();

  Future<CalendarCourseEntity?> getCalendarCourseById(String id) =>
      (select(calendarCourses)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertCalendarCourse(CalendarCoursesCompanion calendarCourse) =>
      into(calendarCourses).insert(calendarCourse);

  Future<bool> updateCalendarCourse(CalendarCoursesCompanion calendarCourse) =>
      update(calendarCourses).replace(calendarCourse);

  Future<int> deleteCalendarCourse(String id) =>
      (delete(calendarCourses)..where((c) => c.id.equals(id))).go();

  Future<int> deleteCalendarCoursesByCourse(String courseId) =>
      (delete(calendarCourses)..where((c) => c.courseId.equals(courseId))).go();

  Future<int> updateCalendarCourseRemoteId(String localId, String remoteId) {
    return (update(calendarCourses)..where((c) => c.id.equals(localId)))
        .write(CalendarCoursesCompanion(remoteId: Value(remoteId)));
  }

  // Migration helper methods
  Future<CourseEntity?> getCourseByRemoteId(String remoteId) =>
      (select(courses)..where((c) => c.remoteId.equals(remoteId)))
          .getSingleOrNull();

  Future<CalendarCourseEntity?> getCalendarCourseByRemoteId(String remoteId) =>
      (select(calendarCourses)..where((c) => c.remoteId.equals(remoteId)))
          .getSingleOrNull();

  // DailyChecks operations (Epic 2: Bag Preparation)
  Future<List<DailyCheckEntity>> getDailyChecksByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(dailyChecks)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(startOfDay) &
              c.date.isSmallerOrEqualValue(endOfDay)))
        .get();
  }

  Future<DailyCheckEntity?> getDailyCheckBySupply(
      String supplyId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(dailyChecks)
          ..where((c) =>
              c.supplyId.equals(supplyId) &
              c.date.isBiggerOrEqualValue(startOfDay) &
              c.date.isSmallerOrEqualValue(endOfDay)))
        .getSingleOrNull();
  }

  Future<int> insertDailyCheck(DailyChecksCompanion check) =>
      into(dailyChecks).insert(check);

  Future<bool> updateDailyCheck(DailyChecksCompanion check) =>
      update(dailyChecks).replace(check);

  Future<int> deleteDailyCheck(String id) =>
      (delete(dailyChecks)..where((c) => c.id.equals(id))).go();

  Future<int> deleteDailyChecksBySupply(String supplyId) =>
      (delete(dailyChecks)..where((c) => c.supplyId.equals(supplyId))).go();

  Future<int> deleteDailyChecksByCourse(String courseId) =>
      (delete(dailyChecks)..where((c) => c.courseId.equals(courseId))).go();

  // BagCompletions operations (Epic 2: Streak System)
  Future<List<BagCompletionEntity>> getAllBagCompletions() =>
      select(bagCompletions).get();

  Future<BagCompletionEntity?> getBagCompletionByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(bagCompletions)
          ..where((b) =>
              b.date.isBiggerOrEqualValue(startOfDay) &
              b.date.isSmallerOrEqualValue(endOfDay)))
        .getSingleOrNull();
  }

  Future<List<BagCompletionEntity>> getBagCompletionsInRange(
      DateTime start, DateTime end) {
    return (select(bagCompletions)
          ..where((b) =>
              b.date.isBiggerOrEqualValue(start) &
              b.date.isSmallerOrEqualValue(end))
          ..orderBy([(b) => OrderingTerm.desc(b.date)]))
        .get();
  }

  Future<int> insertBagCompletion(BagCompletionsCompanion completion) =>
      into(bagCompletions).insert(completion);

  Future<int> deleteBagCompletion(String id) =>
      (delete(bagCompletions)..where((b) => b.id.equals(id))).go();

  // PremiumStatus operations (Epic 4: Premium)
  Future<PremiumStatusEntity?> getPremiumStatus() =>
      select(premiumStatus).getSingleOrNull();

  Future<int> insertPremiumStatus(PremiumStatusCompanion status) =>
      into(premiumStatus).insert(status);

  Future<bool> updatePremiumStatus(PremiumStatusCompanion status) =>
      update(premiumStatus).replace(status);

  Future<int> setPurchased(bool purchased) {
    return (update(premiumStatus)..where((p) => p.id.isNotNull())).write(
        PremiumStatusCompanion(
            hasPurchased: Value(purchased), updatedAt: Value(DateTime.now())));
  }

  Future<int> setLinkedParent(String? parentId) {
    return (update(premiumStatus)..where((p) => p.id.isNotNull())).write(
        PremiumStatusCompanion(
            linkedParentId: Value(parentId), updatedAt: Value(DateTime.now())));
  }

  /// Migrate calendar courses from Supabase to local Drift DB
  /// This is a one-time migration for users who imported before the fix
  Future<void> migrateCalendarCoursesFromSupabase(
    SupabaseClient supabaseClient,
    String deviceId,
  ) async {
    LogService.d(
        'AppDatabase.migrateCalendarCoursesFromSupabase: Starting migration');

    try {
      // 1. Check if Drift table is empty
      final localCourses = await select(calendarCourses).get();
      if (localCourses.isNotEmpty) {
        LogService.d(
            'AppDatabase.migrateCalendarCoursesFromSupabase: Local DB not empty (${localCourses.length} courses), skipping migration');
        return;
      }

      // 2. Fetch from Supabase
      LogService.d(
          'AppDatabase.migrateCalendarCoursesFromSupabase: Fetching from Supabase');
      final response = await supabaseClient
          .from('calendar_courses')
          .select()
          .eq('device_id', deviceId);

      if (response.isEmpty) {
        LogService.d(
            'AppDatabase.migrateCalendarCoursesFromSupabase: No courses in Supabase, migration complete');
        return;
      }

      LogService.d(
          'AppDatabase.migrateCalendarCoursesFromSupabase: Found ${response.length} courses in Supabase');

      // 3. Insert into Drift
      // IMPORTANT: Always provide updatedAt field to avoid silent insertion failures
      int migratedCount = 0;
      for (final json in response) {
        final createdAt = DateTime.parse(json['created_at'] as String);
        final companion = CalendarCoursesCompanion(
          id: Value(json['id'] as String),
          remoteId: Value(json['id'] as String),
          courseId: Value(json['course_id'] as String),
          roomName: Value(json['room_name'] as String),
          startHour: Value(json['start_time_hour'] as int),
          startMinute: Value(json['start_time_minute'] as int),
          endHour: Value(json['end_time_hour'] as int),
          endMinute: Value(json['end_time_minute'] as int),
          weekType: Value(json['week_type'] as String),
          dayOfWeek: Value(json['day_of_week'] as int),
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
        );

        await into(calendarCourses).insert(companion);
        migratedCount++;
      }

      LogService.d(
          'AppDatabase.migrateCalendarCoursesFromSupabase: Migrated $migratedCount courses successfully');
    } catch (e, stackTrace) {
      LogService.e(
          'AppDatabase.migrateCalendarCoursesFromSupabase: Migration failed',
          e,
          stackTrace);
      // Don't rethrow - migration is optional and shouldn't block app startup
    }
  }

  // Clear all data (useful for testing or logout)
  Future<void> clearAllData() async {
    await delete(premiumStatus).go();
    await delete(bagCompletions).go();
    await delete(dailyChecks).go();
    await delete(calendarCourses).go();
    await delete(supplies).go();
    await delete(courses).go();
  }

  /// Clean duplicate data from database
  ///
  /// This method removes duplicate courses, supplies, and calendar courses
  /// keeping only the oldest entry (by createdAt) for each duplicate.
  ///
  /// Returns a map with counts: {'courses': X, 'supplies': Y, 'calendarCourses': Z}
  Future<Map<String, int>> cleanDuplicates() async {
    LogService.i('AppDatabase.cleanDuplicates: Starting duplicate cleanup');

    int coursesRemoved = 0;
    int suppliesRemoved = 0;
    int calendarCoursesRemoved = 0;

    // Clean duplicate courses
    final allCourses = await select(courses).get();
    final coursesByName = <String, List<CourseEntity>>{};

    for (final course in allCourses) {
      coursesByName.putIfAbsent(course.name, () => []).add(course);
    }

    for (final entry in coursesByName.entries) {
      final courseList = entry.value;
      if (courseList.length > 1) {
        // Sort by createdAt (oldest first)
        courseList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final toKeep = courseList.first;
        final toDelete = courseList.skip(1).toList();

        LogService.d(
            'AppDatabase.cleanDuplicates: Course "${entry.key}" has ${toDelete.length} duplicates');

        for (final duplicate in toDelete) {
          // Update supplies to point to kept course
          await (update(supplies)
                ..where((s) => s.courseId.equals(duplicate.id)))
              .write(SuppliesCompanion(courseId: Value(toKeep.id)));

          // Update calendar courses to point to kept course
          await (update(calendarCourses)
                ..where((c) => c.courseId.equals(duplicate.id)))
              .write(CalendarCoursesCompanion(courseId: Value(toKeep.id)));

          // Delete duplicate course
          await (delete(courses)..where((c) => c.id.equals(duplicate.id))).go();
          coursesRemoved++;
        }
      }
    }

    // Clean duplicate supplies
    final allSupplies = await select(supplies).get();
    final suppliesByKey = <String, List<SupplyEntity>>{};

    for (final supply in allSupplies) {
      final key = '${supply.courseId}:${supply.name}';
      suppliesByKey.putIfAbsent(key, () => []).add(supply);
    }

    for (final entry in suppliesByKey.entries) {
      final supplyList = entry.value;
      if (supplyList.length > 1) {
        supplyList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final toKeep = supplyList.first;
        final toDelete = supplyList.skip(1).toList();

        for (final duplicate in toDelete) {
          // Update daily checks to point to kept supply
          await customStatement(
            'UPDATE daily_checks SET supply_id = ? WHERE supply_id = ?',
            [toKeep.id, duplicate.id],
          );

          // Delete duplicate supply
          await (delete(supplies)..where((s) => s.id.equals(duplicate.id)))
              .go();
          suppliesRemoved++;
        }
      }
    }

    // Clean duplicate calendar courses
    final allCalendarCourses = await select(calendarCourses).get();
    final calendarCoursesByKey = <String, List<CalendarCourseEntity>>{};

    for (final cc in allCalendarCourses) {
      final key =
          '${cc.courseId}:${cc.dayOfWeek}:${cc.startHour}:${cc.startMinute}:${cc.weekType}';
      calendarCoursesByKey.putIfAbsent(key, () => []).add(cc);
    }

    for (final entry in calendarCoursesByKey.entries) {
      final ccList = entry.value;
      if (ccList.length > 1) {
        ccList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final toDelete = ccList.skip(1).toList();

        for (final duplicate in toDelete) {
          await (delete(calendarCourses)
                ..where((c) => c.id.equals(duplicate.id)))
              .go();
          calendarCoursesRemoved++;
        }
      }
    }

    LogService.i(
        'AppDatabase.cleanDuplicates: Removed $coursesRemoved courses, $suppliesRemoved supplies, $calendarCoursesRemoved calendar courses');

    return {
      'courses': coursesRemoved,
      'supplies': suppliesRemoved,
      'calendarCourses': calendarCoursesRemoved,
    };
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dansmonsac.sqlite'));
    return NativeDatabase(file);
  });
}
