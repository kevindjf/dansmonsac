// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$importControllerHash() => r'6c4b4323f15a5c758cbf487698280592fdffac28';

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

abstract class _$ImportController
    extends BuildlessAutoDisposeNotifier<ImportState> {
  late final String code;

  ImportState build(
    String code,
  );
}

/// See also [ImportController].
@ProviderFor(ImportController)
const importControllerProvider = ImportControllerFamily();

/// See also [ImportController].
class ImportControllerFamily extends Family<ImportState> {
  /// See also [ImportController].
  const ImportControllerFamily();

  /// See also [ImportController].
  ImportControllerProvider call(
    String code,
  ) {
    return ImportControllerProvider(
      code,
    );
  }

  @override
  ImportControllerProvider getProviderOverride(
    covariant ImportControllerProvider provider,
  ) {
    return call(
      provider.code,
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
  String? get name => r'importControllerProvider';
}

/// See also [ImportController].
class ImportControllerProvider
    extends AutoDisposeNotifierProviderImpl<ImportController, ImportState> {
  /// See also [ImportController].
  ImportControllerProvider(
    String code,
  ) : this._internal(
          () => ImportController()..code = code,
          from: importControllerProvider,
          name: r'importControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$importControllerHash,
          dependencies: ImportControllerFamily._dependencies,
          allTransitiveDependencies:
              ImportControllerFamily._allTransitiveDependencies,
          code: code,
        );

  ImportControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.code,
  }) : super.internal();

  final String code;

  @override
  ImportState runNotifierBuild(
    covariant ImportController notifier,
  ) {
    return notifier.build(
      code,
    );
  }

  @override
  Override overrideWith(ImportController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImportControllerProvider._internal(
        () => create()..code = code,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        code: code,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ImportController, ImportState>
      createElement() {
    return _ImportControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImportControllerProvider && other.code == code;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, code.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImportControllerRef on AutoDisposeNotifierProviderRef<ImportState> {
  /// The parameter `code` of this provider.
  String get code;
}

class _ImportControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ImportController, ImportState>
    with ImportControllerRef {
  _ImportControllerProviderElement(super.provider);

  @override
  String get code => (origin as ImportControllerProvider).code;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
