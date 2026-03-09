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
// ignore: depend_on_referenced_packages
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
    LogService.d(
        'toggleSupplySuggestion: index=$index, isChecked=$isChecked');

    if (index < 0 || index >= state.suggestedSupplies.length) {
      LogService.w('Invalid index for toggleSupplySuggestion: $index');
      return;
    }

    final updatedSupplies = List<SuggestedSupply>.from(state.suggestedSupplies);
    updatedSupplies[index] = SuggestedSupply(
      name: updatedSupplies[index].name,
      isChecked: isChecked,
      isModified: updatedSupplies[index].isModified,
    );
    state = state.copyWith(suggestedSupplies: updatedSupplies);
  }

  Future<void> store() async {
    final name = Validators.clean(state.courseName);
    final error = Validators.validateCourseName(name);
    if (error != null) {
      state = state.copyWith(errorCourseName: error);
      return;
    }

    state = state.copyWith(isLoading: true);

    // Get checked suggested supplies as supply names
    final supplyNames = state.suggestedSupplies
        .where((s) => s.isChecked)
        .map((s) => s.name)
        .toList();

    var response = await courseRepository.store(AddCourseCommand(name, supplyNames));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      LogService.e('Store failed: $failure');
      _errorController.add(ErrorMessages.getMessageForFailure(failure));
    }, (course) {
      LogService.i('Course created successfully: ${course.name}');
      _successController.add(course);
      ref.invalidate(coursesProvider);
    });
  }

  void updateSuggestionText(int index, String text) {
    if (index < 0 || index >= state.suggestedSupplies.length) return;

    final updatedSupplies = List<SuggestedSupply>.from(state.suggestedSupplies);
    updatedSupplies[index] = SuggestedSupply(
      name: text,
      isChecked: updatedSupplies[index].isChecked,
      isModified: true,
    );
    state = state.copyWith(suggestedSupplies: updatedSupplies);
  }

  skip() {
    ref.watch(routerDelegateProvider).goToHome();
  }
}
