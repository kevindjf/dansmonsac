import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:splash/presentation/controller/splash_controller.dart';

class SplashPage extends ConsumerWidget {
  static const String routeName = "/welcome-onboarding";

  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    ref.watch(splashControllerProvider);

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
                "Dans mon sac ",
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

              const Spacer(flex: 1),
              // Bouton Next
             CircularProgressIndicator(),
              const Spacer(flex: 1),

            ],
          ),
        ),
      ),
    );
  }
}
