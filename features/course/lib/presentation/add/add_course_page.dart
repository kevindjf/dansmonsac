import 'dart:async';

import 'package:common/src/ui/ui.dart';
import 'package:course/models/cours_with_supplies.dart';
import 'package:course/presentation/add/add_course_controller.dart';
import 'package:course/presentation/add/add_course_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCoursePage extends ConsumerStatefulWidget {
  final ValueChanged<CourseWithSupplies?> onAddCourse;

  const AddCoursePage({super.key, required this.onAddCourse});

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

    _controller.addListener(() {
      // Update course name and supply suggestions in one call
      ref
          .read(addCourseControllerProvider.notifier)
          .onCourseNameChanged(_controller.text);
    });

    _errorSubscription = ref
        .read(addCourseControllerProvider.notifier)
        .errorStream
        .listen((errorMessage) {
      if (mounted) {
        ShowErrorMessage.show(context, errorMessage);
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
    final bottomSafeArea = MediaQuery.of(context).viewPadding.bottom;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom + bottomSafeArea + 16,
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
                  color: Theme.of(context).colorScheme.onSurface,
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
            const SizedBox(height: 16),
            // Suggested supplies section
            _buildSuggestedSuppliesSection(state, colorScheme),
            const SizedBox(height: 16),
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
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildSuggestedSuppliesSection(
      AddCourseState state, ColorScheme colorScheme) {
    if (state.suggestedSupplies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fournitures suggérées",
          style: GoogleFonts.robotoCondensed(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Cochez les fournitures dont vous avez besoin",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          state.suggestedSupplies.length,
          (index) => _buildSuggestedSupplyItem(
            index,
            state.suggestedSupplies[index],
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedSupplyItem(
    int index,
    dynamic supply,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: supply.isChecked ? colorScheme.primary : Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        value: supply.isChecked,
        onChanged: (bool? value) {
          if (value != null) {
            ref
                .read(addCourseControllerProvider.notifier)
                .toggleSupplySuggestion(index, value);
          }
        },
        title: _SuggestedSupplyTextField(
          index: index,
          supply: supply,
          colorScheme: colorScheme,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: colorScheme.primary,
        checkColor: Colors.black,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}

/// Stateful widget to properly manage TextField controller lifecycle
class _SuggestedSupplyTextField extends ConsumerStatefulWidget {
  final int index;
  final dynamic supply;
  final ColorScheme colorScheme;

  const _SuggestedSupplyTextField({
    required this.index,
    required this.supply,
    required this.colorScheme,
  });

  @override
  ConsumerState<_SuggestedSupplyTextField> createState() =>
      _SuggestedSupplyTextFieldState();
}

class _SuggestedSupplyTextFieldState
    extends ConsumerState<_SuggestedSupplyTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.supply.name);
  }

  @override
  void didUpdateWidget(_SuggestedSupplyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text only if supply name changed from outside
    if (widget.supply.name != oldWidget.supply.name &&
        _controller.text != widget.supply.name) {
      _controller.text = widget.supply.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: TextStyle(
        color: widget.supply.isChecked ? Theme.of(context).colorScheme.onSurface : Colors.grey[500],
        fontSize: 14,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintText: 'Nom de la fourniture',
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      onChanged: (text) {
        ref
            .read(addCourseControllerProvider.notifier)
            .updateSuggestionText(widget.index, text);
      },
    );
  }
}
