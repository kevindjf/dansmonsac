// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tomorrow_supply_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tomorrowSupplyControllerHash() =>
    r'ee76902f369b166017397e6f754a9f3926c9d6dc';

/// Controller for tomorrow's supplies
/// Uses pack time to determine target date:
/// - Before pack time -> show today's courses
/// - After pack time -> show tomorrow's courses
///
/// Copied from [TomorrowSupplyController].
@ProviderFor(TomorrowSupplyController)
final tomorrowSupplyControllerProvider = AutoDisposeAsyncNotifierProvider<
    TomorrowSupplyController, List<CourseWithSuppliesForTomorrow>>.internal(
  TomorrowSupplyController.new,
  name: r'tomorrowSupplyControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tomorrowSupplyControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TomorrowSupplyController
    = AutoDisposeAsyncNotifier<List<CourseWithSuppliesForTomorrow>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
