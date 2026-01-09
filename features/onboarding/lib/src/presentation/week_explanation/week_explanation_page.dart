import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:onboarding/src/presentation/school_year/school_year_page.dart';

class OnboardingWeekExplanationPage extends ConsumerWidget {
  static const String routeName = "/week-explanation-onboarding";

  const OnboardingWeekExplanationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = Theme.of(context).colorScheme.secondary;

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
                      onPressed: () => ref.read(routerDelegateProvider).setRoute(OnboardingSchoolYearPage.routeName),
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

                // Icône
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    size: 64,
                    color: accentColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Titre
                Text(
                  "Système semaine A/B",
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  "Ton emploi du temps alterne entre semaine A et semaine B.\n\nChaque semaine, tes cours peuvent être différents. L'app gère automatiquement l'alternance pour t'afficher les bons cours !",
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Exemple visuel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWeekCard(
                      "Semaine A",
                      accentColor,
                      colorScheme,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.swap_horiz,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    _buildWeekCard(
                      "Semaine B",
                      accentColor,
                      colorScheme,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Bouton Suivant
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => ref.read(routerDelegateProvider).setRoute(OnboardingSchoolYearPage.routeName),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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

  Widget _buildWeekCard(String label, Color accentColor, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
