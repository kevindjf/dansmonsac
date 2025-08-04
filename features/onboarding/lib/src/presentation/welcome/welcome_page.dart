import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:onboarding/src/presentation/hour/setup_time_page.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:onboarding/src/repositories/onboarding_supabase_repository.dart';

class OnboardingWelcomePage extends ConsumerWidget {
  static const String routeName = "/welcome-onboarding";

  const OnboardingWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Spacer(
                flex: 1,
              ),
              // Titre
              Text(
                "Prépare ton sac en un clin d'œil ! ",
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                "Fini les galères du matin ! Avec Dans Mon Sac, prépare ton sac en un clin d'œil et évite les oublis. Simple, rapide et efficace !",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),
              // Bouton Next
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  // Appel de la méthode du contrôleur sans passer le context
                  onPressed: () => ref.read(routerDelegateProvider).setRoute(OnboardingSetupTimePage.routeName),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
