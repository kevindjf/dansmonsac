import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:main/presentation/home/home_page.dart';

class OnboardingNotificationPermissionPage extends ConsumerStatefulWidget {
  static const String routeName = "/notification-permission-onboarding";

  const OnboardingNotificationPermissionPage({super.key});

  @override
  ConsumerState<OnboardingNotificationPermissionPage> createState() =>
      _OnboardingNotificationPermissionPageState();
}

class _OnboardingNotificationPermissionPageState
    extends ConsumerState<OnboardingNotificationPermissionPage> {
  bool _isStarting = false;

  Future<void> _startApp() async {
    setState(() {
      _isStarting = true;
    });

    try {
      // Request notification permissions
      final granted = await NotificationService.requestPermissions();

      if (!granted && mounted) {
        // Show dialog explaining that permissions are recommended
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Autorisation recommandée'),
            content: const Text(
              'Pour recevoir tes rappels quotidiens, tu peux activer les notifications dans les paramètres de ton appareil.\n\n'
              'Paramètres > Applications > DansMonSac > Notifications\n\n'
              'Tu pourras aussi le faire plus tard depuis les paramètres de l\'app.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Compris'),
              ),
            ],
          ),
        );
      }

      // Mark onboarding as completed
      await PreferencesService.setOnboardingCompleted(true);

      // Navigate to home using the app's routing system
      if (mounted) {
        ref.read(routerDelegateProvider).goToHome();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  Future<void> _skipToApp() async {
    // Mark onboarding as completed without requesting permissions
    await PreferencesService.setOnboardingCompleted(true);

    // Navigate to home
    if (mounted) {
      ref.read(routerDelegateProvider).goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 80,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Reçois tes rappels',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Pour ne jamais oublier de préparer ton sac, active les notifications.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Features list
              _buildFeature(
                icon: Icons.alarm,
                title: 'Rappel quotidien',
                description: 'Reçois une notification à l\'heure que tu as choisie',
                accentColor: accentColor,
              ),

              const SizedBox(height: 16),

              _buildFeature(
                icon: Icons.event_note,
                title: 'Liste personnalisée',
                description:
                    'La notification affiche les fournitures pour le lendemain',
                accentColor: accentColor,
              ),

              const SizedBox(height: 16),

              _buildFeature(
                icon: Icons.privacy_tip,
                title: '100% privé',
                description:
                    'Notifications locales uniquement, aucune donnée envoyée',
                accentColor: accentColor,
              ),

              const Spacer(),

              // Main button - Start app with notification request
              FilledButton.icon(
                onPressed: _isStarting ? null : _startApp,
                icon: _isStarting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.rocket_launch),
                label: Text(
                  _isStarting ? 'Démarrage...' : 'Commencer',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 8),

              // Skip button
              TextButton(
                onPressed: _isStarting ? null : _skipToApp,
                child: const Text('Passer cette étape'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
