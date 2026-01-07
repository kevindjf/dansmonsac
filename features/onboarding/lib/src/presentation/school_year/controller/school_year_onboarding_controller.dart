import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/services.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:onboarding/src/presentation/school_year/controller/school_year_onboarding_state.dart';
import 'package:onboarding/src/presentation/hour/setup_time_page.dart';

part 'school_year_onboarding_controller.g.dart';

@riverpod
class SchoolYearOnboardingController extends _$SchoolYearOnboardingController {
  final _errorStreamController = StreamController<String>.broadcast();

  Stream<String> get errorStream => _errorStreamController.stream;

  @override
  SchoolYearOnboardingState build() {
    return SchoolYearOnboardingState(
      schoolYearStart: SchoolYearOnboardingState.getDefaultSchoolYearStart(),
    );
  }

  void updateDate(DateTime date) {
    state = state.copyWith(schoolYearStart: date);
  }

  Future<void> store() async {
    state = state.copyWith(isLoading: true);

    try {
      // Save school year start date to preferences
      await PreferencesService.setSchoolYearStart(state.schoolYearStart);

      // Navigate to next onboarding step
      ref.read(routerDelegateProvider).setRoute(OnboardingSetupTimePage.routeName);
    } catch (e) {
      _errorStreamController.add("Erreur lors de l'enregistrement: ${e.toString()}");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> skip() async {
    // Save default date (first Monday of September)
    await PreferencesService.setSchoolYearStart(state.schoolYearStart);

    // Navigate to next step
    ref.read(routerDelegateProvider).setRoute(OnboardingSetupTimePage.routeName);
  }

  @override
  void dispose() {
    _errorStreamController.close();
    super.dispose();
  }
}
