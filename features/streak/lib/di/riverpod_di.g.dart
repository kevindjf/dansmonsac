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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
