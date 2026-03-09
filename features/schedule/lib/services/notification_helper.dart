import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';
import 'package:common/src/providers/database_provider.dart';
import 'package:streak/di/riverpod_di.dart';
import '../di/riverpod_di.dart';

/// Helper for refreshing notifications after calendar changes
///
/// Provides a centralized, reusable way to update notifications
/// when calendar events are modified (add, edit, delete).
///
/// Used across multiple modules: main, schedule, settings.
class NotificationHelper {
  /// Refresh notifications after calendar changes (Widget context)
  ///
  /// Fire-and-forget operation with error protection.
  /// Reads current streak safely and updates notifications if enabled.
  ///
  /// Usage:
  /// ```dart
  /// unawaited(NotificationHelper.refreshAfterCalendarChange(ref));
  /// ```
  static Future<void> refreshAfterCalendarChange(WidgetRef ref) async {
    await _doRefresh(ref);
  }

  /// Refresh notifications after calendar changes (Provider context)
  ///
  /// Fire-and-forget operation with error protection.
  /// For use within Riverpod providers/controllers.
  ///
  /// Usage:
  /// ```dart
  /// unawaited(NotificationHelper.refreshAfterCalendarChangeFromProvider(ref));
  /// ```
  static Future<void> refreshAfterCalendarChangeFromProvider(Ref ref) async {
    await _doRefresh(ref);
  }

  /// Internal implementation for notification refresh
  static Future<void> _doRefresh(dynamic ref) async {
    try {
      final repository = ref.read(calendarCourseRepositoryProvider);
      final database = ref.read(databaseProvider);
      int currentStreak = 0;
      try {
        currentStreak = await ref.read(currentStreakProvider.future);
      } catch (_) {
        // Streak read failure is non-critical for notifications
      }
      await NotificationService.updateNotificationIfEnabled(
        repository: repository,
        database: database,
        currentStreak: currentStreak,
      );
    } catch (e, st) {
      LogService.e('Erreur reprogrammation notifications', e, st);
    }
  }
}
