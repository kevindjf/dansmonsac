import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:main/presentation/home/controller/home_state_ui.dart';
import 'package:onboarding/src/di/riverpod_di.dart';
import 'package:onboarding/src/models/command/pack_time_command.dart';
import 'package:onboarding/src/presentation/course/controller/course_onboarding_state.dart';
import 'package:onboarding/src/presentation/course/course_page.dart';
import 'package:onboarding/src/presentation/hour/controller/setup_time_onboarding_state.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {

  @override
  HomeStateUi build() {
    return HomeStateUi(0,HomeViewPage.supplies);
  }

  changePage(int index,HomeViewPage page){
    state = HomeStateUi(index,page);
  }
}
