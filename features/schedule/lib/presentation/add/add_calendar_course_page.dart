import 'dart:async';

import 'package:course/models/cours_with_supplies.dart';
import 'package:course/presentation/add/add_course_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:schedule/presentation/add/controller/add_calendar_course_controller.dart';

class AddCalendarCoursePage extends ConsumerStatefulWidget {
  final ValueChanged<CalendarCourse?> onAddCalendarCourse;

  const AddCalendarCoursePage({Key? key, required this.onAddCalendarCourse})
      : super(key: key);

  @override
  ConsumerState<AddCalendarCoursePage> createState() =>
      _AddCalendarCoursePageState();
}

class _AddCalendarCoursePageState extends ConsumerState<AddCalendarCoursePage> {
  final TextEditingController _roomController = TextEditingController();
  StreamSubscription? _errorSubscription;
  StreamSubscription? _successSubscription;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
      hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  @override
  void initState() {
    super.initState();

    _roomController.addListener(() => ref
        .read(addCalendarCourseControllerProvider.notifier)
        .roomNameChanged(_roomController.text));

    _errorSubscription = ref
        .read(addCalendarCourseControllerProvider.notifier)
        .errorStream
        .listen((errorMessage) {
      if (mounted) {
        print("error");
        // ShowErrorMessage.show(context, errorMessage);
      }
    });

    _successSubscription = ref
        .read(addCalendarCourseControllerProvider.notifier)
        .successStream
        .listen((calendarCourse) {
      if (mounted) {
        widget.onAddCalendarCourse(calendarCourse);
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    super.dispose();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Si l'heure de fin est avant l'heure de début, ajuster l'heure de fin
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour &&
                _endTime.minute < _startTime.minute)) {
          _endTime = TimeOfDay(
              hour: _startTime.hour + 1, minute: _startTime.minute);
        }
      });
      ref
          .read(addCalendarCourseControllerProvider.notifier)
          .startTimeChanged(_startTime);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
      ref
          .read(addCalendarCourseControllerProvider.notifier)
          .endTimeChanged(_endTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var state = ref.watch(addCalendarCourseControllerProvider);

    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ajouter au calendrier",
              style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Liste déroulante des cours
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                labelText: "Cours",
                labelStyle: const TextStyle(color: Colors.grey),
              ),
              value: state.courseId,
              items: state.courses.when(
                data: (data) => data.map((course) {
                  return DropdownMenuItem<String>(
                    value: course.id,
                    child: Text(course.name),
                  );
                }).toList(),
                loading: () => [],
                error: (_, __) => [],
              ),
              onChanged: (String? courseId) {
                if (courseId != null) {
                  ref
                      .read(addCalendarCourseControllerProvider.notifier)
                      .courseChanged(courseId);
                }
              },
            ),
            state.errorCourseId == null
                ? const SizedBox(height: 16)
                : Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${state.errorCourseId}",
                        style: TextStyle(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

            // Champ pour la salle
            _buildTextField(
              controller: _roomController,
              labelText: "Salle",
              hintText: "Exemple : A102",
              context: context,
            ),
            state.errorRoomName == null
                ? const SizedBox(height: 16)
                : Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${state.errorRoomName}",
                        style: TextStyle(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

            // Heure de début
            InkWell(
              onTap: () => _selectStartTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  labelText: "Heure de début",
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}",
                    ),
                    Icon(Icons.access_time, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
            state.errorStartTime == null
                ? const SizedBox(height: 16)
                : Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${state.errorStartTime}",
                        style: TextStyle(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

            // Heure de fin
            InkWell(
              onTap: () => _selectEndTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  labelText: "Heure de fin",
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}",
                    ),
                    Icon(Icons.access_time, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
            state.errorEndTime == null
                ? const SizedBox(height: 32)
                : Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${state.errorEndTime}",
                        style: TextStyle(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),

            // Boutons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref
                          .read(addCalendarCourseControllerProvider.notifier)
                          .store();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Bouton Annuler
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String labelText,
        String? hintText,
        Function(String)? onSubmitted,
        BuildContext? context}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context!).colorScheme.primary),
        ),
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      onSubmitted: onSubmitted,
    );
  }
}