// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_supply_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addSupplyControllerHash() =>
    r'875b41488fd06d910e19aeeb2f16db3a85063ec5';

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

abstract class _$AddSupplyController
    extends BuildlessAutoDisposeNotifier<AddSupplyState> {
  late final String courseId;

  AddSupplyState build(
    String courseId,
  );
}

/// See also [AddSupplyController].
@ProviderFor(AddSupplyController)
const addSupplyControllerProvider = AddSupplyControllerFamily();

/// See also [AddSupplyController].
class AddSupplyControllerFamily extends Family<AddSupplyState> {
  /// See also [AddSupplyController].
  const AddSupplyControllerFamily();

  /// See also [AddSupplyController].
  AddSupplyControllerProvider call(
    String courseId,
  ) {
    return AddSupplyControllerProvider(
      courseId,
    );
  }

  @override
  AddSupplyControllerProvider getProviderOverride(
    covariant AddSupplyControllerProvider provider,
  ) {
    return call(
      provider.courseId,
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
  String? get name => r'addSupplyControllerProvider';
}

/// See also [AddSupplyController].
class AddSupplyControllerProvider extends AutoDisposeNotifierProviderImpl<
    AddSupplyController, AddSupplyState> {
  /// See also [AddSupplyController].
  AddSupplyControllerProvider(
    String courseId,
  ) : this._internal(
          () => AddSupplyController()..courseId = courseId,
          from: addSupplyControllerProvider,
          name: r'addSupplyControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addSupplyControllerHash,
          dependencies: AddSupplyControllerFamily._dependencies,
          allTransitiveDependencies:
              AddSupplyControllerFamily._allTransitiveDependencies,
          courseId: courseId,
        );

  AddSupplyControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseId,
  }) : super.internal();

  final String courseId;

  @override
  AddSupplyState runNotifierBuild(
    covariant AddSupplyController notifier,
  ) {
    return notifier.build(
      courseId,
    );
  }

  @override
  Override overrideWith(AddSupplyController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AddSupplyControllerProvider._internal(
        () => create()..courseId = courseId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseId: courseId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AddSupplyController, AddSupplyState>
      createElement() {
    return _AddSupplyControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddSupplyControllerProvider && other.courseId == courseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AddSupplyControllerRef on AutoDisposeNotifierProviderRef<AddSupplyState> {
  /// The parameter `courseId` of this provider.
  String get courseId;
}

class _AddSupplyControllerProviderElement
    extends AutoDisposeNotifierProviderElement<AddSupplyController,
        AddSupplyState> with AddSupplyControllerRef {
  _AddSupplyControllerProviderElement(super.provider);

  @override
  String get courseId => (origin as AddSupplyControllerProvider).courseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
