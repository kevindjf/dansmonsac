// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_check_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyCheckControllerHash() =>
    r'91ce5fa857256188a699771f5f332c17bb9c8a41';

/// Controller for managing daily supply check state
///
/// Responsibilities:
/// - Load checks for a specific date
/// - Toggle check state (checked/unchecked)
/// - Provide reactive state updates to UI
///
/// Copied from [DailyCheckController].
@ProviderFor(DailyCheckController)
final dailyCheckControllerProvider = AutoDisposeAsyncNotifierProvider<
    DailyCheckController, Map<String, bool>>.internal(
  DailyCheckController.new,
  name: r'dailyCheckControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyCheckControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DailyCheckController = AutoDisposeAsyncNotifier<Map<String, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
