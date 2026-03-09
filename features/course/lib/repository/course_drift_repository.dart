import 'package:common/src/database/app_database.dart';
import 'package:common/src/models/network/network_failure.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/services/log_service.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/repository/course_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:supply/models/supply.dart';
import 'package:uuid/uuid.dart';

/// Local-first implementation of CourseRepository using Drift (SQLite)
///
/// All operations are performed on the local Drift database.
/// No Supabase calls are made - this is 100% offline-first.
class CourseDriftRepository extends CourseRepository {
  final AppDatabase database;
  final Uuid uuid = const Uuid();

  CourseDriftRepository(this.database);

  @override
  Future<Either<Failure, CourseWithSupplies>> store(AddCourseCommand command) {
    return handleErrors(() async {
      LogService.d(
          'CourseDriftRepository.store: Creating course "${command.courseName}"');

      final courseId = uuid.v4();
      final now = DateTime.now();

      // Insert course into Drift
      await database.into(database.courses).insert(
            CoursesCompanion(
              id: Value(courseId),
              remoteId: const Value(null), // No remote ID yet (local-only)
              name: Value(command.courseName),
              color: const Value(''), // Default color
              weekType: const Value('AB'), // Default week type
              updatedAt: Value(now),
              createdAt: Value(now),
            ),
          );

      LogService.d(
          'CourseDriftRepository.store: Inserted course with ID $courseId');

      // Insert supplies
      final createdSupplies = <Supply>[];
      if (command.supplies.isNotEmpty) {
        for (final supplyName in command.supplies) {
          final supplyId = uuid.v4();

          await database.into(database.supplies).insert(
                SuppliesCompanion(
                  id: Value(supplyId),
                  remoteId: const Value(null),
                  courseId: Value(courseId),
                  name: Value(supplyName),
                  isChecked: const Value(false),
                  checkedDate: const Value(null),
                  updatedAt: Value(now),
                  createdAt: Value(now),
                ),
              );

          createdSupplies.add(Supply(id: supplyId, name: supplyName));
          LogService.d(
              'CourseDriftRepository.store: Inserted supply "$supplyName"');
        }
      }

      return CourseWithSupplies(
        id: courseId,
        name: command.courseName,
        supplies: createdSupplies,
      );
    });
  }

  @override
  Future<Either<Failure, List<CourseWithSupplies>>> fetchCourses() async {
    return handleErrors(() async {
      LogService.d('CourseDriftRepository.fetchCourses: Reading from Drift');

      // Batch query: fetch all courses and supplies in 2 queries
      final coursesQuery = database.select(database.courses);
      final suppliesQuery = database.select(database.supplies);

      final allCourses = await coursesQuery.get();
      final allSupplies = await suppliesQuery.get();

      LogService.d(
          'CourseDriftRepository.fetchCourses: Found ${allCourses.length} courses and ${allSupplies.length} supplies');

      // Group supplies by courseId in memory
      final suppliesByCourse = <String, List<Supply>>{};
      for (final supply in allSupplies) {
        suppliesByCourse.putIfAbsent(supply.courseId, () => []).add(
              Supply(id: supply.id, name: supply.name),
            );
      }

      // Build CourseWithSupplies list
      final result = allCourses.map((course) {
        final supplies = suppliesByCourse[course.id] ?? [];
        return CourseWithSupplies(
          id: course.id,
          name: course.name,
          supplies: supplies,
        );
      }).toList();

      LogService.d(
          'CourseDriftRepository.fetchCourses: Returning ${result.length} courses');
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) {
    return handleErrors(() async {
      LogService.d('CourseDriftRepository.deleteCourse: Deleting course $id');

      // Delete daily checks first (manual cascade)
      final dailyChecksDeleted = await database.deleteDailyChecksByCourse(id);
      LogService.d(
          'CourseDriftRepository.deleteCourse: Deleted $dailyChecksDeleted daily checks');

      // Delete supplies (manual cascade)
      final suppliesDeleted = await (database.delete(database.supplies)
            ..where((s) => s.courseId.equals(id)))
          .go();

      LogService.d(
          'CourseDriftRepository.deleteCourse: Deleted $suppliesDeleted supplies');

      // Delete course
      final coursesDeleted = await (database.delete(database.courses)
            ..where((c) => c.id.equals(id)))
          .go();

      if (coursesDeleted == 0) {
        LogService.w(
            'CourseDriftRepository.deleteCourse: Course $id not found');
        throw Exception('Course not found');
      }

      LogService.d('CourseDriftRepository.deleteCourse: Deleted course $id');
    });
  }

  @override
  Future<Either<Failure, void>> updateCourseName(String id, String newName) {
    return handleErrors(() async {
      LogService.d(
          'CourseDriftRepository.updateCourseName: Updating course $id to "$newName"');

      final updated = await (database.update(database.courses)
            ..where((c) => c.id.equals(id)))
          .write(
        CoursesCompanion(
          name: Value(newName),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (updated == 0) {
        LogService.w(
            'CourseDriftRepository.updateCourseName: Course $id not found');
        throw Exception('Course not found');
      }

      LogService.d(
          'CourseDriftRepository.updateCourseName: Updated course $id');
    });
  }
}
