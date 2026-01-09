import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:onboarding/src/presentation/week_explanation/week_explanation_page.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:onboarding/src/repositories/onboarding_supabase_repository.dart';

class OnboardingWelcomePage extends ConsumerWidget {
  static const String routeName = "/welcome-onboarding";

  const OnboardingWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
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
                const SizedBox(height: 48),

                // Icône
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.backpack,
                    size: 80,
                    color: accentColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Titre
                Text(
                  "Bienvenue dans DansMonSac !",
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  "Ton assistant personnel pour ne plus rien oublier à l'école",
                  style: textTheme.titleLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Points clés
                _buildFeaturePoint(
                  Icons.calendar_today,
                  "Gère ton emploi du temps en semaines A/B",
                  colorScheme,
                ),
                const SizedBox(height: 16),
                _buildFeaturePoint(
                  Icons.checklist_rtl,
                  "Liste automatique des fournitures à préparer",
                  colorScheme,
                ),
                const SizedBox(height: 16),
                _buildFeaturePoint(
                  Icons.notifications_active,
                  "Rappel quotidien pour préparer ton sac",
                  colorScheme,
                ),

                const SizedBox(height: 48),

                // Bouton Commencer
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => ref.read(routerDelegateProvider).setRoute(OnboardingWeekExplanationPage.routeName),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Commencer",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildFeaturePoint(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.secondary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
