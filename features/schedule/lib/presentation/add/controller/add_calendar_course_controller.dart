import 'dart:async';

import 'package:course/di/riverpod_di.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repository/calendar_course_repository.dart';
import '../../../di/riverpod_di.dart';
import '../../calendar/controller/calendar_controller.dart';
import '../../supply_list/controller/tomorrow_supply_controller.dart';
import 'add_calendar_couse_state.dart';

part 'add_calendar_course_controller.g.dart';

// Provider pour la liste des cours existants
final coursesProvider = FutureProvider<List<CourseWithSupplies>>((ref) async {
  var response = await ref.read(courseRepositoryProvider).fetchCourses();
  return response.fold(
    (failure) => [],
    (courses) => courses,
  );
});

// État pour le contrôleur


@riverpod
class AddCalendarCourseController extends _$AddCalendarCourseController {

  final _errorStreamController = StreamController<String>.broadcast();
  final _successStreamController = StreamController<CalendarCourse>.broadcast();

  Stream<String> get errorStream => _errorStreamController.stream;
  Stream<CalendarCourse> get successStream => _successStreamController.stream;

  @override
  Future<AddCalendarCourseState> build() async{

    var response = await ref.read(courseRepositoryProvider).fetchCourses();
    List<CourseWithSupplies> courses = [];

    response.fold((failure) {
      _errorStreamController.add(failure.message);
      courses = [];
    }, (coursesRemote) {
      courses = coursesRemote;
    });

    return AddCalendarCourseState(
      courses: courses,
      startTime: TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
      endTime: TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0),
    );
  }



  void courseChanged(String courseId) {
    state = AsyncValue.data(state.value!.copyWith(
      courseId: courseId,
      errorCourseId: null,
    ));
  }

  void roomNameChanged(String roomName) {
    state = AsyncValue.data(state.value!.copyWith(
      roomName: roomName,
      errorRoomName: null,
    ));
  }

  void startTimeChanged(TimeOfDay startTime) {
    state = AsyncValue.data(state.value!.copyWith(
      startTime: startTime,
      errorStartTime: null,
    ));
  }

  void endTimeChanged(TimeOfDay endTime) {
    state = AsyncValue.data(state.value!.copyWith(
      endTime: endTime,
      errorEndTime: null,
    ));
  }

  void weekTypeChanged(WeekType weekType) {
    state = AsyncValue.data(state.value!.copyWith(
      weekType: weekType,
    ));
  }

  void dayOfWeekChanged(int dayOfWeek) {
    state = AsyncValue.data(state.value!.copyWith(
      dayOfWeek: dayOfWeek,
    ));
  }

  bool _validateInputs() {
    bool isValid = true;
    final currentState = state.value!;

    // Validation du cours
    if (currentState.courseId == null || currentState.courseId!.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(errorCourseId: "Veuillez sélectionner un cours"));
      isValid = false;
    }

    // Validation de la salle
    if (currentState.roomName.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(errorRoomName: "La salle est obligatoire"));
      isValid = false;
    }

    // Validation de l'heure de fin (doit être après l'heure de début)
    final startMinutes = currentState.startTime.hour * 60 + currentState.startTime.minute;
    final endMinutes = currentState.endTime.hour * 60 + currentState.endTime.minute;

    if (endMinutes <= startMinutes) {
      state = AsyncValue.data(currentState.copyWith(
          errorEndTime: "L'heure de fin doit être après l'heure de début"));
      isValid = false;
    }

    return isValid;
  }

  Future<void> store() async {
    if (!_validateInputs()) {
      return;
    }

    final currentState = state.value!;
    final calendarCourse = CalendarCourse(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporaire
      courseId: currentState.courseId!,
      roomName: currentState.roomName,
      startTime: currentState.startTime,
      endTime: currentState.endTime,
      weekType: currentState.weekType,
      dayOfWeek: currentState.dayOfWeek,
    );

    final repository = ref.read(calendarCourseRepositoryProvider);
    final result = await repository.addCalendarCourse(calendarCourse);

    result.fold(
      (failure) => _errorStreamController.add("Erreur lors de l'enregistrement: ${failure.message}"),
      (savedCalendarCourse) {
        _successStreamController.add(savedCalendarCourse);
        // Refresh calendar and supply list
        ref.invalidate(calendarControllerProvider);
        ref.invalidate(tomorrowSupplyControllerProvider);
        ref.invalidate(coursesProvider); // Refresh courses to ensure course names are up to date
      },
    );
  }
}