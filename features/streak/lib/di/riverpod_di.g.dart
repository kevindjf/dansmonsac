// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$streakRepositoryHash() => r'54ade0e5c6f67dfd4055db08cbb8153fb93ea038';

/// Provider for the StreakRepository
///
/// Provides access to streak tracking functionality including:
/// - Current streak calculation
/// - Bag completion history
/// - Marking bag as complete
///
/// Copied from [streakRepository].
@ProviderFor(streakRepository)
final streakRepositoryProvider = AutoDisposeProvider<StreakRepository>.internal(
  streakRepository,
  name: r'streakRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$streakRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StreakRepositoryRef = AutoDisposeProviderRef<StreakRepository>;
String _$currentStreakHash() => r'b714dbf5198395424171cbe5921ee8a493e8c0b5';

/// Provider for the current streak count
///
/// Returns the current streak as an AsyncValue<int>.
/// The streak represents consecutive school days with bag preparation completed.
///
/// Usage:
/// ```dart
/// final streakAsync = ref.watch(currentStreakProvider);
/// streakAsync.when(
///   data: (count) => Text('Streak: \$count days'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: \$err'),
/// );
/// ```
///
/// Copied from [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = AutoDisposeFutureProvider<int>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStreakRef = AutoDisposeFutureProviderRef<int>;
String _$previousStreakHash() => r'61866932ad1dc5c5d3e13077e22b336557d11a8f';

/// Provider for the previous streak count (before last break)
///
/// Returns the previous streak value stored in preferences.
/// Returns 0 if no previous streak exists.
///
/// Copied from [previousStreak].
@ProviderFor(previousStreak)
final previousStreakProvider = AutoDisposeFutureProvider<int>.internal(
  previousStreak,
  name: r'previousStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$previousStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreviousStreakRef = AutoDisposeFutureProviderRef<int>;
String _$bestStreakHash() => r'91ff35241d901c32df2c8ce5f3cf985f16fb81e9';

/// Provider for the best streak ever achieved
///
/// Returns the highest streak value the user has ever reached.
/// Returns 0 if no best streak exists.
///
/// Copied from [bestStreak].
@ProviderFor(bestStreak)
final bestStreakProvider = AutoDisposeFutureProvider<int>.internal(
  bestStreak,
  name: r'bestStreakProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bestStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BestStreakRef = AutoDisposeFutureProviderRef<int>;
String _$brokenStreakHash() => r'767221b03059bd07d76cac1ed5d5944dcfb8a817';

/// Provider for detecting broken streaks
///
/// Returns true if the streak was broken since last check.
/// This provider checks for missed school days without bag completion.
///
/// Copied from [brokenStreak].
@ProviderFor(brokenStreak)
final brokenStreakProvider = AutoDisposeFutureProvider<bool>.internal(
  brokenStreak,
  name: r'brokenStreakProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$brokenStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BrokenStreakRef = AutoDisposeFutureProviderRef<bool>;
String _$weeklyStreakDataHash() => r'd37625566e5e4dd165ee1c73bdb0374a78d39988';

/// Provider for weekly streak data
///
/// Returns a list of 7 WeekDayStatus entries representing the current week
/// (Monday to Sunday). Each status indicates:
/// - completed: Day with bag completion (green checkmark)
/// - missed: School day without completion (empty circle)
/// - inactive: Non-school day like weekend/holiday (greyed out)
/// - future: Day that hasn't happened yet (empty circle)
///
/// This provider is used by the WeeklyStreakRow widget to display
/// the visual weekly progress.
///
/// Usage:
/// ```dart
/// final weeklyDataAsync = ref.watch(weeklyStreakDataProvider);
/// weeklyDataAsync.when(
///   data: (statuses) => WeeklyStreakRow(statuses: statuses),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: \$err'),
/// );
/// ```
///
/// Copied from [weeklyStreakData].
@ProviderFor(weeklyStreakData)
final weeklyStreakDataProvider =
    AutoDisposeFutureProvider<List<WeekDayStatus>>.internal(
  weeklyStreakData,
  name: r'weeklyStreakDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyStreakDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyStreakDataRef = AutoDisposeFutureProviderRef<List<WeekDayStatus>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
