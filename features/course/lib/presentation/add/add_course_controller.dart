import 'dart:async';
import 'package:course/di/riverpod_di.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/models/suggested_supply.dart';
import 'package:course/presentation/add/add_course_state.dart';
import 'package:course/repository/course_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:common/src/services.dart';
import 'package:common/src/utils.dart';
import 'package:schedule/presentation/add/controller/add_calendar_course_controller.dart';

part 'add_course_controller.g.dart';

@riverpod
class AddCourseController extends _$AddCourseController {
  late CourseRepository courseRepository;

  final _errorController = StreamController<String>.broadcast();
  final _successController = StreamController<CourseWithSupplies>.broadcast();

  Stream<String> get errorStream => _errorController.stream;

  Stream<CourseWithSupplies> get successStream => _successController.stream;

  @override
  AddCourseState build() {
    courseRepository = ref.watch(courseRepositoryProvider);
    return AddCourseState.initial();
  }

  courseNameChanged(String text) {
    state = state.copyWith(courseName: text);
  }

  /// Update course name and load supply suggestions based on the subject name
  void onCourseNameChanged(String courseName) {
    LogService.d('onCourseNameChanged: $courseName');

    // Update course name
    state = state.copyWith(courseName: courseName);

    // Load supply suggestions
    final supplies = DefaultSupplies.getSuppliesBySubjectName(courseName);

    if (supplies != null && supplies.isNotEmpty) {
      // Convert to SuggestedSupply list with default checked state
      final suggestions = supplies
          .map((name) => SuggestedSupply(
                name: name,
                isChecked: true,
                isModified: false,
              ))
          .toList();

      state = state.copyWith(suggestedSupplies: suggestions);
      LogService.d('Loaded ${suggestions.length} suggestions for $courseName');
    } else {
      // No suggestions found - clear the list
      state = state.copyWith(suggestedSupplies: []);
      LogService.d('No suggestions found for $courseName');
    }
  }

  /// Toggle a suggested supply's checked state
  void toggleSupplySuggestion(int index, bool isChecked) {
    LogService.d('🔘 toggleSupplySuggestion: index=$index, isChecked=$isChecked');

    if (index < 0 || index >= state.suggestedSupplies.length) {
      LogService.w('Invalid index for toggleSupplySuggestion: $index');
      return;
    }

    final oldSupply = state.suggestedSupplies[index];
    LogService.d('  Before: ${oldSupply.name} - checked: ${oldSupply.isChecked}');

    final updatedSupplies = List<SuggestedSupply>.from(state.suggestedSupplies);
    updatedSupplies[index] = updatedSupplies[index].copyWith(isChecked: isChecked);

    LogService.d('  After: ${updatedSupplies[index].name} - checked: ${updatedSupplies[index].isChecked}');

    state = state.copyWith(suggestedSupplies: updatedSupplies);

    LogService.d('  State updated - total suggestions: ${state.suggestedSupplies.length}');
  }

  /// Update a suggested supply's text and mark as modified
  void updateSuggestionText(int index, String newText) {
    LogService.d('updateSuggestionText: index=$index, newText=$newText');

    if (index < 0 || index >= state.suggestedSupplies.length) {
      LogService.w('Invalid index for updateSuggestionText: $index');
      return;
    }

    final updatedSupplies = List<SuggestedSupply>.from(state.suggestedSupplies);
    updatedSupplies[index] = updatedSupplies[index].copyWith(
      name: newText,
      isModified: true,
    );

    state = state.copyWith(suggestedSupplies: updatedSupplies);
  }

  store() async {
    final validationError = Validators.validateCourseName(state.courseName);
    if (validationError != null) {
      state = state.copyWith(errorCourseName: validationError);
      return;
    }

    final cleanName = Validators.clean(state.courseName);

    // DEBUG: Log current state
    LogService.d('=== STORE DEBUG ===');
    LogService.d('Course name: $cleanName');
    LogService.d('Total suggestions in state: ${state.suggestedSupplies.length}');
    for (var i = 0; i < state.suggestedSupplies.length; i++) {
      final s = state.suggestedSupplies[i];
      LogService.d('  [$i] ${s.name} - checked: ${s.isChecked}, modified: ${s.isModified}');
    }

    // Collect checked suggested supplies
    final checkedSupplies = state.suggestedSupplies
        .where((supply) => supply.isChecked)
        .map((supply) => supply.name)
        .toList();

    LogService.d('Checked supplies to store: ${checkedSupplies.length}');
    for (var supply in checkedSupplies) {
      LogService.d('  - $supply');
    }

    // Validate all supply names
    for (final supplyName in checkedSupplies) {
      final supplyError = Validators.validateSupplyName(supplyName);
      if (supplyError != null) {
        LogService.e('Supply validation failed for: $supplyName - $supplyError');
        _errorController.add('Fourniture invalide: $supplyError');
        return;
      }
    }

    LogService.d('Calling repository.store() with ${checkedSupplies.length} supplies');
    var response = await courseRepository
        .store(AddCourseCommand(cleanName, checkedSupplies));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      LogService.e('Store failed: $failure');
      _errorController.add(ErrorMessages.getMessageForFailure(failure));
    }, (course) {
      LogService.i('✅ Course created successfully!');
      LogService.i('  Course ID: ${course.id}');
      LogService.i('  Course name: ${course.name}');
      LogService.i('  Supplies returned: ${course.supplies.length}');
      _successController.add(course);
      // Invalidate courses provider to refresh course list everywhere
      ref.invalidate(coursesProvider);
    });
  }

  skip() {
    ref.watch(routerDelegateProvider).goToHome();
  }
}
