import 'dart:async';

import 'package:common/src/ui/ui.dart';
import 'package:common/src/utils/week_utils.dart';
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
  final DateTime selectedDate;

  const AddCalendarCoursePage({
    Key? key,
    required this.onAddCalendarCourse,
    required this.selectedDate,
  }) : super(key: key);

  @override
  ConsumerState<AddCalendarCoursePage> createState() =>
      _AddCalendarCoursePageState();
}

class _AddCalendarCoursePageState extends ConsumerState<AddCalendarCoursePage> {
  final TextEditingController _roomController = TextEditingController();
  StreamSubscription? _errorSubscription;
  StreamSubscription? _successSubscription;
  TimeOfDay _startTime = TimeOfDay(hour: TimeOfDay.now().hour, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

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
        ShowErrorMessage.show(context, errorMessage);
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

    // Set the day of week to the selected date's weekday
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(addCalendarCourseControllerProvider.notifier)
          .dayOfWeekChanged(widget.selectedDate.weekday);
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
        // Si l'heure de fin est avant ou égale à l'heure de début, ajuster l'heure de fin
        final startMinutes = _startTime.hour * 60 + _startTime.minute;
        final endMinutes = _endTime.hour * 60 + _endTime.minute;

        if (endMinutes <= startMinutes) {
          _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24, minute: 0);
        }
      });
      ref
          .read(addCalendarCourseControllerProvider.notifier)
          .startTimeChanged(_startTime);
      // Update end time in controller if it was adjusted
      ref
          .read(addCalendarCourseControllerProvider.notifier)
          .endTimeChanged(_endTime);
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
    var asyncState = ref.watch(addCalendarCourseControllerProvider);

    return asyncState.when(
      data: (state) => PopScope(
      canPop: true,
      child: Container(
      width: double.infinity,
      child: SingleChildScrollView(
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
              items: state.courses.map((course) {
                return DropdownMenuItem<String>(
                  value: course.id,
                  child: Text(course.name),
                );
              }).toList(),
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

            // Jour de la semaine
            DropdownButtonFormField<int>(
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
                labelText: "Jour de la semaine",
                labelStyle: const TextStyle(color: Colors.grey),
              ),
              value: state.dayOfWeek,
              items: [
                DropdownMenuItem(value: 1, child: Text('Lundi')),
                DropdownMenuItem(value: 2, child: Text('Mardi')),
                DropdownMenuItem(value: 3, child: Text('Mercredi')),
                DropdownMenuItem(value: 4, child: Text('Jeudi')),
                DropdownMenuItem(value: 5, child: Text('Vendredi')),
                DropdownMenuItem(value: 6, child: Text('Samedi')),
                DropdownMenuItem(value: 7, child: Text('Dimanche')),
              ],
              onChanged: (int? value) {
                if (value != null) {
                  ref
                      .read(addCalendarCourseControllerProvider.notifier)
                      .dayOfWeekChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Type de semaine (A, B, ou les deux)
            DropdownButtonFormField<WeekType>(
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
                labelText: "Semaine",
                labelStyle: const TextStyle(color: Colors.grey),
              ),
              value: state.weekType,
              items: [
                DropdownMenuItem(
                  value: WeekType.A,
                  child: Text('Semaine A uniquement'),
                ),
                DropdownMenuItem(
                  value: WeekType.B,
                  child: Text('Semaine B uniquement'),
                ),
                DropdownMenuItem(
                  value: WeekType.BOTH,
                  child: Text('Les deux semaines'),
                ),
              ],
              onChanged: (WeekType? value) {
                if (value != null) {
                  ref
                      .read(addCalendarCourseControllerProvider.notifier)
                      .weekTypeChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),

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
      ),
    ),
    ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erreur: $error')),
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