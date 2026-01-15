import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Table for courses
@DataClassName('CourseEntity')
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  TextColumn get weekType => text()(); // 'A', 'B', or 'AB'
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for supplies associated with courses
@DataClassName('SupplyEntity')
class Supplies extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get name => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get checkedDate => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for calendar courses (schedule)
@DataClassName('CalendarCourseEntity')
class CalendarCourses extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  IntColumn get dayOfWeek => integer()(); // 1-7 (Monday-Sunday)
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for pending operations to sync with Supabase
@DataClassName('PendingOperationEntity')
class PendingOperations extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'course', 'supply', 'calendar_course'
  TextColumn get entityId => text()();
  TextColumn get operationType => text()(); // 'create', 'update', 'delete'
  TextColumn get data => text().nullable()(); // JSON data for create/update
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Main database class
@DriftDatabase(tables: [Courses, Supplies, CalendarCourses, PendingOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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

  Future<int> markCourseAsSynced(String id) {
    return (update(courses)..where((c) => c.id.equals(id)))
        .write(const CoursesCompanion(isSynced: Value(true)));
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

  Future<int> markSupplyAsSynced(String id) {
    return (update(supplies)..where((s) => s.id.equals(id)))
        .write(const SuppliesCompanion(isSynced: Value(true)));
  }

  // Calendar course operations
  Future<List<CalendarCourseEntity>> getAllCalendarCourses() =>
      select(calendarCourses).get();

  Future<List<CalendarCourseEntity>> getCalendarCoursesByDay(int dayOfWeek) =>
      (select(calendarCourses)..where((c) => c.dayOfWeek.equals(dayOfWeek)))
          .get();

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
      (delete(calendarCourses)..where((c) => c.courseId.equals(courseId)))
          .go();

  Future<int> markCalendarCourseAsSynced(String id) {
    return (update(calendarCourses)..where((c) => c.id.equals(id)))
        .write(const CalendarCoursesCompanion(isSynced: Value(true)));
  }

  // Pending operation operations
  Future<List<PendingOperationEntity>> getAllPendingOperations() =>
      select(pendingOperations).get();

  Future<int> insertPendingOperation(
          PendingOperationsCompanion operation) =>
      into(pendingOperations).insert(operation);

  Future<int> deletePendingOperation(String id) =>
      (delete(pendingOperations)..where((o) => o.id.equals(id))).go();

  Future<int> incrementRetryCount(String id) async {
    final operation = await (select(pendingOperations)
          ..where((o) => o.id.equals(id)))
        .getSingleOrNull();

    if (operation == null) return 0;

    return (update(pendingOperations)..where((o) => o.id.equals(id))).write(
        PendingOperationsCompanion(
            retryCount: Value(operation.retryCount + 1)));
  }

  // Clear all data (useful for testing or logout)
  Future<void> clearAllData() async {
    await delete(pendingOperations).go();
    await delete(calendarCourses).go();
    await delete(supplies).go();
    await delete(courses).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dansmonsac.sqlite'));
    return NativeDatabase(file);
  });
}
