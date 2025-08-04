import 'dart:async';

import 'package:course/di/riverpod_di.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repository/calendar_course_repository.dart';
import 'add_calendar_couse_state.dart';

part 'add_calendar_course_controller.g.dart';

// Provider pour la liste des cours existants (à adapter selon votre architecture)
final coursesProvider = FutureProvider<List<CourseWithSupplies>>((ref) async {
  // Récupérer la liste des cours depuis votre repository
  var response = await ref.read(courseRepositoryProvider).fetchCourses();
  return [];
});

// État pour le contrôleur


@riverpod
class AddCalendarCourseController extends _$AddCalendarCourseController {

  late CalendarCourseRepository _calendarCourseRepository;
  final _errorStreamController = StreamController<String>.broadcast();
  final _successStreamController = StreamController<CalendarCourse>.broadcast();

  Stream<String> get errorStream => _errorStreamController.stream;
  Stream<CalendarCourse> get successStream => _successStreamController.stream;

  @override
  Future<AddCalendarCourseState> build() async{

    var response = await ref.read(courseRepositoryProvider).fetchCourses();
    List<CourseWithSupplies> courses = [];

    response.fold((failure) {
     //TODO Manage error

      }, (coursesRemote) {
       courses = coursesRemote;
    });

    return AddCalendarCourseState(
      courses: courses,
      startTime: TimeOfDay.now(),
      endTime: TimeOfDay(
          hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute),
    );
  }



  void courseChanged(String courseId) {
   /* state = state.value.copyWith(
      courseId: courseId,
      errorCourseId: null,
    );*/
  }

  void roomNameChanged(String roomName) {
   /* state = state.value?.copyWith(
      roomName: roomName,
      errorRoomName: null,
    );*/
  }

  void startTimeChanged(TimeOfDay startTime) {
   /* state = state.copyWith(
      startTime: startTime,
      errorStartTime: null,
    );*/
  }

  void endTimeChanged(TimeOfDay endTime) {
  /*  state = state.copyWith(
      endTime: endTime,
      errorEndTime: null,
    );*/
  }

  bool _validateInputs() {
    bool isValid = true;

    // Validation du cours
    /*if (state.courseId == null || state.courseId!.isEmpty) {
      state = state.copyWith(errorCourseId: "Veuillez sélectionner un cours");
      isValid = false;
    }

    // Validation de la salle
    if (state.roomName.isEmpty) {
      state = state.copyWith(errorRoomName: "La salle est obligatoire");
      isValid = false;
    }

    // Validation de l'heure de fin (doit être après l'heure de début)
    final startMinutes = state.startTime.hour * 60 + state.startTime.minute;
    final endMinutes = state.endTime.hour * 60 + state.endTime.minute;

    if (endMinutes <= startMinutes) {
      state = state.copyWith(
          errorEndTime: "L'heure de fin doit être après l'heure de début");
      isValid = false;
    }*/

    return isValid;
  }

  Future<void> store() async {
   /* if (!_validateInputs()) {
      return;
    }

    try {
      final calendarCourse = CalendarCourse(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporaire
        courseId: state.courseId!,
        roomName: state.roomName,
        startTime: state.startTime,
        endTime: state.endTime,
      );

      //final savedCalendarCourse =
      //await _calendarCourseRepository.addCalendarCourse(calendarCourse);
     // _successStreamController.add(savedCalendarCourse);
    } catch (e) {
      _errorStreamController.add("Erreur lors de l'enregistrement: ${e.toString()}");
    }

    */
  }
}