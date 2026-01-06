import 'dart:async';

import 'package:common/src/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onboarding/src/presentation/hour/controller/setup_time_onboarding_controller.dart';
import 'package:common/src/ui/ui.dart';

class OnboardingSetupTimePage extends ConsumerStatefulWidget {
  static const String routeName = "/setup-onboarding";

  const OnboardingSetupTimePage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingSetupTimePage> createState() =>
      _OnboardingSetupTimePageState();
}

class _OnboardingSetupTimePageState
    extends ConsumerState<OnboardingSetupTimePage> {
  StreamSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();

    _errorSubscription = ref
        .read(setupTimeOnboardingControllerProvider.notifier)
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

    var state = ref.watch(setupTimeOnboardingControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Titre
              Text(
                "À quelle heure tu prépares ton sac ?",
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                "Renseigne l'heure à laquelle tu fais ton sac, et on te rappellera ce qu'il te faut pour le lendemain. Plus d'oubli, plus de stress !",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              Spacer(
                flex: 1,
              ),

              // Sélecteur d'heure
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _selectTimePicker(state.setupTime),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Choisir une heure",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                state.setupTime.format(context),
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary.withAlpha(100),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),

              // Bouton Next
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () => ref
                          .read(setupTimeOnboardingControllerProvider.notifier)
                          .store(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isLoading
                      ? Center(
                          child: SizedBox(child: CircularProgressIndicator()),
                        )
                      : const Text(
                          "Suivant",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTimePicker(TimeOfDay initial) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null && picked != initial) {
      ref
          .read(setupTimeOnboardingControllerProvider.notifier)
          .updateTime(picked);
    }
  }
}
