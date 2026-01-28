import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/di/riverpod_di.dart' as course_di;
import 'package:schedule/models/calendar_course.dart';
import 'package:schedule/di/riverpod_di.dart' as schedule_di;
import 'package:common/src/services/preferences_service.dart';
import '../../../di/riverpod_di.dart';
import '../../../models/shared_schedule_data.dart';
import 'share_state.dart';

part 'share_controller.g.dart';

@riverpod
class ShareController extends _$ShareController {
  @override
  ShareState build() {
    _loadInitialData();
    return const ShareState();
  }

  /// Load initial data (code, name) and current schedule data
  /// If there's already a code, automatically sync to Supabase
  Future<void> _loadInitialData() async {
    try {
      // Load saved code and sharer name from preferences
      final savedCode = await PreferencesService.getShareCode();
      final savedName = await PreferencesService.getSharerName();

      // Load fresh schedule data
      final data = await _fetchFreshData();

      // If there's already a code, we need to sync the data to Supabase
      if (savedCode != null) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: true,
          data: data,
          code: savedCode,
          sharerName: savedName,
        );

        // Sync with Supabase
        final repo = ref.read(sharingRepositoryProvider);
        final result = await repo.updateShare(
          code: savedCode,
          sharerName: savedName.isEmpty ? null : savedName,
          data: data,
        );

        result.fold(
          (failure) {
            debugPrint('Initial sync failed: $failure');
            state = state.copyWith(
              isSyncing: false,
              syncFailed: true,
              errorMessage: 'Les donnees n\'ont pas pu etre synchronisees. Elles ne sont peut-etre pas a jour.',
            );
          },
          (_) {
            debugPrint('Initial sync successful');
            state = state.copyWith(
              isSyncing: false,
              syncFailed: false,
            );
          },
        );
      } else {
        // No code yet, just load the data
        state = state.copyWith(
          isLoading: false,
          data: data,
          code: savedCode,
          sharerName: savedName,
        );
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors du chargement des donnees',
      );
    }
  }

  /// Fetch fresh data from local database
  /// This is called before every sync to ensure we have the latest data
  Future<SharedScheduleData> _fetchFreshData() async {
    // Fetch all courses with supplies
    final courseRepo = ref.read(course_di.courseRepositoryProvider);
    final coursesResult = await courseRepo.fetchCourses();

    // Fetch all calendar entries
    final calendarRepo = ref.read(schedule_di.calendarCourseRepositoryProvider);
    final calendarResult = await calendarRepo.fetchCalendarCourses();

    final courses = coursesResult.fold(
      (failure) => <CourseWithSupplies>[],
      (courses) => courses,
    );

    final calendarCourses = calendarResult.fold(
      (failure) => <CalendarCourse>[],
      (entries) => entries,
    );

    debugPrint('ShareController: Fetched ${courses.length} courses and ${calendarCourses.length} calendar entries');

    // Build shared data structure
    final sharedCourses = courses.map((course) {
      return SharedCourseData(
        name: course.name,
        supplies: course.supplies.map((s) => s.name).toList(),
      );
    }).toList();

    final sharedCalendarCourses = calendarCourses.map((entry) {
      // Find course name by ID
      final course = courses.firstWhere(
        (c) => c.id == entry.courseId,
        orElse: () => CourseWithSupplies(id: '', name: 'Unknown', supplies: []),
      );

      return SharedCalendarCourseData(
        courseName: course.name,
        roomName: entry.roomName,
        startTimeHour: entry.startTime.hour,
        startTimeMinute: entry.startTime.minute,
        endTimeHour: entry.endTime.hour,
        endTimeMinute: entry.endTime.minute,
        weekType: entry.weekType.name,
        dayOfWeek: entry.dayOfWeek,
      );
    }).toList();

    debugPrint('ShareController: Built ${sharedCourses.length} shared courses and ${sharedCalendarCourses.length} shared calendar entries');

    return SharedScheduleData(
      courses: sharedCourses,
      calendarCourses: sharedCalendarCourses,
    );
  }

  void updateSharerName(String name) {
    state = state.copyWith(sharerName: name);
    // Save name to preferences
    PreferencesService.setSharerName(name);
  }

  Future<void> generateCode() async {
    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      // Fetch fresh data before generating code
      final freshData = await _fetchFreshData();

      // Update state with fresh data
      state = state.copyWith(data: freshData);

      final repo = ref.read(sharingRepositoryProvider);
      final result = await repo.createShare(
        sharerName: state.sharerName.isEmpty ? null : state.sharerName,
        data: freshData,
      );

      result.fold(
        (failure) {
          debugPrint('Error generating code: $failure');
          state = state.copyWith(
            isGenerating: false,
            errorMessage: 'Erreur lors de la generation du code',
          );
        },
        (code) {
          debugPrint('Code generated successfully: $code');
          // Save code to preferences
          PreferencesService.setShareCode(code);
          state = state.copyWith(
            isGenerating: false,
            code: code,
          );
        },
      );
    } catch (e) {
      debugPrint('Exception generating code: $e');
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'Erreur lors de la generation du code',
      );
    }
  }

  /// Sync data to Supabase (called from "Synchroniser les données" button)
  /// Returns true if sync was successful, false otherwise
  Future<bool> syncData() async {
    if (state.code == null) return false;

    state = state.copyWith(isSyncing: true, errorMessage: null, syncFailed: false);

    try {
      // Fetch fresh data before syncing
      final freshData = await _fetchFreshData();

      debugPrint('syncData: Syncing ${freshData.courses.length} courses, ${freshData.calendarCourses.length} calendar entries');

      // Update state with fresh data so UI reflects current counts
      state = state.copyWith(data: freshData);

      final repo = ref.read(sharingRepositoryProvider);
      final result = await repo.updateShare(
        code: state.code!,
        sharerName: state.sharerName.isEmpty ? null : state.sharerName,
        data: freshData,
      );

      return result.fold(
        (failure) {
          debugPrint('Error syncing: $failure');
          state = state.copyWith(
            isSyncing: false,
            syncFailed: true,
            errorMessage: 'Erreur de synchronisation. Verifiez votre connexion internet.',
          );
          return false;
        },
        (_) {
          debugPrint('Sync successful!');
          state = state.copyWith(
            isSyncing: false,
            syncFailed: false,
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('Exception syncing: $e');
      state = state.copyWith(
        isSyncing: false,
        syncFailed: true,
        errorMessage: 'Erreur lors de la synchronisation',
      );
      return false;
    }
  }

  /// Sync and share: Called when sharing the link
  /// Returns true if sync was successful, false otherwise
  Future<bool> syncAndShare() async {
    return syncData();
  }
}
