// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarControllerHash() =>
    r'049d9222f610c30d834ced1e5c0fa834852e2caf';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CalendarController
    extends BuildlessAutoDisposeAsyncNotifier<List<CalendarEvent>> {
  late final DateTime selectedDate;
  late final WeekFilter weekFilter;

  FutureOr<List<CalendarEvent>> build(
    DateTime selectedDate,
    WeekFilter weekFilter,
  );
}

/// See also [CalendarController].
@ProviderFor(CalendarController)
const calendarControllerProvider = CalendarControllerFamily();

/// See also [CalendarController].
class CalendarControllerFamily extends Family<AsyncValue<List<CalendarEvent>>> {
  /// See also [CalendarController].
  const CalendarControllerFamily();

  /// See also [CalendarController].
  CalendarControllerProvider call(
    DateTime selectedDate,
    WeekFilter weekFilter,
  ) {
    return CalendarControllerProvider(
      selectedDate,
      weekFilter,
    );
  }

  @override
  CalendarControllerProvider getProviderOverride(
    covariant CalendarControllerProvider provider,
  ) {
    return call(
      provider.selectedDate,
      provider.weekFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calendarControllerProvider';
}

/// See also [CalendarController].
class CalendarControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CalendarController, List<CalendarEvent>> {
  /// See also [CalendarController].
  CalendarControllerProvider(
    DateTime selectedDate,
    WeekFilter weekFilter,
  ) : this._internal(
          () => CalendarController()
            ..selectedDate = selectedDate
            ..weekFilter = weekFilter,
          from: calendarControllerProvider,
          name: r'calendarControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$calendarControllerHash,
          dependencies: CalendarControllerFamily._dependencies,
          allTransitiveDependencies:
              CalendarControllerFamily._allTransitiveDependencies,
          selectedDate: selectedDate,
          weekFilter: weekFilter,
        );

  CalendarControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedDate,
    required this.weekFilter,
  }) : super.internal();

  final DateTime selectedDate;
  final WeekFilter weekFilter;

  @override
  FutureOr<List<CalendarEvent>> runNotifierBuild(
    covariant CalendarController notifier,
  ) {
    return notifier.build(
      selectedDate,
      weekFilter,
    );
  }

  @override
  Override overrideWith(CalendarController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CalendarControllerProvider._internal(
        () => create()
          ..selectedDate = selectedDate
          ..weekFilter = weekFilter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedDate: selectedDate,
        weekFilter: weekFilter,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CalendarController,
      List<CalendarEvent>> createElement() {
    return _CalendarControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarControllerProvider &&
        other.selectedDate == selectedDate &&
        other.weekFilter == weekFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedDate.hashCode);
    hash = _SystemHash.combine(hash, weekFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<CalendarEvent>> {
  /// The parameter `selectedDate` of this provider.
  DateTime get selectedDate;

  /// The parameter `weekFilter` of this provider.
  WeekFilter get weekFilter;
}

class _CalendarControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CalendarController,
        List<CalendarEvent>> with CalendarControllerRef {
  _CalendarControllerProviderElement(super.provider);

  @override
  DateTime get selectedDate =>
      (origin as CalendarControllerProvider).selectedDate;
  @override
  WeekFilter get weekFilter =>
      (origin as CalendarControllerProvider).weekFilter;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
