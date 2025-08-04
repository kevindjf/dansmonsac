import 'dart:async';

import 'package:course/models/cours_with_supplies.dart';
import 'package:course/presentation/add/add_course_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCoursePage extends ConsumerStatefulWidget {
  final ValueChanged<CourseWithSupplies?> onAddCourse;

  const AddCoursePage({Key? key, required this.onAddCourse}) : super(key: key);

  @override
  ConsumerState<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends ConsumerState<AddCoursePage> {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _errorSubscription;
  StreamSubscription? _successSubscription;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() => ref
        .read(addCourseControllerProvider.notifier)
        .courseNameChanged(_controller.text));

    _errorSubscription = ref
        .read(addCourseControllerProvider.notifier)
        .errorStream
        .listen((errorMessage) {
      if (mounted) {
        print("error");
        // ShowErrorMessage.show(context, errorMessage);
      }
    });

    _successSubscription = ref
        .read(addCourseControllerProvider.notifier)
        .successStream
        .listen((course) {
      if (mounted) {
        widget.onAddCourse(course);
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var state = ref.watch(addCourseControllerProvider);

    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Ajuste le padding selon la hauteur du clavier
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // Permet d'éviter que la bottom sheet prenne toute la hauteur
          children: [
            Text(
              "Nouveau cours",
              style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField(
                controller: _controller,
                labelText: "Cours",
                hintText: "Exemple : Maths",
                onSubmitted: (text) {
                  ref.read(addCourseControllerProvider.notifier).store();
                },
                context: context),
            state.errorCourseName == null
                ? const SizedBox()
                : Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${state.errorCourseName}",
                        style: TextStyle(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(addCourseControllerProvider.notifier).store();
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

                // Bouton Plus tard
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Fermer le clavier d'abord
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
                      "Plus tard",
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
