import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splash/presentation/controller/splash_state.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:common/src/providers/database_provider.dart';
import 'package:common/src/repository/preference_repository.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/services/preferences_service.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  late PreferenceRepository preferenceRepository;

  @override
  SplashState build() {
    preferenceRepository = ref.watch(preferenceRepositoryProvider);
    getData();
    return LoadingSplashState();
  }

  getData() async {
    // Run migration FIRST (before any other operations)
    await _runCalendarCourseMigration();

    var responses =
        await Future.wait([_checkShowOnboarding(), waitTimeToNext()]);

    var routerProvider = ref.watch(routerDelegateProvider);
    if (responses[0]) {
      routerProvider.goToOnboarding();
    } else {
      routerProvider.goToHome();
    }
  }

  /// One-time migration: Sync calendar courses from Supabase to Drift
  /// for users who imported before the offline-first fix
  Future<void> _runCalendarCourseMigration() async {
    try {
      // Check if migration already done
      final migrationDone = await PreferencesService.getCalendarMigrationDone();
      if (migrationDone) {
        LogService.d(
            'SplashController: Calendar migration already done, skipping');
        return;
      }

      LogService.d('SplashController: Running calendar course migration');

      final database = ref.read(databaseProvider);
      final supabase = ref.read(supabaseClient);
      final deviceId = await preferenceRepository.getUserId();

      await database.migrateCalendarCoursesFromSupabase(supabase, deviceId);

      // Mark as done
      await PreferencesService.setCalendarMigrationDone(true);

      LogService.d('SplashController: Calendar migration complete');
    } catch (e, stackTrace) {
      LogService.e(
          'SplashController: Calendar migration failed', e, stackTrace);
      // Don't block app startup on migration failure
    }
  }

  Future<bool> _checkShowOnboarding() async {
    return preferenceRepository.showingOnboarding();
  }

  Future waitTimeToNext() async {
    return Future.delayed(const Duration(milliseconds: 1500));
  }
}
