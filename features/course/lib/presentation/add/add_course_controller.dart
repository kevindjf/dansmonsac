import 'dart:async';
import 'package:course/di/riverpod_di.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/presentation/add/add_course_state.dart';
import 'package:course/repository/course_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
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

  store() async {
    final validationError = Validators.validateCourseName(state.courseName);
    if (validationError != null) {
      state = state.copyWith(errorCourseName: validationError);
      return;
    }

    final cleanName = Validators.clean(state.courseName);
    var response = await courseRepository
        .store(AddCourseCommand(cleanName, []));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      _errorController.add(ErrorMessages.getMessageForFailure(failure));
    }, (course) {
      _successController.add(course);
      // Invalidate courses provider to refresh course list everywhere
      ref.invalidate(coursesProvider);
    });
  }

  skip() {
    ref.watch(routerDelegateProvider).goToHome();
  }
}
