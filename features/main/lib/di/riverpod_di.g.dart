// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyCheckRepositoryHash() =>
    r'eb1fb9d28779dc80f2a98c598fed114762f4a533';

/// Provider for the DailyCheckRepository
///
/// Provides access to daily checklist persistence functionality including:
/// - Toggle supply check state (checked/unchecked)
/// - Load daily checks for a specific date
/// - Offline-first architecture with automatic sync
///
/// Copied from [dailyCheckRepository].
@ProviderFor(dailyCheckRepository)
final dailyCheckRepositoryProvider =
    AutoDisposeProvider<DailyCheckRepository>.internal(
  dailyCheckRepository,
  name: r'dailyCheckRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyCheckRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyCheckRepositoryRef = AutoDisposeProviderRef<DailyCheckRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
