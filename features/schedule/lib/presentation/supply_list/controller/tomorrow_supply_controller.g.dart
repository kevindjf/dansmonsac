// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tomorrow_supply_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tomorrowSupplyControllerHash() =>
    r'9b8f7e8c90eeb035ae69d73f3df918a54dba25dc';

/// Controller for tomorrow's supplies
/// Refactored to use getTomorrowCourses() repository method (Story 2.8)
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
