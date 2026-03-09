// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarCourseRepositoryHash() =>
    r'b8f881d341fedaf3a7db8ca8cd48212928ef8c33';

/// See also [calendarCourseRepository].
@ProviderFor(calendarCourseRepository)
final calendarCourseRepositoryProvider =
    AutoDisposeProvider<CalendarCourseRepository>.internal(
  calendarCourseRepository,
  name: r'calendarCourseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarCourseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarCourseRepositoryRef
    = AutoDisposeProviderRef<CalendarCourseRepository>;
String _$tomorrowCoursesHash() => r'3662b380d8b84993bc631675d7852d518dcb708f';

/// Provider for tomorrow's courses with supplies
/// Returns list of courses scheduled for tomorrow, grouped by course with supplies
/// Returns empty list if tomorrow is a weekend or has no classes
///
/// Copied from [tomorrowCourses].
@ProviderFor(tomorrowCourses)
final tomorrowCoursesProvider =
    AutoDisposeFutureProvider<List<CalendarCourseWithSupplies>>.internal(
  tomorrowCourses,
  name: r'tomorrowCoursesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tomorrowCoursesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TomorrowCoursesRef
    = AutoDisposeFutureProviderRef<List<CalendarCourseWithSupplies>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
