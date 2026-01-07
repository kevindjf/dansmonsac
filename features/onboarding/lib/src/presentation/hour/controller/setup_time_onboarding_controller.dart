import 'dart:async';

import 'package:common/src/di/riverpod_di.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/src/di/riverpod_di.dart';
import 'package:onboarding/src/models/command/pack_time_command.dart';
import 'package:onboarding/src/presentation/notifications/notification_permission_page.dart';
import 'package:onboarding/src/presentation/hour/controller/setup_time_onboarding_state.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_time_onboarding_controller.g.dart';

@riverpod
class SetupTimeOnboardingController extends _$SetupTimeOnboardingController {
  late OnboardingRepository onboardingRepository;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  @override
  SetupTimeOnboardingState build() {
    onboardingRepository = ref.watch(onboardingRepositoryProvider);
    return SetupTimeOnboardingState(
        TimeOfDay(
          hour: 19,
          minute: 00,
        ),
        false);
  }

  updateTime(TimeOfDay setupTime) {
    state = state.copyWith(setupTime: setupTime);
  }

  store() async {
    state = state.copyWith(isLoading: true);

    var setupTime = state.setupTime;
    var response = await onboardingRepository
        .storePackTime(PackTimeCommand(setupTime.hour, setupTime.minute));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);

      print(failure);
      _errorController
          .add("Une erreur est survenue, veuillez réessayer ultérieurement !");
    }, (_) => ref.read(routerDelegateProvider))?.setRoute(
        OnboardingNotificationPermissionPage.routeName);
  }
}
