// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarControllerHash() =>
    r'04cd71cfd3acc0a8ec453318794ba7a606ab7fda';

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

  FutureOr<List<CalendarEvent>> build(
    DateTime selectedDate,
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
  ) {
    return CalendarControllerProvider(
      selectedDate,
    );
  }

  @override
  CalendarControllerProvider getProviderOverride(
    covariant CalendarControllerProvider provider,
  ) {
    return call(
      provider.selectedDate,
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
  ) : this._internal(
          () => CalendarController()..selectedDate = selectedDate,
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
        );

  CalendarControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedDate,
  }) : super.internal();

  final DateTime selectedDate;

  @override
  FutureOr<List<CalendarEvent>> runNotifierBuild(
    covariant CalendarController notifier,
  ) {
    return notifier.build(
      selectedDate,
    );
  }

  @override
  Override overrideWith(CalendarController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CalendarControllerProvider._internal(
        () => create()..selectedDate = selectedDate,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedDate: selectedDate,
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
        other.selectedDate == selectedDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<CalendarEvent>> {
  /// The parameter `selectedDate` of this provider.
  DateTime get selectedDate;
}

class _CalendarControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CalendarController,
        List<CalendarEvent>> with CalendarControllerRef {
  _CalendarControllerProviderElement(super.provider);

  @override
  DateTime get selectedDate =>
      (origin as CalendarControllerProvider).selectedDate;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
