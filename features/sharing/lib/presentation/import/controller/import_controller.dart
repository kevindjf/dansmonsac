import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/di/riverpod_di.dart' as course_di;
import 'package:schedule/models/calendar_course.dart';
import 'package:schedule/di/riverpod_di.dart' as schedule_di;
import '../../../di/riverpod_di.dart';
import '../../../models/import_result.dart';
import '../../../models/shared_schedule_data.dart';
import '../../../services/code_generator.dart';
import 'import_state.dart';

part 'import_controller.g.dart';

@riverpod
class ImportController extends _$ImportController {
  @override
  ImportState build(String code) {
    _fetchSchedule(code);
    return const ImportState();
  }

  Future<void> _fetchSchedule(String code) async {
    if (!CodeGenerator.isValid(code)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Code invalide',
      );
      return;
    }

    final repo = ref.read(sharingRepositoryProvider);
    final result = await repo.fetchByCode(code);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Code introuvable ou erreur reseau',
        );
      },
      (schedule) {
        state = state.copyWith(
          isLoading: false,
          schedule: schedule,
        );
      },
    );
  }

  Future<void> startImport() async {
    if (state.schedule == null) return;

    state = state.copyWith(isImporting: true, errorMessage: null);

    try {
      // Step 1: Analyze conflicts
      final courseRepo = ref.read(course_di.courseRepositoryProvider);
      final existingCoursesResult = await courseRepo.fetchCourses();

      final existingCourses = existingCoursesResult.fold(
        (failure) => <CourseWithSupplies>[],
        (courses) => courses,
      );

      final existingCourseMap = {for (var c in existingCourses) c.name: c};

      final conflicts = <ImportConflict>[];
      final toCreate = <SharedCourseData>[];
      final skipped = <String>[];

      for (final importedCourse in state.schedule!.data.courses) {
        final existing = existingCourseMap[importedCourse.name];

        if (existing == null) {
          // New course - will create
          toCreate.add(importedCourse);
        } else {
          // Check if supplies are different
          final existingSupplyNames = existing.supplies.map((s) => s.name).toSet();
          final importedSupplyNames = importedCourse.supplies.toSet();

          if (existingSupplyNames.containsAll(importedSupplyNames) &&
              importedSupplyNames.containsAll(existingSupplyNames)) {
            // Exact duplicate - skip
            skipped.add(importedCourse.name);
          } else {
            // Different supplies - conflict
            conflicts.add(ImportConflict(
              courseName: importedCourse.name,
              existingSupplies: existing.supplies.map((s) => s.name).toList(),
              importedSupplies: importedCourse.supplies,
              existingCourseId: existing.id,
            ));
          }
        }
      }

      // If there are conflicts, pause and ask user
      if (conflicts.isNotEmpty) {
        state = state.copyWith(
          isImporting: false,
          pendingConflicts: conflicts,
          currentConflictIndex: 0,
        );
        return;
      }

      // No conflicts - proceed with import
      await _executeImport(toCreate, skipped, []);
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: 'Erreur lors de l\'import: ${e.toString()}',
      );
    }
  }

  void resolveConflict(ConflictResolution resolution) {
    if (!state.isResolvingConflicts) return;

    final conflicts = List<ImportConflict>.from(state.pendingConflicts);
    conflicts[state.currentConflictIndex].resolution = resolution;

    final nextIndex = state.currentConflictIndex + 1;

    if (nextIndex >= conflicts.length) {
      // All conflicts resolved - execute import
      state = state.copyWith(
        pendingConflicts: conflicts,
        currentConflictIndex: nextIndex,
        isImporting: true,
      );
      _executeImportWithResolvedConflicts();
    } else {
      // Move to next conflict
      state = state.copyWith(
        pendingConflicts: conflicts,
        currentConflictIndex: nextIndex,
      );
    }
  }

  Future<void> _executeImportWithResolvedConflicts() async {
    try {
      final courseRepo = ref.read(course_di.courseRepositoryProvider);
      final existingCoursesResult = await courseRepo.fetchCourses();

      final existingCourses = existingCoursesResult.fold(
        (failure) => <CourseWithSupplies>[],
        (courses) => courses,
      );

      final existingCourseMap = {for (var c in existingCourses) c.name: c};

      final toCreate = <SharedCourseData>[];
      final skipped = <String>[];

      for (final importedCourse in state.schedule!.data.courses) {
        final existing = existingCourseMap[importedCourse.name];

        if (existing == null) {
          toCreate.add(importedCourse);
        } else {
          // Check if this course was in conflicts
          final conflict = state.pendingConflicts.firstWhere(
            (c) => c.courseName == importedCourse.name,
            orElse: () => ImportConflict(
              courseName: '',
              existingSupplies: [],
              importedSupplies: [],
            ),
          );

          if (conflict.courseName.isEmpty) {
            // Not a conflict - must be exact duplicate
            skipped.add(importedCourse.name);
          }
        }
      }

      await _executeImport(toCreate, skipped, state.pendingConflicts);
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: 'Erreur lors de l\'import: ${e.toString()}',
      );
    }
  }

  Future<void> _executeImport(
    List<SharedCourseData> toCreate,
    List<String> skipped,
    List<ImportConflict> resolvedConflicts,
  ) async {
    final courseRepo = ref.read(course_di.courseRepositoryProvider);
    final calendarRepo = ref.read(schedule_di.calendarCourseRepositoryProvider);

    final createdCourses = <String>[];
    final courseNameToId = <String, String>{};

    // Fetch existing courses to get their IDs
    final existingCoursesResult = await courseRepo.fetchCourses();
    final existingCourses = existingCoursesResult.fold(
      (failure) => <CourseWithSupplies>[],
      (courses) => courses,
    );

    for (var c in existingCourses) {
      courseNameToId[c.name] = c.id;
    }

    // Create new courses
    for (final courseData in toCreate) {
      final result = await courseRepo.store(
        AddCourseCommand(courseData.name, courseData.supplies),
      );

      result.fold(
        (failure) {
          // Log error but continue
        },
        (course) {
          createdCourses.add(course.name);
          courseNameToId[course.name] = course.id;
        },
      );
    }

    // Handle resolved conflicts
    for (final conflict in resolvedConflicts) {
      switch (conflict.resolution) {
        case ConflictResolution.keepExisting:
          skipped.add(conflict.courseName);
          break;
        case ConflictResolution.replace:
          // Delete existing course and create new one
          if (conflict.existingCourseId != null) {
            await courseRepo.deleteCourse(conflict.existingCourseId!);
          }
          final importedCourse = state.schedule!.data.courses.firstWhere(
            (c) => c.name == conflict.courseName,
          );
          final result = await courseRepo.store(
            AddCourseCommand(importedCourse.name, importedCourse.supplies),
          );
          result.fold(
            (failure) {},
            (course) {
              createdCourses.add(course.name);
              courseNameToId[course.name] = course.id;
            },
          );
          break;
        case ConflictResolution.merge:
          // Add new supplies to existing course
          final mergedSupplies = conflict.mergedSupplies;
          if (conflict.existingCourseId != null) {
            await courseRepo.deleteCourse(conflict.existingCourseId!);
          }
          final result = await courseRepo.store(
            AddCourseCommand(conflict.courseName, mergedSupplies),
          );
          result.fold(
            (failure) {},
            (course) {
              createdCourses.add(course.name);
              courseNameToId[course.name] = course.id;
            },
          );
          break;
        case null:
          skipped.add(conflict.courseName);
          break;
      }
    }

    // Import calendar entries
    int calendarEntriesImported = 0;
    for (final entry in state.schedule!.data.calendarCourses) {
      final courseId = courseNameToId[entry.courseName];
      if (courseId == null) continue;

      final calendarCourse = CalendarCourse(
        id: '', // Auto-generated
        courseId: courseId,
        roomName: entry.roomName,
        startTime: TimeOfDay(hour: entry.startTimeHour, minute: entry.startTimeMinute),
        endTime: TimeOfDay(hour: entry.endTimeHour, minute: entry.endTimeMinute),
        weekType: WeekType.values.firstWhere(
          (w) => w.name.toUpperCase() == entry.weekType.toUpperCase(),
          orElse: () => WeekType.BOTH,
        ),
        dayOfWeek: entry.dayOfWeek,
      );

      final result = await calendarRepo.addCalendarCourse(calendarCourse);
      result.fold(
        (failure) {},
        (_) => calendarEntriesImported++,
      );
    }

    state = state.copyWith(
      isImporting: false,
      result: ImportResult(
        createdCourses: createdCourses,
        skippedCourses: skipped,
        calendarEntriesImported: calendarEntriesImported,
      ),
    );
  }
}
