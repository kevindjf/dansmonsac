import 'package:flutter/material.dart';

class SetupTimeOnboardingState {
  final TimeOfDay setupTime;
  final bool isLoading;

  SetupTimeOnboardingState(this.setupTime, this.isLoading);

  SetupTimeOnboardingState copyWith({TimeOfDay? setupTime, bool? isLoading}) {
    return SetupTimeOnboardingState(setupTime ?? this.setupTime, isLoading ?? this.isLoading);
  }
}
