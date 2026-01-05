import 'dart:async';

import 'package:common/src/di/riverpod_di.dart';
import 'package:onboarding/src/di/riverpod_di.dart';
import 'package:onboarding/src/presentation/course/controller/course_onboarding_state.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_onboarding_controller.g.dart';

@riverpod
class CourseOnboardingController extends _$CourseOnboardingController {
  late OnboardingRepository onboardingRepository;

  final _errorController = StreamController<String>.broadcast();

  Stream<String> get errorStream => _errorController.stream;

  @override
  CourseOnboardingState build() {
    onboardingRepository = ref.watch(onboardingRepositoryProvider);
    return CourseOnboardingState.initial();
  }

  courseNameChanged(String text) {
    state = state.copyWith(courseName: text);
  }

  addSupply(String text) {
    state = state.copyWith(supplies: [...state.supplies, text]);
  }

  removeSupply(int index) {
    state = state.copyWith(supplies: [...state.supplies]..removeAt(index));
  }

  store() async {
    if (state.courseName.trim().isEmpty) {
      state = state.copyWith(
          errorCourseName: "Le nom du cours ne peut pas être vide");
      return;
    }

    var response = await onboardingRepository.storeCourse(
        state.courseName, state.supplies);

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      print(failure);
      _errorController
          .add("Une erreur est survenue, veuillez réessayer ultérieurement !");
    }, (_) => ref.watch(routerDelegateProvider).goToHome());
  }

  skip() {
    ref.watch(routerDelegateProvider).goToHome();
  }
}
