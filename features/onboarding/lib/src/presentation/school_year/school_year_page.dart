import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/ui/ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onboarding/src/presentation/school_year/controller/school_year_onboarding_controller.dart';
import 'package:intl/intl.dart';

class OnboardingSchoolYearPage extends ConsumerStatefulWidget {
  static const String routeName = "/school-year-onboarding";

  const OnboardingSchoolYearPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingSchoolYearPage> createState() =>
      _OnboardingSchoolYearPageState();
}

class _OnboardingSchoolYearPageState
    extends ConsumerState<OnboardingSchoolYearPage> {
  StreamSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();

    _errorSubscription = ref
        .read(schoolYearOnboardingControllerProvider.notifier)
        .errorStream
        .listen((errorMessage) {
      if (mounted) {
        ShowErrorMessage.show(context, errorMessage);
      }
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = Theme.of(context).colorScheme.secondary;

    var state = ref.watch(schoolYearOnboardingControllerProvider);
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bouton Skip en haut à droite
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () => ref
                              .read(schoolYearOnboardingControllerProvider.notifier)
                              .skip(),
                      child: Text(
                        "Passer",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Titre
                Text(
                  "Début de l'année scolaire",
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  "Quelle est la date de ta première semaine A ?\n\nOn utilisera cette info pour gérer l'alternance des semaines.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Affichage de la date sélectionnée
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event,
                        size: 48,
                        color: accentColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dateFormat.format(state.schoolYearStart),
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "(1er lundi de septembre par défaut)",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton pour changer la date
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _selectDate(state.schoolYearStart),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: accentColor, width: 2),
                    ),
                    child: Text(
                      "Modifier la date",
                      style: TextStyle(
                        fontSize: 16,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton Suivant
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () => ref
                            .read(schoolYearOnboardingControllerProvider.notifier)
                            .store(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Text(
                            "Suivant",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(DateTime initial) async {
    final accentColor = Theme.of(context).colorScheme.secondary;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF303030),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initial) {
      ref
          .read(schoolYearOnboardingControllerProvider.notifier)
          .updateDate(picked);
    }
  }
}
