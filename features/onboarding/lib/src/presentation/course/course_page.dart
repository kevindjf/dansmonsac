import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onboarding/src/presentation/course/controller/course_onboarding_controller.dart';
import 'package:onboarding/src/presentation/hour/setup_time_page.dart';

class OnboardingCoursePage extends ConsumerStatefulWidget {
  static const String routeName = "/course-onboarding";

  const OnboardingCoursePage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingCoursePage> createState() =>
      _OnboardingCoursePageState();
}

class _OnboardingCoursePageState extends ConsumerState<OnboardingCoursePage> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _supplyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _courseNameController.addListener(() => ref
        .read(courseOnboardingControllerProvider.notifier)
        .courseNameChanged(_courseNameController.text));
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _supplyController.dispose();
    super.dispose();
  }

  void _addSupply() {
    if (_supplyController.text.isNotEmpty) {
      ref
          .read(courseOnboardingControllerProvider.notifier)
          .addSupply(_supplyController.text);
      _supplyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    var state = ref.watch(courseOnboardingControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        "Ajoute ton 1er cours !",
                        style: textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        "Ajoute ton premier cours, indique la matière, et sélectionne les fournitures dont tu auras besoin pour être prêt !",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _courseNameController,
                        labelText: "Nom du cours",
                      ),
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
                      const SizedBox(height: 24),

                      // Section des fournitures
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Affaires à prévoir",
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Note tout ce qu'il te faut pour ce cours, on s'occupe de te le rappeler !",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.left,
                          ),

                          const SizedBox(height: 32),

                          // Input pour ajouter des fournitures
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _supplyController,
                                  labelText: "Fourniture",
                                  hintText: "Exemple : Classeur vert",
                                  onSubmitted: (_) => _addSupply(),
                                ),
                              ),
                              IconButton(
                                onPressed: _addSupply,
                                icon:
                                    Icon(Icons.add, color: colorScheme.primary),
                                tooltip: "Ajouter une fourniture",
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Liste des fournitures ajoutées
                          Container(
                            constraints: BoxConstraints(
                              // Hauteur fixe pour la liste, évite que le ListView prenne trop de place
                              maxHeight: 200,
                            ),
                            child: state.supplies.isEmpty
                                ? Center(
                                    child: Text(
                                      "Aucune fourniture ajoutée",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.supplies.length,
                                    itemBuilder: (context, index) {
                                      String supply = state.supplies[index];

                                      return ListTile(
                                        title: Text(supply),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          onPressed: () {
                                            ref
                                                .read(
                                                    courseOnboardingControllerProvider
                                                        .notifier)
                                                .removeSupply(index);
                                          },
                                          tooltip: "Supprimer",
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // Espace supplémentaire pour s'assurer que le défilement fonctionne bien
                          const SizedBox(height: 50),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Boutons fixes en bas de l'écran (ne se déplacent pas avec le clavier)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        ref
                            .read(courseOnboardingControllerProvider.notifier)
                            .store();
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Prêt à commencer ?",
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
                        FocusScope.of(context).unfocus();
                        ref.watch(courseOnboardingControllerProvider.notifier).skip();
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
      ),
    );
  }

  // Widget réutilisable pour les champs de texte
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    Function(String)? onSubmitted,
  }) {
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
