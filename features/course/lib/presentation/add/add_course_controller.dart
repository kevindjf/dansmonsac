import 'dart:async';
import 'dart:ffi';
import 'package:course/di/riverpod_di.dart';
import 'package:course/models/add_course_command.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/presentation/add/add_course_state.dart';
import 'package:course/repository/course_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
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
    if (state.courseName.trim().isEmpty) {
      state = state.copyWith(
          errorCourseName: "Le nom du cours ne peut pas être vide");
      return;
    }

    var response = await courseRepository
        .store(AddCourseCommand(state.courseName, []));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      _errorController
          .add("Une erreur est survenue, veuillez réessayer ultérieurement !");
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
